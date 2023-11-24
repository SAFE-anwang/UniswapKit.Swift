import EvmKit
import BigInt

class RemoveLiquidityETHMethod: ContractMethod {
    static let methodSignature = "removeLiquidity(address,uint256,uint256,uint256,address,uint256)"

    let token: Address
    let liquidity: BigUInt
    let amountTokenMin: BigUInt
    let amountETHMin: BigUInt
    let to: Address
    let deadline: BigUInt

    init(token: Address, liquidity: BigUInt, amountTokenMin: BigUInt, amountETHMin: BigUInt, to: Address, deadline: BigUInt) {
        self.token = token
        self.liquidity = liquidity
        self.amountTokenMin = amountTokenMin
        self.amountETHMin = amountETHMin
        self.to = to
        self.deadline = deadline

        super.init()
    }

    override var methodSignature: String { RemoveLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [token, liquidity, amountTokenMin, amountETHMin, to, deadline]
    }

}
