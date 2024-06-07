
import EvmKit
import Eip20Kit
import BigInt

public class LiquidityV3Decoration: TransactionDecoration {
    public let tokenId: BigUInt
    public let amount0: Amount?
    public let amount1: Amount?
    public let recipient: Address?
    public let contractAddress: Address
    public let deadline: BigUInt?
    public let internalTransactions: [InternalTransaction]
    public let eventInstances: [ContractEventInstance]
    init(tokenId: BigUInt, amount0: Amount?, amount1: Amount?, recipient: Address?, contractAddress: Address, deadline: BigUInt?, internalTransactions: [InternalTransaction], eventInstances: [ContractEventInstance]) {
        self.tokenId = tokenId
        self.amount0 = amount0
        self.amount1 = amount1
        self.recipient = recipient
        self.contractAddress = contractAddress
        self.deadline = deadline
        self.internalTransactions = internalTransactions
        self.eventInstances = eventInstances
        super.init()
    }
    
    private func tag(token: Token, type: TransactionTag.TagType) -> TransactionTag {
        switch token {
        case .evmCoin: return TransactionTag(type: type, protocol: .native)
        case .eip20Coin(let tokenAddress, _): return TransactionTag(type: type, protocol: .eip20, contractAddress: tokenAddress)
        }
    }
}

extension LiquidityV3Decoration {

    public enum Amount {
        case exact(value: BigUInt)
        case extremum(value: BigUInt)
    }

    public enum Token {
        case evmCoin
        case eip20Coin(address: Address, tokenInfo: TokenInfo?)

        public var tokenInfo: TokenInfo? {
            switch self {
            case .eip20Coin(_, let tokenInfo): return tokenInfo
            default: return nil
            }
        }
    }

}
