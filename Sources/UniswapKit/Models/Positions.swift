import Foundation
import EvmKit
import BigInt

public struct Positions {
    public let tokenId: BigUInt
    public let nonce: BigUInt
    public let `operator`: Address
    public let token0: Address
    public let token1: Address
    public let fee: BigUInt
    public let tickLower: BigInt
    public let tickUpper: BigInt
    public let liquidity: BigUInt
    public let feeGrowthInside0LastX128: BigUInt
    public let feeGrowthInside1LastX128: BigUInt
    public let tokensOwed0: BigUInt
    public let tokensOwed1: BigUInt
    
    init?(data: Data, _tokenId: BigUInt) {
        guard data.count >= 384 else {
            return nil
        }
        tokenId = _tokenId
        nonce = BigUInt(data[0 ..< 32])
        `operator` = EvmKit.Address(raw: data[44 ..< 64])
        token0 = EvmKit.Address(raw: data[76 ..< 96])
        token1 = EvmKit.Address(raw: data[108 ..< 128])
        fee = BigUInt(data[128 ..< 160])
        tickLower = BigInt(data[160 ..< 192])
        tickUpper = BigInt(data[192 ..< 224])
        liquidity = BigUInt(data[224 ..< 256])
        feeGrowthInside0LastX128 = BigUInt(data[256 ..< 288])
        feeGrowthInside1LastX128 = BigUInt(data[288 ..< 320])
        tokensOwed0 = BigUInt(data[320 ..< 352])
        tokensOwed1 = BigUInt(data[352 ..< 384])
    }
}

