import Foundation
import EvmKit
import BigInt

class RemoveLiquidityMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: RemoveLiquidityMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, Address.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self])
        guard let tokenA = parsedArguments[0] as? Address,
              let tokenB = parsedArguments[1] as? Address,
              let liquidity = parsedArguments[2] as? BigUInt,
              let amountAMin = parsedArguments[3] as? BigUInt,
              let amountBMin = parsedArguments[4] as? BigUInt,
              let to = parsedArguments[5] as? Address,
              let deadline = parsedArguments[6] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return RemoveLiquidityMethod(tokenA: tokenA, tokenB: tokenB, liquidity: liquidity, amountAMin: amountAMin, amountBMin: amountBMin, to: to, deadline: deadline)
    }

}

class RemoveLiquidityWithPermitMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: RemoveLiquidityWithPermitMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, Address.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self, String.self, BigUInt.self, BigUInt.self, BigUInt.self])
        guard let tokenA = parsedArguments[0] as? Address,
              let tokenB = parsedArguments[1] as? Address,
              let liquidity = parsedArguments[2] as? BigUInt,
              let amountAMin = parsedArguments[3] as? BigUInt,
              let amountBMin = parsedArguments[4] as? BigUInt,
              let to = parsedArguments[5] as? Address,
              let deadline = parsedArguments[6] as? BigUInt,
              let approveMax = parsedArguments[6] as? String,
              let v = parsedArguments[7] as? BigUInt,
              let r = parsedArguments[8] as? BigUInt,
              let s = parsedArguments[9] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return RemoveLiquidityWithPermitMethod(tokenA: tokenA, tokenB: tokenB, liquidity: liquidity, amountAMin: amountAMin, amountBMin: amountBMin, to: to, deadline: deadline, approveMax: approveMax == "0" ? false : true, v: v, r: r, s: s)
    }

}

