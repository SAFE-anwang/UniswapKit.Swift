import BigInt
import Foundation

public class TradeDataV3 {
    let trade: TradeV3
    public let options: TradeOptions

    public init(trade: TradeV3, options: TradeOptions) {
        self.trade = trade
        self.options = options
    }

    var tokenAmountInMax: TokenAmount {
        let rawAmount = trade.tokenAmountIn.rawAmount
        let amountInMax: BigUInt
        if rawAmount == 0 {
            amountInMax = 0
        } else {
            amountInMax = ((Fraction(numerator: 1) + options.slippageFraction) * Fraction(numerator: rawAmount)).quotient
        }
        return TokenAmount(token: trade.tokenAmountIn.token, rawAmount: amountInMax)
    }
    
    var tokenAmountInMin: TokenAmount {
        let rawAmount = trade.tokenAmountIn.rawAmount
        let amountInMin: BigUInt
        if rawAmount == 0 {
            amountInMin = 0
        } else {
            amountInMin = ((Fraction(numerator: 1) + options.slippageFraction).inverted * Fraction(numerator: rawAmount)).quotient
        }
        return TokenAmount(token: trade.tokenAmountIn.token, rawAmount: amountInMin)
    }

    var tokenAmountOutMin: TokenAmount {
        let rawAmount = trade.tokenAmountOut.rawAmount
        let amountOutMin: BigUInt
        if rawAmount == 0 {
            amountOutMin = 0
        } else {
            amountOutMin = ((Fraction(numerator: 1) + options.slippageFraction).inverted * Fraction(numerator: rawAmount)).quotient
        }
        return TokenAmount(token: trade.tokenAmountOut.token, rawAmount: amountOutMin)
    }
}

extension TradeDataV3 {
    var isSingleSwap: Bool { trade.swapPath.isSingle }
    var singleSwapFee: KitV3.FeeAmount { trade.swapPath.firstFeeAmount }
}

public extension TradeDataV3 {
    var type: TradeType {
        trade.type
    }

    var amountIn: Decimal? {
        trade.tokenAmountIn.decimalAmount
    }

    var amountOut: Decimal? {
        trade.tokenAmountOut.decimalAmount
    }

    var amountInMax: Decimal? {
        tokenAmountInMax.decimalAmount
    }

    var amountOutMin: Decimal? {
        tokenAmountOutMin.decimalAmount
    }

    var executionPrice: Decimal? {
        trade.executionPrice.decimalValue
    }

    var executionPriceInverted: Decimal? {
        trade.executionPrice.invertedPrice.decimalValue
    }

    var priceImpact: Decimal? {
        trade.priceImpact
    }
    
    var fee: BigUInt {
        trade.swapPath.firstFeeAmount.rawValue
    }
}

public extension TradeDataV3 {
    
    var tickInfo: TickInfo? {
        trade.tickInfo
    }
}
