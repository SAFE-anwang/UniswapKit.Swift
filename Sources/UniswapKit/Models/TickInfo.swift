import BigInt
import Foundation

public struct TickInfo {
    
    public let tickLower: BigInt
    public let tickUpper: BigInt
    public let tickLowerSqrtPriceX96: BigUInt?
    public let tickUpperSqrtPriceX96: BigUInt?
    public let tickLowerPrice: Decimal?
    public let tickUpperPrice: Decimal?
    public let tickcurrentPrice: Decimal?
    public let tickSpacing: BigUInt
    public let slot0: Slot0
    
    init(tickLower: BigInt, tickUpper: BigInt, tickLowerSqrtPriceX96: BigUInt?, tickUpperSqrtPriceX96: BigUInt?, tickLowerPrice: Decimal?, tickUpperPrice: Decimal?, tickcurrentPrice: Decimal?, tickSpacing: BigUInt, slot0: Slot0) {
        self.tickLower = tickLower
        self.tickUpper = tickUpper
        self.tickLowerSqrtPriceX96 = tickLowerSqrtPriceX96
        self.tickUpperSqrtPriceX96 = tickUpperSqrtPriceX96
        self.tickLowerPrice = tickLowerPrice
        self.tickUpperPrice = tickUpperPrice
        self.tickcurrentPrice = tickcurrentPrice
        self.tickSpacing = tickSpacing
        self.slot0 = slot0
    }
    
    public var tickCurrent: BigInt {
        slot0.tick
    }
    
    public var isMinTick: Bool {
        tickLower == TickMath.MIN_TICK
    }
    
    public var isMaxTick: Bool {
        tickUpper == TickMath.MAX_TICK
    }
}
