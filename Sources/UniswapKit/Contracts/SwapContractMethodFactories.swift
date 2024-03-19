import EvmKit

class SwapContractMethodFactories: ContractMethodFactories {
    static let shared = SwapContractMethodFactories()

    override init() {
        super.init()
        register(factories: [
            AddLiquidityMethodFactory(),
            RemoveLiquidityMethodFactory(),
            AddLiquidityETHMethodFactory(),
            RemoveLiquidityETHMethodFactory(),
            // to do ... AddLiquidityETHWithPermit、RemoveLiquidityETHWithPermit
            SwapETHForExactTokensMethodFactory(),
            SwapExactETHForTokensMethodFactory(),
            SwapExactTokensForETHMethodFactory(),
            SwapExactTokensForTokensMethodFactory(),
            SwapTokensForExactETHMethodFactory(),
            SwapTokensForExactTokensMethodFactory(),
            SwapExactETHForTokensMethodSupportingFeeOnTransferFactory(),
            SwapExactTokensForETHMethodSupportingFeeOnTransferFactory(),
            SwapExactTokensForTokensMethodSupportingFeeOnTransferFactory(),
        ])
    }
}
