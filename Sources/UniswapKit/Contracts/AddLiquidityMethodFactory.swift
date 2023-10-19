import Foundation
import EvmKit
import BigInt

class AddLiquidityMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: AddLiquidityMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, Address.self, BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self])
        guard let tokenA = parsedArguments[0] as? Address,
              let tokenB = parsedArguments[1] as? Address,
              let amountADesired = parsedArguments[2] as? BigUInt,
              let amountBDesired = parsedArguments[3] as? BigUInt,
              let amountAMin = parsedArguments[4] as? BigUInt,
              let amountBMin = parsedArguments[5] as? BigUInt,
              let to = parsedArguments[6] as? Address,
              let deadline = parsedArguments[7] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return AddLiquidityMethod(tokenA: tokenA, tokenB: tokenB, amountADesired: amountADesired, amountBDesired: amountBDesired, amountAMin: amountAMin, amountBMin: amountBMin, to: to, deadline: deadline)
    }

}
