import Foundation
import EvmKit
import BigInt

class AddLiquidityMethod: ContractMethod {
    static let methodSignature = "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)"

    let tokenA: Address
    let tokenB: Address
    let amountADesired: BigUInt
    let amountBDesired: BigUInt
    let amountAMin: BigUInt
    let amountBMin: BigUInt
    let to: Address
    let deadline: BigUInt

    init(tokenA: Address, tokenB: Address, amountADesired: BigUInt, amountBDesired: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, to: Address, deadline: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.amountADesired = amountADesired
        self.amountBDesired = amountBDesired
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.to = to
        self.deadline = deadline

        super.init()
    }

    override var methodSignature: String { AddLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline]
    }

}

