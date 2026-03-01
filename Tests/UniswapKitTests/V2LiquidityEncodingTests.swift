import BigInt
import EvmKit
import XCTest

@testable import UniswapKit

final class V2LiquidityEncodingTests: XCTestCase {
    func testAddLiquidityETH_UsesCorrectSelectorValueAndMinAmounts() throws {
        let weth = try Address(hex: "0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2")
        let dai = try Address(hex: "0x6B175474E89094C44Da98b954EedeAC495271d0F")
        let recipient = try Address(hex: "0x000000000000000000000000000000000000dEaD")

        let eth = Token.eth(wethAddress: weth)
        let token = Token.erc20(address: dai, decimals: 18)

        let e18 = BigUInt(10).power(18)
        let pair = Pair(
            reserve0: TokenAmount(token: eth, rawAmount: 1_000 * e18),
            reserve1: TokenAmount(token: token, rawAmount: 1_000 * e18)
        )

        let route = try Route(pairs: [pair], tokenIn: eth, tokenOut: token)
        let ethIn = TokenAmount(token: eth, rawAmount: 1 * e18)
        let tokenOut = TokenAmount(token: token, rawAmount: 900 * BigUInt(10).power(15))
        let trade = Trade(type: .exactIn, route: route, tokenAmountIn: ethIn, tokenAmountOut: tokenOut)

        let options = TradeOptions(allowedSlippage: 1, ttl: TradeOptions.defaultTtl, recipient: nil, feeOnTransfer: false)
        let tradeData = TradeData(trade: trade, options: options)

        let tradeManager = try TradeManager(networkManager: NetworkManager(), isSafeSwap: false)
        let tx = try tradeManager.transactionLiquidityData(tradeData: tradeData, type: .add, chain: .ethereum, recipient: recipient)

        XCTAssertEqual(tx.value, ethIn.rawAmount)
        XCTAssertEqual(tx.input.prefix(4), ContractMethodHelper.methodId(signature: AddLiquidityETHMethod.methodSignature))

        let decoded = try AddLiquidityETHMethodFactory().createMethod(inputArguments: Data(tx.input.dropFirst(4)))
        let method = try XCTUnwrap(decoded as? AddLiquidityETHMethod)

        XCTAssertEqual(method.token, dai)
        XCTAssertEqual(method.amountDesired, tokenOut.rawAmount)
        XCTAssertEqual(method.amountTokenMin, tokenOut.rawAmount * 995 / 1000)
        XCTAssertEqual(method.amountETHMin, ethIn.rawAmount * 995 / 1000)
        XCTAssertEqual(method.to, recipient)
    }

    func testAddLiquidity_UsesZeroValueAndMinAmounts() throws {
        let tokenAAddress = try Address(hex: "0x0000000000000000000000000000000000000001")
        let tokenBAddress = try Address(hex: "0x0000000000000000000000000000000000000002")
        let recipient = try Address(hex: "0x000000000000000000000000000000000000dEaD")

        let tokenA = Token.erc20(address: tokenAAddress, decimals: 18)
        let tokenB = Token.erc20(address: tokenBAddress, decimals: 18)

        let e18 = BigUInt(10).power(18)
        let pair = Pair(
            reserve0: TokenAmount(token: tokenA, rawAmount: 1_000 * e18),
            reserve1: TokenAmount(token: tokenB, rawAmount: 1_000 * e18)
        )

        let route = try Route(pairs: [pair], tokenIn: tokenA, tokenOut: tokenB)
        let amountIn = TokenAmount(token: tokenA, rawAmount: 1 * e18)
        let amountOut = TokenAmount(token: tokenB, rawAmount: 900 * BigUInt(10).power(15))
        let trade = Trade(type: .exactIn, route: route, tokenAmountIn: amountIn, tokenAmountOut: amountOut)

        let options = TradeOptions(allowedSlippage: 1, ttl: TradeOptions.defaultTtl, recipient: nil, feeOnTransfer: false)
        let tradeData = TradeData(trade: trade, options: options)

        let tradeManager = try TradeManager(networkManager: NetworkManager(), isSafeSwap: false)
        let tx = try tradeManager.transactionLiquidityData(tradeData: tradeData, type: .add, chain: .ethereum, recipient: recipient)

        XCTAssertEqual(tx.value, 0)
        XCTAssertEqual(tx.input.prefix(4), ContractMethodHelper.methodId(signature: AddLiquidityMethod.methodSignature))

        let decoded = try AddLiquidityMethodFactory().createMethod(inputArguments: Data(tx.input.dropFirst(4)))
        let method = try XCTUnwrap(decoded as? AddLiquidityMethod)

        XCTAssertEqual(method.tokenA, tokenAAddress)
        XCTAssertEqual(method.tokenB, tokenBAddress)
        XCTAssertEqual(method.amountADesired, amountIn.rawAmount)
        XCTAssertEqual(method.amountBDesired, amountOut.rawAmount)
        XCTAssertEqual(method.amountAMin, amountIn.rawAmount * 995 / 1000)
        XCTAssertEqual(method.amountBMin, amountOut.rawAmount * 995 / 1000)
        XCTAssertEqual(method.to, recipient)
    }

    func testRemoveLiquidityETH_UsesCorrectSelectorAndZeroValue() throws {
        let weth = try Address(hex: "0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2")
        let dai = try Address(hex: "0x6B175474E89094C44Da98b954EedeAC495271d0F")
        let recipient = try Address(hex: "0x000000000000000000000000000000000000dEaD")

        let eth = Token.eth(wethAddress: weth)
        let token = Token.erc20(address: dai, decimals: 18)

        let e18 = BigUInt(10).power(18)
        let pair = Pair(
            reserve0: TokenAmount(token: eth, rawAmount: 1_000 * e18),
            reserve1: TokenAmount(token: token, rawAmount: 1_000 * e18)
        )

        let route = try Route(pairs: [pair], tokenIn: eth, tokenOut: token)
        let ethExpected = TokenAmount(token: eth, rawAmount: 1 * e18)
        let tokenExpected = TokenAmount(token: token, rawAmount: 900 * BigUInt(10).power(15))
        let trade = Trade(type: .exactIn, route: route, tokenAmountIn: ethExpected, tokenAmountOut: tokenExpected)

        let options = TradeOptions(allowedSlippage: 1, ttl: TradeOptions.defaultTtl, recipient: nil, feeOnTransfer: false)
        let tradeData = TradeData(trade: trade, options: options)

        let tradeManager = try TradeManager(networkManager: NetworkManager(), isSafeSwap: false)
        let tx = try tradeManager.transactionLiquidityData(tradeData: tradeData, type: .remove(liquidity: 123), chain: .ethereum, recipient: recipient)

        XCTAssertEqual(tx.value, 0)
        XCTAssertEqual(tx.input.prefix(4), ContractMethodHelper.methodId(signature: RemoveLiquidityETHMethod.methodSignature))

        let decoded = try RemoveLiquidityETHMethodFactory().createMethod(inputArguments: Data(tx.input.dropFirst(4)))
        let method = try XCTUnwrap(decoded as? RemoveLiquidityETHMethod)

        XCTAssertEqual(method.token, dai)
        XCTAssertEqual(method.liquidity, 123)
        XCTAssertEqual(method.amountTokenMin, tokenExpected.rawAmount * 995 / 1000)
        XCTAssertEqual(method.amountETHMin, ethExpected.rawAmount * 995 / 1000)
        XCTAssertEqual(method.to, recipient)
    }
}
