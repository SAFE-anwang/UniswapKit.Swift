import EvmKit
import BigInt

class DecreaseLiquidityMethod: ContractMethod {
    static let methodSignature = "decreaseLiquidity((uint256,uint128,uint256,uint256,uint256))"
    
    let tokenId: BigUInt
    let liquidity: BigUInt
    let amount0Min: BigUInt
    let amount1Min: BigUInt
    let deadline: BigUInt
    
    init(tokenId: BigUInt, liquidity: BigUInt, amount0Min: BigUInt, amount1Min: BigUInt, deadline: BigUInt) {
        self.tokenId = tokenId
        self.liquidity = liquidity
        self.amount0Min = amount0Min
        self.amount1Min = amount1Min
        self.deadline = deadline
        super.init()
    }

    override var methodSignature: String { DecreaseLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [tokenId, liquidity, amount0Min, amount1Min, deadline]
    }
}
