import EvmKit
import Eip20Kit
import BigInt

public class RemoveLiquidityDecoration: TransactionDecoration {
    public let tokenA: Token
    public let tokenB: Token
    public let liquidity: BigUInt
    public let amountAMin: Amount
    public let amountBMin: Amount
    public let to: Address?
    public let deadline: BigUInt?
    public let internalTransactions: [InternalTransaction]
    public let eventInstances: [ContractEventInstance]

    public init(amountAMin: Amount, amountBMin: Amount, tokenA: Token, tokenB: Token, liquidity: BigUInt, to: Address?, deadline: BigUInt?, internalTransactions: [InternalTransaction],  eventInstances: [ContractEventInstance]) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.liquidity = liquidity
        self.to = to
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
        let tags = [
            tag(token: tokenA, type: .incoming),
            tag(token: tokenB, type: .incoming),
        ]

        return tags
    }

}

extension RemoveLiquidityDecoration {

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
