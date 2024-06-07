import EvmKit
import BigInt

class IncreaseLiquidityMethod: ContractMethod {
    
    static let methodSignature = "increaseLiquidity((uint256,uint256,uint256,uint256,uint256,uint256))"
    let tokenId: BigUInt
    let amount0Desired: BigUInt
    let amount1Desired: BigUInt
    let amount0Min: BigUInt
    let amount1Min: BigUInt
    let deadline: BigUInt
    
    init(tokenId: BigUInt, amount0Desired: BigUInt, amount1Desired: BigUInt, amount0Min: BigUInt, amount1Min: BigUInt, deadline: BigUInt) {
        self.tokenId = tokenId
        self.amount0Desired = amount0Desired
        self.amount1Desired = amount1Desired
        self.amount0Min = amount0Min
        self.amount1Min = amount1Min
        self.deadline = deadline
        super.init()
    }

    override var methodSignature: String { IncreaseLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [tokenId, amount0Desired, amount1Desired, amount0Min, amount1Min, deadline]
    }
}

