import EvmKit
import Eip20Kit
import BigInt

public class LiquidityDecoration: TransactionDecoration {
    public let contractAddress: Address
    public let amountInA: Amount
    public let amountInB: Amount
    public let tokenInA: Token
    public let tokenInB: Token
    public let recipient: Address?
    public let deadline: BigUInt?
    public let internalTransactions: [InternalTransaction]
    public let eventInstances: [ContractEventInstance]

    public init(contractAddress: Address, amountInA: Amount, amountInB: Amount, tokenInA: Token, tokenInB: Token, recipient: Address?, deadline: BigUInt?, internalTransactions: [InternalTransaction],  eventInstances: [ContractEventInstance]) {
        self.contractAddress = contractAddress
        self.amountInA = amountInA
        self.amountInB = amountInB
        self.tokenInA = tokenInA
        self.tokenInB = tokenInB
        self.recipient = recipient
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

    public override func tags() -> [TransactionTag] {
        var tags = [
            tag(token: tokenInA, type: .swap),
            tag(token: tokenInB, type: .swap),
//            tag(token: tokenOut, type: .swap),
            tag(token: tokenInA, type: .outgoing),
            tag(token: tokenInB, type: .outgoing)
        ]

        if recipient == nil {
//            tags.append(tag(token: tokenOut, type: .incoming))
        }

        return tags
    }

}

extension LiquidityDecoration {

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

