import Foundation
import EvmKit
import BigInt

public class PancakeSwapKit {
    private let tradeManager: TradeManager
    private let pairSelector: PairSelector
    private let tokenFactory: TokenFactory

    init(tradeManager: TradeManager, pairSelector: PairSelector, tokenFactory: TokenFactory) {
        self.tradeManager = tradeManager
        self.pairSelector = pairSelector
        self.tokenFactory = tokenFactory
    }

}

extension PancakeSwapKit {

    public var routerAddress: Address {
        tradeManager.routerAddress
    }

    public var etherToken: Token {
        tokenFactory.etherToken
    }

    public func token(contractAddress: Address, decimals: Int) -> Token {
        tokenFactory.token(contractAddress: contractAddress, decimals: decimals)
    }

    public func swapData(tokenIn: Token, tokenOut: Token) async throws -> SwapData {
        let tokenPairs = pairSelector.tokenPairs(tokenA: tokenIn, tokenB: tokenOut)

        let pairs = try await withThrowingTaskGroup(of: Pair.self) { taskGroup in
            tokenPairs.forEach { token, token2 in
                taskGroup.addTask { try await self.tradeManager.pair(tokenA: token, tokenB: token2) }
            }

            return try await taskGroup.reduce(into: [Pair]()) { result, pair in
                result.append(pair)
            }
        }

        return SwapData(pairs: pairs, tokenIn: tokenIn, tokenOut: tokenOut)
    }
        
    public func bestTradeExactIn(swapData: SwapData, amountIn: Decimal, options: TradeOptions = TradeOptions()) throws -> TradeData {
        guard amountIn > 0 else {
            throw TradeError.zeroAmount
        }

        let tokenAmountIn = try TokenAmount(token: swapData.tokenIn, decimal: amountIn)

        let sortedTrades = try TradeManager.tradesExactIn(
                pairs: swapData.pairs,
                tokenAmountIn: tokenAmountIn,
                tokenOut: swapData.tokenOut
        ).sorted()

        guard let bestTrade = sortedTrades.first else {
            throw TradeError.tradeNotFound
        }

        return TradeData(trade: bestTrade, options: options)
    }

    public func bestTradeExactOut(swapData: SwapData, amountOut: Decimal, options: TradeOptions = TradeOptions()) throws -> TradeData {
        guard amountOut > 0 else {
            throw TradeError.zeroAmount
        }

        let tokenAmountOut = try TokenAmount(token: swapData.tokenOut, decimal: amountOut)

        let sortedTrades = try TradeManager.tradesExactOut(
                pairs: swapData.pairs,
                tokenIn: swapData.tokenIn,
                tokenAmountOut: tokenAmountOut
        ).sorted()

//        print("Trades: \(sortedTrades)")

        guard let bestTrade = sortedTrades.first else {
            throw TradeError.tradeNotFound
        }

        return TradeData(trade: bestTrade, options: options)
    }

    public func transactionData(tradeData: TradeData) throws -> TransactionData {
        try tradeManager.transactionData(tradeData: tradeData)
    }
    
    public func transactionLiquidityData(tradeData: TradeData) throws -> TransactionData {
        try tradeManager.transactionLiquidityData(tradeData: tradeData)
    }

}

extension PancakeSwapKit {

    public static func instance(evmKit: EvmKit.Kit) throws -> PancakeSwapKit {
        let address = evmKit.address

        let tradeManager = try TradeManager(evmKit: evmKit, address: address)
        let tokenFactory = try TokenFactory(chain: evmKit.chain)
        let pairSelector = PairSelector(tokenFactory: tokenFactory)

        let swapKit = PancakeSwapKit(tradeManager: tradeManager, pairSelector: pairSelector, tokenFactory: tokenFactory)

        return swapKit
    }

//    public static func addDecorators(to evmKit: EvmKit.Kit) {
//        evmKit.add(methodDecorator: SwapMethodDecorator(contractMethodFactories: SwapContractMethodFactories.shared))
//        evmKit.add(transactionDecorator: SwapTransactionDecorator())
//    }

}

extension PancakeSwapKit {

    public enum FractionError: Error {
        case negativeDecimal
        case invalidSignificand(value: String)
    }

    public enum TradeError: Error {
        case zeroAmount
        case tradeNotFound
        case invalidTokensForSwap
    }

    public enum PairError: Error {
        case notInvolvedToken
        case insufficientReserves
        case insufficientReserveOut
    }

    public enum RouteError: Error {
        case emptyPairs
        case invalidPair(index: Int)
    }

}
