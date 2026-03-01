import BigInt
import EvmKit
import Foundation

class SweepTokenMethod: ContractMethod {
    static let methodSignature = "sweepToken(address,uint256,address)"

    let token: Address
    let amountMinimum: BigUInt
    let recipient: Address

    init(token: Address, amountMinimum: BigUInt, recipient: Address) {
        self.token = token
        self.amountMinimum = amountMinimum
        self.recipient = recipient

        super.init()
    }

    override var methodSignature: String { SweepTokenMethod.methodSignature }

    override var arguments: [Any] {
        [token, amountMinimum, recipient]
    }
}

