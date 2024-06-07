import Alamofire
import BigInt
import EvmKit
import Foundation
import HsToolKit

class LiquidityAmounts {
    struct FixedPoint96 {
        static let RESOLUTION: BigUInt = 96
        static let Q96 = BigUInt("1000000000000000000000000", radix: 16)!
    }
    
    static func getLiquidityForAmount0(sqrtRatioAX96: BigUInt, sqrtRatioBX96: BigUInt, amount0: BigUInt) -> BigUInt? {

        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 > sqrtRatioBX96 ? (sqrtRatioBX96, sqrtRatioAX96) : (sqrtRatioAX96, sqrtRatioBX96)

        guard sqrtRatioLower > 0 && sqrtRatioUpper > sqrtRatioLower else { return nil }

        let numerator = amount0 * ((sqrtRatioLower * sqrtRatioUpper) / FixedPoint96.Q96)
        let denominator = sqrtRatioUpper - sqrtRatioLower
        guard denominator != 0 else { return nil }

        let liquidity = numerator / denominator

        return liquidity
    }
    
    static func getLiquidityForAmount1(sqrtRatioAX96: BigUInt, sqrtRatioBX96: BigUInt, amount1: BigUInt) -> BigUInt? {
        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 > sqrtRatioBX96 ? (sqrtRatioBX96, sqrtRatioAX96) : (sqrtRatioAX96, sqrtRatioBX96)

        guard sqrtRatioLower > 0 && sqrtRatioUpper > sqrtRatioLower else { return nil }

        let numerator = amount1 * FixedPoint96.Q96
        let denominator = sqrtRatioUpper - sqrtRatioLower
        
        guard denominator != 0 else { return nil }
        
        let liquidity = numerator / denominator

        return liquidity
    }
    
    static func getAmount0ForLiquidity(sqrtRatioAX96: BigUInt, sqrtRatioBX96: BigUInt, liquidity: BigUInt) -> BigUInt? {
        
        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 < sqrtRatioBX96 ? (sqrtRatioAX96, sqrtRatioBX96) : (sqrtRatioBX96, sqrtRatioAX96)
        
        guard sqrtRatioLower > 0 && sqrtRatioUpper > sqrtRatioLower else { return nil }
        
        let numerator = (liquidity << FixedPoint96.RESOLUTION) * (sqrtRatioUpper - sqrtRatioLower) / sqrtRatioUpper
        let denominator =  sqrtRatioLower
        let amount1BigInt = numerator / denominator

        return amount1BigInt
    }
    
    static func getAmount1ForLiquidity(sqrtRatioAX96: BigUInt, sqrtRatioBX96: BigUInt, liquidity: BigUInt) -> BigUInt? {
        
        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 > sqrtRatioBX96 ? (sqrtRatioBX96, sqrtRatioAX96) : (sqrtRatioAX96, sqrtRatioBX96)
        
        guard sqrtRatioLower > 0 && sqrtRatioUpper > sqrtRatioLower else { return nil }
        
        let numerator = liquidity * (sqrtRatioUpper - sqrtRatioLower)
        let denominator = FixedPoint96.Q96
        let amount1BigInt = numerator / denominator

        return amount1BigInt
    }

    static func getLiquidityForAmounts(
        sqrtRatioX96: BigUInt,
        sqrtRatioAX96: BigUInt,
        sqrtRatioBX96: BigUInt,
        amount0: BigUInt,
        amount1: BigUInt
    ) -> BigUInt? {
        
        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 > sqrtRatioBX96 ? (sqrtRatioBX96, sqrtRatioAX96) : (sqrtRatioAX96, sqrtRatioBX96)

        guard sqrtRatioLower > 0 && sqrtRatioUpper > sqrtRatioLower else { return nil }

        var liquidity: BigUInt?

        if sqrtRatioX96 <= sqrtRatioLower {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioUpper, amount0: amount0)
        } else if sqrtRatioX96 < sqrtRatioUpper {
            guard let liquidity0 = getLiquidityForAmount0(sqrtRatioAX96: sqrtRatioX96, sqrtRatioBX96: sqrtRatioUpper, amount0: amount0),
                  let liquidity1 = getLiquidityForAmount1(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioX96, amount1: amount1) else { return nil }

            liquidity = min(liquidity0, liquidity1)
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioUpper, amount1: amount1)
        }
        return liquidity
    }
    
    static func getAmountsForLiquidity(
        liquidity: BigUInt,
        sqrtRatioX96: BigUInt,
        sqrtRatioAX96: BigUInt,
        sqrtRatioBX96: BigUInt
    ) -> (BigUInt, BigUInt)? {
        
        let (sqrtRatioLower, sqrtRatioUpper) = sqrtRatioAX96 > sqrtRatioBX96 ? (sqrtRatioBX96, sqrtRatioAX96) : (sqrtRatioAX96, sqrtRatioBX96)

        if sqrtRatioX96 <= sqrtRatioLower {
            guard let amount0 = getAmount0ForLiquidity(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioUpper, liquidity: liquidity) else { return nil }
            return (amount0, 0)
            
        } else if sqrtRatioX96 < sqrtRatioUpper {
            guard let amount0 = getAmount0ForLiquidity(sqrtRatioAX96: sqrtRatioX96, sqrtRatioBX96: sqrtRatioUpper, liquidity: liquidity),
                  let amount1 = getAmount1ForLiquidity(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioX96, liquidity: liquidity) else {
                return nil
            }
            return (amount0,amount1)
            
        } else {
            guard let amount1 = getAmount1ForLiquidity(sqrtRatioAX96: sqrtRatioLower, sqrtRatioBX96: sqrtRatioUpper, liquidity: liquidity) else { return nil }
            return (0,amount1)
        }
    }
}
