import EvmKit

class PancakeSwapV2ContractMethodFactories: ContractMethodFactories {
    static let shared = PancakeSwapV2ContractMethodFactories()

    override init() {
        super.init()
        register(factories: [
            AddLiquidityMethodFactory(),
            MulticallMethodFactory()
        ])
    }

}
