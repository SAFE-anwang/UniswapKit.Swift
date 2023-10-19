import Foundation
import EvmKit

class LiquidityMethodDecorator {
    private let contractMethodFactories: PancakeSwapV2ContractMethodFactories

    init(contractMethodFactories: PancakeSwapV2ContractMethodFactories) {
        self.contractMethodFactories = contractMethodFactories
    }

}

extension LiquidityMethodDecorator: IMethodDecorator {

    public func contractMethod(input: Data) -> ContractMethod? {
        contractMethodFactories.createMethod(input: input)
    }

}
