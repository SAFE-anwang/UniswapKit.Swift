import Foundation
import EvmKit
import BigInt

class AddLiquidityETHMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: AddLiquidityETHMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self])
        guard let token = parsedArguments[0] as? Address,
              let amountDesired = parsedArguments[1] as? BigUInt,
              let amountTokenMin = parsedArguments[2] as? BigUInt,
              let amountETHMin = parsedArguments[3] as? BigUInt,
              let to = parsedArguments[4] as? Address,
              let deadline = parsedArguments[5] as? BigUInt else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return AddLiquidityETHMethod(token: token, amountDesired: amountDesired, amountTokenMin: amountTokenMin, amountETHMin: amountETHMin, to: to, deadline: deadline)
    }

}
