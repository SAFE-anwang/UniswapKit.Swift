import Foundation
import EvmKit
import BigInt

class PermitMethod: ContractMethod {
    private let spender: Address
    private let tokenId: BigUInt
    private let deadline: BigUInt
    private let v: BigUInt
    private let r: Data
    private let s: Data
    
    init(spender: Address, tokenId: BigUInt, deadline: BigUInt, v: BigUInt, r: Data, s: Data) {
        self.spender = spender
        self.tokenId = tokenId
        self.deadline = deadline
        self.v = v
        self.r = r
        self.s = s
    }

    override var methodSignature: String {
        "permit(address,uint256,uint256,,uint8,bytes32,bytes32)"
    }

    override var arguments: [Any] {
        [spender, tokenId, deadline, v, r, s]
    }
}
