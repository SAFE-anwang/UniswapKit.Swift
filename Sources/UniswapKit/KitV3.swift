import BigInt
import EvmKit
import Foundation
import HsToolKit

public class KitV3 {
    private let dexType: DexType
    private let quoter: QuoterV2
    private let swapRouter: SwapRouter
    private let tokenFactory: TokenFactory
    private let nonfungiblePositionManager: NonfungiblePositionManager
    
    init(dexType: DexType, quoter: QuoterV2, swapRouter: SwapRouter, tokenFactory: TokenFactory, nonfungiblePositionManager: NonfungiblePositionManager) {
        self.dexType = dexType
        self.quoter = quoter
        self.swapRouter = swapRouter
        self.tokenFactory = tokenFactory
        self.nonfungiblePositionManager = nonfungiblePositionManager
    }
}

public extension KitV3 {
    func routerAddress(chain: Chain) -> Address {
        dexType.routerAddress(chain: chain)
    }
    
    func nonfungiblePositionAddress(chain: Chain) -> Address {
        dexType.nonfungiblePositionAddress(chain: chain)
    }

    func etherToken(chain: Chain) throws -> Token {
        try tokenFactory.etherToken(chain: chain)
    }

    func token(contractAddress: Address, decimals: Int) -> Token {
        tokenFactory.token(contractAddress: contractAddress, decimals: decimals)
    }

    func bestTradeExactIn(rpcSource: RpcSource, chain: Chain, tokenIn: Token, tokenOut: Token, amountIn: Decimal, options: TradeOptions) async throws -> TradeDataV3 {
        guard let amountIn = BigUInt(amountIn.hs.roundedString(decimal: tokenIn.decimals)), !amountIn.isZero else {
            throw TradeError.zeroAmount
        }

        let trade = try await quoter.bestTradeExactIn(rpcSource: rpcSource, chain: chain, tokenIn: tokenIn, tokenOut: tokenOut, amountIn: amountIn)
        return TradeDataV3(trade: trade, options: options)
    }

    func bestTradeExactOut(rpcSource: RpcSource, chain: Chain, tokenIn: Token, tokenOut: Token, amountOut: Decimal, options: TradeOptions) async throws -> TradeDataV3 {
        guard let amountOut = BigUInt(amountOut.hs.roundedString(decimal: tokenOut.decimals)), !amountOut.isZero else {
            throw TradeError.zeroAmount
        }

        let trade = try await quoter.bestTradeExactOut(rpcSource: rpcSource, chain: chain, tokenIn: tokenIn, tokenOut: tokenOut, amountOut: amountOut)
        return TradeDataV3(trade: trade, options: options)
    }

    func transactionData(receiveAddress: Address, chain: Chain, bestTrade: TradeDataV3, tradeOptions: TradeOptions) throws -> TransactionData {
        swapRouter.transactionData(receiveAddress: receiveAddress, chain: chain, tradeData: bestTrade, tradeOptions: tradeOptions)
    }
}

public extension KitV3 {
    static func instance(dexType: DexType) throws -> KitV3 {
        let networkManager = NetworkManager()
        let tokenFactory = TokenFactory()
        let quoter = QuoterV2(networkManager: networkManager, tokenFactory: tokenFactory, dexType: dexType)
        let swapRouter = SwapRouter(dexType: dexType)
        let nonfungiblePositionManager = NonfungiblePositionManager(networkManager: networkManager, dexType: dexType)
        let uniswapKit = KitV3(dexType: dexType,
                               quoter: quoter,
                               swapRouter: swapRouter,
                               tokenFactory: tokenFactory,
                               nonfungiblePositionManager: nonfungiblePositionManager
                              )

        return uniswapKit
    }

    static func addDecorators(to evmKit: EvmKit.Kit) throws {
        let tokenFactory = TokenFactory()
        evmKit.add(methodDecorator: SwapV3MethodDecorator(contractMethodFactories: SwapV3ContractMethodFactories.shared))
        try evmKit.add(transactionDecorator: SwapV3TransactionDecorator(wethAddress: tokenFactory.etherToken(chain: evmKit.chain).address))
    }

    static func isSupported(chain: Chain) -> Bool {
        switch chain {
        case .ethereumGoerli, .ethereum, .polygon, .optimism, .arbitrumOne, .binanceSmartChain: return true
        default: return false
        }
    }
}

public extension KitV3 {
    enum FeeAmount: BigUInt, CaseIterable {
        case lowest = 100
        case low = 500
        case mediumPancakeSwap = 2500
        case mediumUniswap = 3000
        case high = 10000

        static func sorted(dexType: DexType) -> [FeeAmount] {
            [
                .lowest,
                .low,
                dexType.mediumFeeAmount,
                .high,
            ]
        }
    }

    enum TradeError: Error {
        case zeroAmount
        case tradeNotFound
        case invalidTokensForSwap
    } 
}

extension KitV3 {
    enum KitError: Error {
        case unsupportedChain
    }
}

public extension KitV3 {
    
    enum TickSpacing: BigUInt, CaseIterable {
        case lowest = 1
        case low = 10
        case medium = 50
        case high = 200

        static func tickSpacing(fee: FeeAmount) -> TickSpacing {
            switch fee {
            case .lowest:
                return .lowest
            case .low:
                return .low
            case .mediumPancakeSwap, .mediumUniswap:
                return .medium
            case .high:
                return .high
            }
        }
    }
    
    enum LiquidityTickType: Equatable {
         case full
         case multi(value: Decimal)
         case range(lower: BigInt?, upper: BigInt?)
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.full, .full): return true
            case let (.multi(lh), .multi(rh)): return lh == rh
            case let (.range(lh0,lh1), .range(rh0,rh1)): return lh0 == rh0 && lh1 == rh1
            default: return false
            }
        }
     }
    
    enum TickError: Error {
        case tickInfoNotFound
    }
}

public extension KitV3 {
    
    func liquidityBestTradeExact(rpcSource: RpcSource, chain: Chain, tokenIn: Token, tokenOut: Token, amountIn: Decimal, options: TradeOptions, tickType: KitV3.LiquidityTickType) async throws -> TradeDataV3 {

        guard let amountIn = BigUInt(amountIn.hs.roundedString(decimal: tokenIn.decimals)), !amountIn.isZero else {
            throw TradeError.zeroAmount
        }
        let trade = try await quoter.liquidityBestTradeSingle(rpcSource: rpcSource, chain: chain, tokenIn: tokenIn, tokenOut: tokenOut, amountIn: amountIn, tickType: tickType)
        return TradeDataV3(trade: trade, options: options)
    }
    
    func addLiquidityTransactionData(bestTrade: TradeDataV3, tradeOptions: TradeOptions, recipient: Address, rpcSource: RpcSource, chain: Chain, deadline: BigUInt) async throws -> TransactionData {
        return try await nonfungiblePositionManager.addLiquidityTransactionData(tradeData: bestTrade, tradeOptions: tradeOptions, recipient: recipient, rpcSource: rpcSource, chain: chain, deadline: deadline)
    }
    
    func removeLiquidityTransactionData(positions: Positions, rpcSource: RpcSource, chain: Chain, liquidity: BigUInt, slippage: BigUInt, recipient: Address, deadline: BigUInt) async throws -> TransactionData {
        try await nonfungiblePositionManager.removeLiquidityTransactionData(positions: positions, rpcSource: rpcSource, chain: chain, liquidity: liquidity, slippage: slippage, recipient: recipient, deadline: deadline)
    }
    
    var minTick: BigInt {
        TickMath.MIN_TICK
    }
    
    var maxTick: BigInt {
        TickMath.MAX_TICK
    }
    
    func getSqrtRatioAtTick(tick: BigInt) throws -> BigUInt {
        try TickMath.getSqrtRatioAtTick(tick: tick)
    }
    
    func getTickAtSqrtRatio(sqrtRatioX96: BigUInt) throws -> BigInt {
        try TickMath.getTickAtSqrtRatio(sqrtPriceX96: sqrtRatioX96)
    }
    
    /// price to sqrtRatioX96
    func encodeSqrtRatioX96(price: Decimal, tokenA: Token ,tokenB: Token) -> BigUInt? {
        let reverted = tokenA.address.hex <= tokenB.address.hex
        let(token0, token1) = reverted ? (tokenA, tokenB) : (tokenB, tokenA)
        let token0Decimals: Int = token0.decimals
        let token1Decimals: Int = token1.decimals
        let amountA = Decimal(1) * pow(10, token0Decimals)
//        let reverted = token0.address.hex <= token1.address.hex
        let amountB = reverted ? price * pow(10, token1Decimals) : price.reciprocal * pow(10, token1Decimals) 
        
        guard let amount0 = amountA.toBigUInt(), !amount0.isZero else { return nil }
        guard let amount1 = amountB.toBigUInt(), !amount1.isZero else { return nil }
        return TickMath.encodeSqrtRatioX96(amount1: amount1, amount0: amount0)
    }
    
    func correctedX96Price(sqrtPriceX96: BigUInt, tokenIn: Token, tokenOut: Token) -> Decimal? {
        quoter.correctedX96Price(sqrtPriceX96: sqrtPriceX96, tokenIn: tokenIn, tokenOut: tokenOut)
    }
    
    func getAmountsForLiquidity(positions: Positions, rpcSource: RpcSource, chain: Chain, liquidity: BigUInt) async throws -> (BigUInt, BigUInt, Bool) {
        try await nonfungiblePositionManager.getAmountsForLiquidity(positions: positions, rpcSource: rpcSource, chain: chain, liquidity: liquidity)
    }

    func ownedLiquidity(rpcSource: RpcSource, chain: Chain, owner: Address) async throws -> [Positions] {
        try await nonfungiblePositionManager.ownedLiquidity(rpcSource: rpcSource, chain: chain, owner: owner)
    }

}

