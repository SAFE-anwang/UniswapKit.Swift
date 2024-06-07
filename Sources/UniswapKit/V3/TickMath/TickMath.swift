import BigInt
import EvmKit
import Foundation
import HsToolKit

class TickMath {
    
    static let MIN_TICK: BigInt = -887272
    static let MAX_TICK: BigInt = -MIN_TICK
    
    static let Q96: BigUInt = BigUInt(1) << 96 // Q64.96 "79228162514264337593543950336"
    static let MIN_SQRT_RATIO: BigUInt = BigUInt("4295128739")
    static let MAX_SQRT_RATIO: BigUInt = BigUInt("1461446703485210103287273052203988822378723970342")
    
    static func getSqrtRatioAtTick(tick: BigInt) throws -> BigUInt {
        guard tick >= MIN_TICK, tick <= MAX_TICK, let tickInt = Int(exactly: tick) else {
            throw NSError(domain: "Tick out of bounds", code: 0, userInfo: nil)
        }
        //  (1.0001)^tick
        let ratio = pow(1.0001, abs(tickInt))
                
        let Q96Decimal = Decimal(string: Q96.description)!
                
        let sqrtRatio = tick < 0 ? ratio.squareRoot().reciprocal * Q96Decimal : ratio.squareRoot() * Q96Decimal
        
        guard let sqrtRatioBigUInt = sqrtRatio.ceil()?.toBigUInt() else {
            throw NSError(domain: "Conversion to BigUInt failed", code: 0, userInfo: nil)
        }
        guard sqrtRatioBigUInt >= MIN_SQRT_RATIO, sqrtRatioBigUInt <= MAX_SQRT_RATIO else {
            throw NSError(domain: "SQRT_RATIO out of bounds", code: 0, userInfo: nil)
        }
        return sqrtRatioBigUInt
    }
    
    static func isInBounds(tick: BigInt) -> Bool {
        tick >= MIN_TICK && tick <= MAX_TICK
    }
    
    static func getTickAtSqrtRatio(sqrtPriceX96: BigUInt) throws -> BigInt {

        let base: Decimal = 1.0001
        
        let sqrtPrice = Decimal(string: sqrtPriceX96.description)! / Decimal(string: Q96.description)!
        
        guard let logValue = (2 * sqrtPrice.logarithm(base: base)).ceil() else {
            throw NSError(domain: "ceil failed", code: 0, userInfo: nil)
        }
        
        let intValue = NSDecimalNumber(decimal: logValue).intValue
        
        guard intValue >= MIN_TICK, intValue <= MAX_TICK else {
            throw NSError(domain: "Tick out of bounds", code: 0, userInfo: nil)
        }
        return BigInt(intValue)
    }
        
    static func encodeSqrtRatioX96(amount1: BigUInt, amount0: BigUInt) -> BigUInt? {
        let numerator = amount1 << 192
        let denominator = amount0
        let ratioX192 = numerator / denominator
        return ratioX192.squareRoot()
    }
    
    static func nearestUsableTick(tick: BigInt, tickSpacing: BigUInt) throws -> BigInt {
        
        if tick == MIN_TICK { return tick }
        if tick == MAX_TICK { return tick }
        
        guard tickSpacing > 0 else {
            throw NSError(domain: "Tick out of bounds", code: 0, userInfo: nil)
        }
        guard tick >= MIN_TICK, tick <= MAX_TICK else {
            throw NSError(domain: "Tick out of bounds", code: 0, userInfo: nil)
        }
        let rounded = tick / BigInt(tickSpacing) * BigInt(tickSpacing)
        
        if (rounded < MIN_TICK) {
            return rounded + BigInt(tickSpacing)
            
        } else if (rounded > MAX_TICK) {
            return rounded - BigInt(tickSpacing)
            
        } else {
            return rounded
        }
    }
}

extension Decimal {
    func squareRoot() -> Decimal {
        let nsDecimal = NSDecimalNumber(decimal: self)
        let doubleValue = nsDecimal.doubleValue
        let squareRootDouble = sqrt(doubleValue)
        return Decimal(squareRootDouble)
    }
    
    func ceil() -> Decimal? {
        let nsDecimal = NSDecimalNumber(decimal: self)
        let doubleValue = nsDecimal.doubleValue
        let ceilValue = Darwin.ceil(doubleValue)
        return Decimal(string: ceilValue.description)
    }
    
    func toBigUInt() -> BigUInt? {
        guard let ratioStr = "\(self)".split(separator: ".").first else {
            return nil
        }
        return BigUInt(ratioStr)
    }
    
    var reciprocal: Decimal {
        return 1 / self
    }
    
    func logarithm(base: Decimal) -> Decimal {
        let lnBase = NSDecimalNumber(decimal: base).doubleValue.logarithm()
        let lnValue = NSDecimalNumber(decimal: self).doubleValue.logarithm()
        return Decimal(string: "\(lnValue / lnBase)")!
    }
}

extension Double {
    func logarithm() -> Double {
        return log(self)
    }
}
