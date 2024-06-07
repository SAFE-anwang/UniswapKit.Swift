import Foundation
import EvmKit
import BigInt

class MintMethodFactory: IContractMethodFactory {
    let methodId: Data = ContractMethodHelper.methodId(signature: MintMethod.methodSignature)

    func createMethod(inputArguments: Data) throws -> ContractMethod {
        let parsedArguments = ContractMethodHelper_fix.decodeABI(inputArguments: inputArguments, argumentTypes: [Address.self, Address.self, BigUInt.self, BigInt.self, BigInt.self, BigUInt.self, BigUInt.self, BigUInt.self, BigUInt.self, Address.self, BigUInt.self])
        
        guard let token0 = parsedArguments[0] as? Address,
              let token1 = parsedArguments[1] as? Address,
              let fee = parsedArguments[2] as? BigUInt,
              let tickLower = parsedArguments[3] as? BigInt,
              let tickUpper = parsedArguments[4] as? BigInt,
              let amount0Desired = parsedArguments[5] as? BigUInt,
              let amount1Desired = parsedArguments[6] as? BigUInt,
              let amount0Min = parsedArguments[7] as? BigUInt,
              let amount1Min = parsedArguments[8] as? BigUInt,
              let recipient = parsedArguments[9] as? Address,
              let deadline = parsedArguments[10] as? BigUInt 
        else {
            throw ContractMethodFactories.DecodeError.invalidABI
        }

        return MintMethod(token0: token0, token1: token1, fee: fee, tickLower: tickLower, tickUpper: tickUpper, amount0Desired: amount0Desired, amount1Desired: amount1Desired, amount0Min: amount0Min, amount1Min: amount1Min, recipient: recipient, deadline: deadline)
    }
}

