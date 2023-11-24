import Foundation
import EvmKit
import BigInt

class RemoveLiquidityETHMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: RemoveLiquidityETHMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self])
        guard let token = parsedArguments[0] as? Address,
              let liquidity = parsedArguments[1] as? BigUInt,
              let amountTokenMin = parsedArguments[3] as? BigUInt,
              let amountETHMin = parsedArguments[4] as? BigUInt,
              let to = parsedArguments[5] as? Address,
              let deadline = parsedArguments[6] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return RemoveLiquidityETHMethod(token: token, liquidity: liquidity, amountTokenMin: amountTokenMin, amountETHMin: amountETHMin, to: to, deadline: deadline)
    }

}
