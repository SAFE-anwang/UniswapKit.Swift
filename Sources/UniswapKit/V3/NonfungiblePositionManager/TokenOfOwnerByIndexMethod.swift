import EvmKit
import BigInt

class TokenOfOwnerByIndexMethod: ContractMethod {
    static let methodSignature = "tokenOfOwnerByIndex(address,uint256)"
    
    let owner: Address
    let index: BigUInt
    
    init(owner: Address, index: BigUInt) {
        self.owner = owner
        self.index = index

        super.init()
    }

    override var methodSignature: String { TokenOfOwnerByIndexMethod.methodSignature }

    override var arguments: [Any] {
        [owner, index]
    }
}
