import BigInt
import EvmKit
import Foundation

class LiquidityMethod: ContractMethod {
    static let methodSignature = "liquidity()"

    override var methodSignature: String { LiquidityMethod.methodSignature }

    override var arguments: [Any] {
        []
    }
}
