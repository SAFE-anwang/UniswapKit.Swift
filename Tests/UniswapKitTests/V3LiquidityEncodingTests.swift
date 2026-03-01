import BigInt
import EvmKit
import XCTest

@testable import UniswapKit

final class V3LiquidityEncodingTests: XCTestCase {
    func testMulticall_EncodesAndDecodesInnerMint() throws {
        let token0 = try Address(hex: "0x0000000000000000000000000000000000000001")
        let token1 = try Address(hex: "0x0000000000000000000000000000000000000002")
        let recipient = try Address(hex: "0x000000000000000000000000000000000000dEaD")

        let mint = MintMethod(
            token0: token0,
            token1: token1,
            fee: 3000,
            tickLower: BigInt(-100),
            tickUpper: BigInt(100),
            amount0Desired: 1,
            amount1Desired: 2,
            amount0Min: 1,
            amount1Min: 2,
            recipient: recipient,
            deadline: 123
        )

        let multicall = MulticallMethod(methods: [mint])
        let encoded = multicall.encodedABI_fix()
        XCTAssertEqual(encoded.prefix(4), ContractMethodHelper_fix.methodId(signature: MulticallMethod.methodSignature))
        XCTAssertEqual((encoded.count - 4) % 32, 0)

        let decoded = ContractMethodHelper_fix.decodeABI(
            inputArguments: Data(encoded.dropFirst(4)),
            argumentTypes: [ContractMethodHelper_fix.MulticallParameters.self]
        )
        let methodArray = try XCTUnwrap(decoded.first as? [Data])
        XCTAssertEqual(methodArray.count, 1)
        XCTAssertEqual(methodArray[0], mint.encodedABI_fix())
    }
}

