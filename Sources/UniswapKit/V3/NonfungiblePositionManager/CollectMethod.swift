import Foundation
import EvmKit
import BigInt

class CollectMethod: ContractMethod {
    
    private let tokenId: BigUInt
    private let recipient: Address
    private let amount0Max: BigUInt
    private let amount1Max: BigUInt
    
    init(tokenId: BigUInt, recipient: Address, amount0Max: BigUInt, amount1Max: BigUInt) {
        self.tokenId = tokenId
        self.recipient = recipient
        self.amount0Max = amount0Max
        self.amount1Max = amount1Max
    }

    override var methodSignature: String {
        "collect((uint256,address,uint128,uint128))"
    }

    override var arguments: [Any] {
        [tokenId, recipient, amount0Max, amount1Max]
    }
}
