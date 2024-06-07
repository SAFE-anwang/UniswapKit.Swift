import BigInt

public struct DecreaseLiquidityInfo {
    
    public let slot0: Slot0
    public let positions: Positions
    
    public let amount0: BigUInt
    public let amount1: BigUInt
    
    public var isInRange: Bool {
        positions.tickLower < positions.tickUpper && (positions.tickLower ... positions.tickUpper).contains(slot0.tick)
    }
}
