import Foundation
import BigInt
import EvmKit

public class SafeSwapConfig {
    public static let wethAddressHex = "0x0000000000000000000000000000000000001101"
    public static let safeSwapv2Safe4Router = "0x6476008C612dF9F8Db166844fFE39D24aEa12271"
    public static let safeSwapv2Safe4CodeHash = "ad0e51aa7a058efb9eb40fd6385473f0175ee7419e8d4f91a4e0294ec12b2d13"
    public static let safeSwapv2Safe4Factory = "0xB3c827077312163c53E3822defE32cAffE574B42"
    
    static let safeSwapv2Safe4Router_test = "0x6476008C612dF9F8Db166844fFE39D24aEa12271"
    static let safeSwapv2Safe4CodeHash_test = "ad0e51aa7a058efb9eb40fd6385473f0175ee7419e8d4f91a4e0294ec12b2d13"
    static let safeSwapv2Safe4Factory_test = "0xB3c827077312163c53E3822defE32cAffE574B42"
    
    public static func routerAddress(chain: Chain) throws -> Address {
        switch chain {
        case .ethereum, .ethereumGoerli: return try Address(hex: "0x6476008C612dF9F8Db166844fFE39D24aEa12271")
        case .binanceSmartChain: return try Address(hex: "0x6476008C612dF9F8Db166844fFE39D24aEa12271")
        case .polygon: return try Address(hex: "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff")
        case .avalanche: return try Address(hex: "0x60aE616a2155Ee3d9A68541Ba4544862310933d4")
        case .base: return try Address(hex: "0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24")
        case .SafeFour: return try Address(hex: safeSwapv2Safe4Router)
        case .SafeFourTestNet: return try Address(hex: safeSwapv2Safe4Router_test)
        default: throw TradeManager.UnsupportedChainError.noRouterAddress
        }
     }

    public static func factoryAddressString(chain: Chain) throws -> String {
         switch chain {
         case .ethereum, .ethereumGoerli: return "0xB3c827077312163c53E3822defE32cAffE574B42"
         case .binanceSmartChain: return "0xB3c827077312163c53E3822defE32cAffE574B42"
         case .polygon: return "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32"
         case .avalanche: return "0x9Ad6C38BE94206cA50bb0d90783181662f0Cfa10"
         case .base: return "0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6"
         case .SafeFour: return safeSwapv2Safe4Factory
         case .SafeFourTestNet: return safeSwapv2Safe4Factory_test
         default: throw TradeManager.UnsupportedChainError.noFactoryAddress
         }
     }

    public static func initCodeHashString(chain: Chain) throws -> String {
         switch chain {
         case .ethereum, .ethereumGoerli, .polygon, .avalanche, .base: return "0xad0e51aa7a058efb9eb40fd6385473f0175ee7419e8d4f91a4e0294ec12b2d13"
         case .binanceSmartChain: return "0xad0e51aa7a058efb9eb40fd6385473f0175ee7419e8d4f91a4e0294ec12b2d13"
         case .SafeFour: return safeSwapv2Safe4CodeHash
         case .SafeFourTestNet: return safeSwapv2Safe4CodeHash_test
         default: throw TradeManager.UnsupportedChainError.noInitCodeHash
         }
     }
}
