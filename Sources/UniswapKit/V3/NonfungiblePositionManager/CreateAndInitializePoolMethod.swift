import BigInt
import EvmKit
import Foundation

class CreateAndInitializePoolMethod: ContractMethod {
    static let methodSignature = "createAndInitializePoolIfNecessary(address,address,uint24,uint160)"

    let token0: Address
    let token1: Address
    let fee: BigUInt
    let sqrtPriceX96: BigUInt
    
    init(token0: Address, token1: Address, fee: BigUInt, sqrtPriceX96: BigUInt) {
        self.token0 = token0
        self.token1 = token1
        self.fee = fee
        self.sqrtPriceX96 = sqrtPriceX96
        
        super.init()
    }

    override var methodSignature: String { CreateAndInitializePoolMethod.methodSignature }

    override var arguments: [Any] {
        [token0, token1, fee, sqrtPriceX96]
    }
}

