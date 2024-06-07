import Foundation
import EvmKit
import BigInt

class IncreaseLiquidityMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: IncreaseLiquidityMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self])
        guard let tokenId = parsedArguments[0] as? BigUInt,
              let amount0Desired = parsedArguments[1] as? BigUInt,
              let amount1Desired = parsedArguments[2] as? BigUInt,
              let amount0Min = parsedArguments[3] as? BigUInt,
              let amount1Min = parsedArguments[4] as? BigUInt,
              let deadline = parsedArguments[5] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return IncreaseLiquidityMethod(tokenId: tokenId, amount0Desired: amount0Desired, amount1Desired: amount1Desired, amount0Min: amount0Min, amount1Min: amount1Min, deadline: deadline)
    }
}
