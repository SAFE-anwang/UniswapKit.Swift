import EvmKit
import BigInt

class PositionsMethod: ContractMethod {
    static let methodSignature = "positions(uint256)"
    
    let tokenId: BigUInt
    
    init(tokenId: BigUInt) {
        self.tokenId = tokenId
        super.init()
    }

    override var methodSignature: String { PositionsMethod.methodSignature }

    override var arguments: [Any] {
        [tokenId]
    }
}
