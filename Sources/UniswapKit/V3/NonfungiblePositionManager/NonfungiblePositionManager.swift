import Alamofire
import BigInt
import EvmKit
import Foundation
import HsToolKit

public class NonfungiblePositionManager {
    private let networkManager: NetworkManager
    private let dexType: DexType

    init(networkManager: NetworkManager, dexType: DexType) {
        self.networkManager = networkManager
        self.dexType = dexType
    }
    
    private func call(rpcSource: RpcSource, chain: Chain, data: Data) async throws -> Data {
        do {
            let contractAddress = dexType.nonfungiblePositionAddress(chain: chain)
            let a = try await EvmKit.Kit.call(networkManager: networkManager, rpcSource: rpcSource, contractAddress: contractAddress, data: data)
            return a
        } catch {
            throw error
        }
    }
}

private extension NonfungiblePositionManager {
    
    func tokenId(rpcSource: RpcSource, chain: Chain, owner: Address, token0: Address, token1: Address, fee: BigUInt, tickLower: BigInt, tickUpper: BigInt) async throws -> BigUInt? {
        let positionInfos = try await getPositionInfos(rpcSource: rpcSource, chain: chain, owner: owner)
        let tokenId = positionInfos.first(where: {
            $0.fee == fee &&
            $0.tickLower == tickLower &&
            $0.tickUpper == tickUpper
        })?.tokenId
        return tokenId
    }
    
    func getPositionInfos(rpcSource: RpcSource, chain: Chain, owner: Address) async throws -> [Positions] {
        let tokenIds = try await getPositionTokenIds(rpcSource: rpcSource, chain: chain, owner: owner)
        var positions = [Positions]()
        for tokenId in tokenIds {
            let method = PositionsMethod(tokenId: tokenId)
            let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
            guard let position = Positions(data: data, _tokenId: tokenId) else {
                throw PositionManagerError.UniswapV3PositionDataError
            }
            positions.append(position)
        }
        return positions
    }
    
    func getPositionTokenIds(rpcSource: RpcSource, chain: Chain, owner: Address) async throws -> [BigUInt] {
        let numPositions = try await numPositions(rpcSource: rpcSource, chain: chain, owner: owner)
        var positionIds = [BigUInt]()
        for index in 0 ..< numPositions {
            if let numPositions = try await positionId(rpcSource: rpcSource, chain: chain, owner: owner, index: index) {
                positionIds.append(numPositions)
            }
        }
        return positionIds
    }
    
    func numPositions(rpcSource: RpcSource, chain: Chain, owner: Address) async throws -> BigUInt {
        let method = BalanceOfMethod(owner: owner)
        let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
        guard data.count >= 32 else {
            return 0
        }
        let num = BigUInt(data[0 ..< 32])
        return num
    }
    
    func positionId(rpcSource: RpcSource, chain: Chain, owner: Address, index: BigUInt) async throws -> BigUInt? {
        let method = TokenOfOwnerByIndexMethod(owner: owner, index: index)
        let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
        guard data.count >= 32 else {
            return nil
        }
        let tokenId = BigUInt(data[0 ..< 32])
        return tokenId
    }
    
    func totalSupply(rpcSource: RpcSource, chain: Chain) async throws -> BigUInt? {
        let method = TotalSupplyMethod()
        let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
        guard data.count >= 32 else {
            return nil
        }
        let total = BigUInt(data[0 ..< 32])
        return total
    }
/*
    func createAndInitializePoolIfNecessary(rpcSource: RpcSource, chain: Chain, token0: Address, token1: Address, fee: BigUInt, sqrtPriceX96: BigUInt) async throws -> Address {
        let method = CreateAndInitializePoolMethod(token0: token0, token1: token1, fee: fee, sqrtPriceX96: sqrtPriceX96)
        let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
        guard data.count >= 32 else {
            throw PositionManagerError.createAndInitializePoolError
        }
        let poolAddress = Address(raw: data[0 ..< 32])
        return poolAddress
    }
*/
}

private extension NonfungiblePositionManager {
    
    func buildMethodForExact(tradeData: TradeDataV3, tickLower: BigInt, tickUpper: BigInt, recipient: Address, rpcSource: RpcSource, chain: Chain, deadline: BigUInt) async throws -> ContractMethod {
        let trade = tradeData.trade
        let tokentIn = trade.tokenAmountIn.token
        let tokentOut = trade.tokenAmountOut.token
        
        let (token0, token1) = tokentIn.sortsBefore(token: tokentOut) ? (tokentIn, tokentOut) : (tokentOut, tokentIn)
        let (amount0, amount1) = tokentIn.sortsBefore(token: tokentOut) ? (trade.tokenAmountIn.rawAmount, trade.tokenAmountOut.rawAmount) : (trade.tokenAmountOut.rawAmount ,trade.tokenAmountIn.rawAmount)
        let (amount0Min, amount1Min) = tokentIn.sortsBefore(token: tokentOut) ? (tradeData.tokenAmountInMin.rawAmount, tradeData.tokenAmountOutMin.rawAmount) : (tradeData.tokenAmountOutMin.rawAmount, tradeData.tokenAmountInMin.rawAmount)
        
        if  let tokenId = try await tokenId(rpcSource: rpcSource,
                                            chain: chain,
                                            owner: recipient,
                                            token0: token0.address,
                                            token1: token1.address,
                                            fee: trade.swapPath.firstFeeAmount.rawValue,
                                            tickLower: tickLower,
                                            tickUpper: tickUpper) {
            
            let method = IncreaseLiquidityMethod(tokenId: tokenId,
                                                 amount0Desired: amount0,
                                                 amount1Desired: amount1,
                                                 amount0Min: amount0Min,
                                                 amount1Min: amount1Min,
                                                 deadline: deadline
            )
           return method
            
        } else {
            /// mint a new position
            let method = MintMethod(token0: token0.address,
                                    token1: token1.address,
                                    fee: trade.swapPath.firstFeeAmount.rawValue,
                                    tickLower: tickLower,
                                    tickUpper: tickUpper,
                                    amount0Desired: amount0,
                                    amount1Desired: amount1,
                                    amount0Min: amount0Min,
                                    amount1Min: amount1Min,
                                    recipient: recipient,
                                    deadline: deadline
            )
            return method
        }
    }
}

extension NonfungiblePositionManager {
    
    func addLiquidityTransactionData(
            tradeData: TradeDataV3,
            tradeOptions: TradeOptions,
            recipient: Address,
            rpcSource: RpcSource,
            chain: Chain,
            deadline: BigUInt
    ) async throws -> TransactionData {
  
        var methods = [ContractMethod]()
        
        guard let tickInfo = tradeData.tickInfo else {
            throw PositionManagerError.tickInfoNotFound
        }
        
        let tickLower = tickInfo.tickLower
        let tickUpper = tickInfo.tickUpper
        
        let swapMethod = try await buildMethodForExact(tradeData: tradeData, tickLower: tickLower, tickUpper: tickUpper, recipient: recipient, rpcSource: rpcSource, chain: chain, deadline: deadline)
        
        if tradeData.trade.tokenAmountIn.token.isEther, tradeData.type == .exactOut {
            methods.append(RefundEthMethod())
        }
        
        if tradeData.trade.tokenAmountOut.token.isEther {
            methods.append(UnwrapWeth9Method(amountMinimum: tradeData.tokenAmountOutMin.rawAmount, recipient: recipient))
        }

        let resultMethod = (methods.count > 1) ? MulticallMethod(methods: methods) : swapMethod
        let contractAddress = dexType.nonfungiblePositionAddress(chain: chain)
        return TransactionData(to: contractAddress, value: 0, input: resultMethod.encodedABI_fix())
    }
    
    func removeLiquidityTransactionData(
            positions: Positions,
            rpcSource: RpcSource,
            chain: Chain,
            liquidity: BigUInt,
            slippage: BigUInt,
            recipient: Address,
            deadline: BigUInt
    ) async throws -> TransactionData {
           
        let (amount0, amount1, _) = try await getAmountsForLiquidity(positions: positions, rpcSource: rpcSource, chain: chain, liquidity: liquidity)
        
        let amount0Min = amount0 - amount0.multiplied(by: slippage)/1000
        let amount1Min = amount1 - amount1.multiplied(by: slippage)/1000
        
        var methods = [ContractMethod]()
        
        let decreaseMethod = DecreaseLiquidityMethod(tokenId: positions.tokenId, liquidity: liquidity, amount0Min: amount0Min, amount1Min: amount1Min, deadline: deadline)
        methods.append(decreaseMethod)
        
        let amount0Max: BigUInt = BigUInt(2).power(128) - 1
        let amount1Max: BigUInt = BigUInt(2).power(128) - 1
        let collectMethod = CollectMethod(tokenId: positions.tokenId, recipient: recipient, amount0Max: amount0Max, amount1Max: amount1Max)
        methods.append(collectMethod)
        
        let resultMethod =  (methods.count > 1) ? MulticallMethod(methods: methods) : decreaseMethod
        let contractAddress = dexType.nonfungiblePositionAddress(chain: chain)
        return TransactionData(to: contractAddress, value: 0, input: resultMethod.encodedABI())
    }
}
extension NonfungiblePositionManager {
    
    func getPositions(tokenId: BigUInt, rpcSource: RpcSource, chain: Chain) async throws -> Positions {
        let method = PositionsMethod(tokenId: tokenId)
        let data = try await call(rpcSource: rpcSource, chain: chain, data: method.encodedABI())
        guard let positions = Positions(data: data, _tokenId: tokenId) else {
            throw PositionManagerError.UniswapV3PositionDataError
        }
        return positions
    }
    
    func getAmountsForLiquidity(positions: Positions, rpcSource: RpcSource, chain: Chain, liquidity: BigUInt) async throws -> (BigUInt, BigUInt, Bool) {
        let pool = try await Pool(networkManager: networkManager, rpcSource: rpcSource, chain: chain, token0: positions.token0, token1: positions.token1, fee: KitV3.FeeAmount(rawValue: positions.fee)!, dexType: dexType)
        let slot0 = try await pool.slot0()
        let sqrtPriceX96 = slot0.sqrtPriceX96
        let sqrtPriceAX96 = try TickMath.getSqrtRatioAtTick(tick: positions.tickLower)
        let sqrtPriceBX96 = try TickMath.getSqrtRatioAtTick(tick: positions.tickUpper)
                
        guard let (amount0,amount1) = LiquidityAmounts.getAmountsForLiquidity(liquidity: liquidity, sqrtRatioX96: sqrtPriceX96, sqrtRatioAX96: sqrtPriceAX96, sqrtRatioBX96: sqrtPriceBX96) else {
            throw PositionManagerError.amountsForLiquidityError
        }
        let  isInRange = sqrtPriceAX96 <= sqrtPriceX96 && sqrtPriceX96 <= sqrtPriceBX96
        return (amount0, amount1, isInRange)
    }
    
    func ownedLiquidity(rpcSource: RpcSource, chain: Chain, owner: Address) async throws -> [Positions] {
        return try await getPositionInfos(rpcSource: rpcSource, chain: chain, owner: owner)
    }
}

extension NonfungiblePositionManager {

    enum PositionManagerError: Error {
        case tokenIdNotFound
        case tickInfoNotFound
        case decreaseLiquidityFailed
        case cantFetchNumPositions
        case cantFetchPositionIds
        case UniswapV3PositionDataError
        case PancakeV3PositionDataError
        case positionIdDataError
        case createAndInitializePoolError
        case amountsForLiquidityError
    }

    struct UInt128 {
        var high: UInt64
        var low: UInt64
        
        static let max = UInt128(high: UInt64.max, low: UInt64.max)
    }
}
