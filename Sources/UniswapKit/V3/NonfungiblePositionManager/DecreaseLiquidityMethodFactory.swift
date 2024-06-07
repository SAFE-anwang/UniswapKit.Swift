import Foundation
import EvmKit
import BigInt

class DecreaseLiquidityMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: DecreaseLiquidityMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self])
        guard let tokenId = parsedArguments[0] as? BigUInt,
              let liquidity = parsedArguments[1] as? BigUInt,
              let amount0Min = parsedArguments[2] as? BigUInt,
              let amount1Min = parsedArguments[3] as? BigUInt,
              let deadline = parsedArguments[4] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return DecreaseLiquidityMethod(tokenId: tokenId, liquidity: liquidity, amount0Min: amount0Min, amount1Min: amount1Min, deadline: deadline)
    }
}
