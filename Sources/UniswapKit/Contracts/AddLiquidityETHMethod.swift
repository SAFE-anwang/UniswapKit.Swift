import Foundation
import EvmKit
import BigInt

class AddLiquidityETHMethod: ContractMethod {
    static let methodSignature = "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)"

    let token: Address
    let amountDesired: BigUInt
    let amountTokenMin: BigUInt
    let amountETHMin: BigUInt
    let to: Address
    let deadline: BigUInt

    init(token: Address, amountDesired: BigUInt, amountTokenMin: BigUInt, amountETHMin: BigUInt, to: Address, deadline: BigUInt) {
        self.token = token
        self.amountDesired = amountDesired
        self.amountTokenMin = amountTokenMin
        self.amountETHMin = amountETHMin
        self.to = to
        self.deadline = deadline

        super.init()
    }

    override var methodSignature: String { AddLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [token, amountDesired, amountTokenMin, amountETHMin, to, deadline]
    }

}
