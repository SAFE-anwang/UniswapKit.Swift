import Foundation
import EvmKit
import BigInt

class PermitMethod: ContractMethod {
    private let spender: Address
    private let tokenId: BigUInt
    private let deadline: BigUInt
    private let v: BigUInt
    private let r: Data32
    private let s: Data32
    
    init(spender: Address, tokenId: BigUInt, deadline: BigUInt, v: BigUInt, r: Data, s: Data) {
        self.spender = spender
        self.tokenId = tokenId
        self.deadline = deadline
        self.v = v
        self.r = Data32(data: r)
        self.s = Data32(data: s)
        super.init()
    }

    override var methodSignature: String {
        "permit(address,uint256,uint256,uint8,bytes32,bytes32)"
    }

    override var arguments: [Any] {
        [spender, tokenId, deadline, v, r, s]
    }
}
