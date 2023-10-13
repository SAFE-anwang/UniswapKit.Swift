import EvmKit
import BigInt

class RemoveLiquidityMethod: ContractMethod {
    static let methodSignature = "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)"

    let tokenA: Address
    let tokenB: Address
    let liquidity: BigUInt
    let amountAMin: BigUInt
    let amountBMin: BigUInt
    let to: Address
    let deadline: BigUInt

    init(tokenA: Address, tokenB: Address, liquidity: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, to: Address, deadline: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.liquidity = liquidity
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.to = to
        self.deadline = deadline

        super.init()
    }

    override var methodSignature: String { RemoveLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline]
    }

}
