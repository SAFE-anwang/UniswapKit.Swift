import BigInt
import Foundation

public class TradeV3 {
    public let type: TradeType

    let swapPath: SwapPath
    let executionPrice: Price
    let slotPrices: [Decimal]
    let tokenAmountIn: TokenAmount
    let tokenAmountOut: TokenAmount
    public var tickInfo: TickInfo?

    public init(tradeType: TradeType, swapPath: SwapPath, amountIn: BigUInt, amountOut: BigUInt, tokenIn: Token, tokenOut: Token, slotPrices: [Decimal], tickInfo: TickInfo? = nil) {
        type = tradeType
        self.swapPath = swapPath
        self.slotPrices = slotPrices
        self.tickInfo = tickInfo
        
        tokenAmountIn = TokenAmount(token: tokenIn, rawAmount: amountIn)
        tokenAmountOut = TokenAmount(token: tokenOut, rawAmount: amountOut)

        executionPrice = Price(baseTokenAmount: tokenAmountIn, quoteTokenAmount: tokenAmountOut)
    }
}

public extension TradeV3 {
    var priceImpact: Decimal? {
        let decimals = tokenAmountIn.token.decimals - tokenAmountOut.token.decimals
        var tradePrice = PriceImpactHelper.price(in: tokenAmountIn.rawAmount, out: tokenAmountOut.rawAmount, shift: decimals)

        let reverted = tokenAmountIn.token.address.hex >= tokenAmountOut.token.address.hex
        if reverted, let tp = tradePrice {
            tradePrice = 1 / tp
        }

        var slotPrice: Decimal?
        if !slotPrices.isEmpty {
            var result: Decimal = 1
            for decimal in slotPrices {
                result *= decimal
            }
            slotPrice = result
        } else {
            slotPrice = nil
        }

        guard let slotPrice,
              let tradePrice
        else {
            return nil
        }

        return PriceImpactHelper.impact(price: slotPrice, real: tradePrice)
    }
}

