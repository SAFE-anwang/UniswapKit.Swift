import Foundation
import EvmKit
import BigInt

class TotalSupplyMethod: ContractMethod {

    override init() {}

    override var methodSignature: String {
        "totalSupply()"
    }

    override var arguments: [Any] {
        []
    }
}
