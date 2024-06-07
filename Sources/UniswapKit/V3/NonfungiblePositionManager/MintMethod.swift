import EvmKit
import Foundation
import BigInt

class MintMethod: ContractMethod {
    static let methodSignature = "mint((address,address,uint24,int24,int24,uint256,uint256,uint256,uint256,address,uint256))"
    let token0: Address
    let token1: Address
    let fee: BigUInt
    let tickLower: BigInt
    let tickUpper: BigInt
    let amount0Desired: BigUInt
    let amount1Desired: BigUInt
    let amount0Min: BigUInt
    let amount1Min: BigUInt
    let recipient: Address
    let deadline: BigUInt
    
    init(token0: Address, token1: Address, fee: BigUInt, tickLower: BigInt,tickUpper: BigInt, amount0Desired: BigUInt, amount1Desired: BigUInt, amount0Min: BigUInt, amount1Min: BigUInt, recipient: Address, deadline: BigUInt) {
        self.token0 = token0
        self.token1 = token1
        self.fee = fee
        self.tickLower = tickLower
        self.tickUpper = tickUpper
        self.amount0Desired = amount0Desired
        self.amount1Desired = amount1Desired
        self.amount0Min = amount0Min
        self.amount1Min = amount1Min
        self.recipient = recipient
        self.deadline = deadline
        super.init()
    }

    override var methodSignature: String { MintMethod.methodSignature }

    override var arguments: [Any] {
        [token0, token1, fee, tickLower, tickUpper, amount0Desired, amount1Desired, amount0Min, amount1Min, recipient, deadline]
    }
    
}

extension ContractMethod {
    
    func encodedABI_fix() -> Data {
        ContractMethodHelper_fix.encodedABI(methodId: methodId, arguments: arguments)
    }
}
