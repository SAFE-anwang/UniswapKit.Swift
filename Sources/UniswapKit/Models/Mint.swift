import Foundation
import EvmKit
import BigInt

public struct MintInputs {
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
    
    init(token0: Address, token1: Address, fee: BigUInt, tickLower: BigInt, tickUpper: BigInt, amount0Desired: BigUInt, amount1Desired: BigUInt, amount0Min: BigUInt, amount1Min: BigUInt, recipient: Address, deadline: BigUInt) {
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
    }
}

public struct MintOutputs {
    public let tokenId: BigUInt
    public let liquidity: BigUInt
    public let amount0: BigUInt
    public let amount1: BigUInt
    
    init?(data: Data) {
        guard data.count >= 128 else {
            return nil
        }
        tokenId = BigUInt(data[0 ..< 32])
        liquidity = BigUInt(data[32 ..< 64])
        amount0 = BigUInt(data[64 ..< 96])
        amount1 = BigUInt(data[96 ..< 128])
    }
}
