import BigInt
import Eip20Kit
import EvmKit
import SnapKit
import UIKit
import UniswapKit

class LiquidityController: UIViewController {
//    private let slippage = Decimal(0.005)
//    private var gasPrice = GasPrice.legacy(gasPrice: 1_000_000_000)
    private var estimatedCancellationTask: Task<Void, Never>?
    private var swapDataTask: Task<Void, Never>?

//    private var tradeOptions = TradeOptions(allowedSlippage: 0.5)
    private var fromToken = Configuration.shared.erc20Tokens[5]
    private var toToken = Configuration.shared.erc20Tokens[4]
    private var tradeType: TradeType = .exactIn {
        didSet {
            syncCoinLabels()
        }
    }
    private var liquiditys = [Positions]()
    private var tradeData: TradeDataV3?
    private let evmKit = Manager.shared.evmKit
    private let signer = Manager.shared.signer
    private var state: State = .idle

    private let uniswapKit = try! UniswapKit.KitV3.instance(dexType: .pancakeSwap)

    private let fromButton = UIButton()
    private let fromTextField = UITextField()
    private let toButton = UIButton()
    private let toTextField = UITextField()
    
    private let tickLowerLabel = UILabel()
    private let tickLowerField = UITextField()
    
    private let tickUpperLabel = UILabel()
    private let tickUpperField = UITextField()
    
    private let tickCurrentLabel = UILabel()
    private let tickCurrentField = UITextField()
    
    private let allowanceLabel = UILabel()
    private let maximumSoldLabel = UILabel()
    private let executionPriceLabel = UILabel()
    private let midPriceLabel = UILabel()
    private let providerFeeLabel = UILabel()
    private let pathLabel = UILabel()

    private let testTickButton = UIButton()
    private let swapButton = UIButton()
    private let removeLiquidityButton = UIButton()
    private let addButton = UIButton()
    private let syncAllowanceButton = UIButton()
    private let approveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Liquidity"

        view.addSubview(fromButton)
        fromButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        fromButton.setTitleColor(.systemBlue, for: .normal)
        fromButton.titleLabel?.font = .systemFont(ofSize: 14)
        fromButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)

        let fromTextFieldWrapper = UIView()

        view.addSubview(fromTextFieldWrapper)
        fromTextFieldWrapper.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(fromButton.snp.bottom).offset(8)
        }

        fromTextFieldWrapper.borderWidth = 1
        fromTextFieldWrapper.borderColor = .black.withAlphaComponent(0.1)
        fromTextFieldWrapper.layer.cornerRadius = 8

        fromTextFieldWrapper.addSubview(fromTextField)
        fromTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        fromTextField.text = "1"
        fromTextField.font = .systemFont(ofSize: 13)
        fromTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        view.addSubview(toButton)
        toButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(fromTextField.snp.bottom).offset(16)
        }

        toButton.setTitleColor(.systemBlue, for: .normal)
        toButton.titleLabel?.font = .systemFont(ofSize: 14)
        toButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)

        let toTextFieldWrapper = UIView()

        view.addSubview(toTextFieldWrapper)
        toTextFieldWrapper.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(toButton.snp.bottom).offset(8)
        }

        toTextFieldWrapper.borderWidth = 1
        toTextFieldWrapper.borderColor = .black.withAlphaComponent(0.1)
        toTextFieldWrapper.layer.cornerRadius = 8

        toTextFieldWrapper.addSubview(toTextField)
        toTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        toTextField.font = .systemFont(ofSize: 13)
        toTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tickLowerLabel.text = "lower Price"
        view.addSubview(tickLowerLabel)
        tickLowerLabel.snp.makeConstraints { make in
            make.top.equalTo(toTextFieldWrapper.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        let tickLowerFieldWrapper = UIView()

        view.addSubview(tickLowerFieldWrapper)
        tickLowerFieldWrapper.snp.makeConstraints { make in
            make.top.equalTo(tickLowerLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tickLowerFieldWrapper.borderWidth = 1
        tickLowerFieldWrapper.borderColor = .black.withAlphaComponent(0.1)
        tickLowerFieldWrapper.layer.cornerRadius = 8

        tickLowerFieldWrapper.addSubview(tickLowerField)
        tickLowerField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        tickLowerField.font = .systemFont(ofSize: 13)
        
        tickCurrentLabel.text = "current Price"
        view.addSubview(tickCurrentLabel)
        tickCurrentLabel.snp.makeConstraints { make in
            make.top.equalTo(tickLowerFieldWrapper.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        let tickCurrentFieldWrapper = UIView()

        view.addSubview(tickCurrentFieldWrapper)
        tickCurrentFieldWrapper.snp.makeConstraints { make in
            make.top.equalTo(tickCurrentLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tickCurrentFieldWrapper.borderWidth = 1
        tickCurrentFieldWrapper.borderColor = .black.withAlphaComponent(0.1)
        tickCurrentFieldWrapper.layer.cornerRadius = 8

        tickCurrentFieldWrapper.addSubview(tickCurrentField)
        tickCurrentField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        tickCurrentField.font = .systemFont(ofSize: 13)
        
        var lastView = tickCurrentFieldWrapper
        let labels = [allowanceLabel, maximumSoldLabel, executionPriceLabel, midPriceLabel, providerFeeLabel, pathLabel]
        labels.enumerated().forEach { index, label in
            lastView.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(16)
                make.top.equalTo(lastView.snp.bottom).offset(index == 0 ? 24 : 16)
            }

            label.font = .systemFont(ofSize: 12)
            label.textColor = .gray
            lastView = label
        }
        
        tickUpperLabel.text = "upper Price"
        view.addSubview(tickUpperLabel)
        tickUpperLabel.snp.makeConstraints { make in
            make.top.equalTo(tickCurrentFieldWrapper.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        let tickUpperFieldWrapper = UIView()

        view.addSubview(tickUpperFieldWrapper)
        tickUpperFieldWrapper.snp.makeConstraints { make in
            make.top.equalTo(tickUpperLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tickUpperFieldWrapper.borderWidth = 1
        tickUpperFieldWrapper.borderColor = .black.withAlphaComponent(0.1)
        tickUpperFieldWrapper.layer.cornerRadius = 8

        tickUpperFieldWrapper.addSubview(tickUpperField)
        tickUpperField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        tickUpperField.font = .systemFont(ofSize: 13)
        
        pathLabel.numberOfLines = 4
        
        view.addSubview(testTickButton)
        testTickButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(pathLabel.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        testTickButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        testTickButton.setTitleColor(.systemBlue, for: .normal)
        testTickButton.setTitleColor(.lightGray, for: .disabled)
        testTickButton.setTitle("Test Tick", for: .normal)
        testTickButton.addTarget(self, action: #selector(testTickData), for: .touchUpInside)

        view.addSubview(swapButton)
        swapButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(pathLabel.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        swapButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        swapButton.setTitleColor(.systemBlue, for: .normal)
        swapButton.setTitleColor(.lightGray, for: .disabled)
        swapButton.setTitle("BestTradeData", for: .normal)
        swapButton.addTarget(self, action: #selector(bestTradeData), for: .touchUpInside)
        
        view.addSubview(removeLiquidityButton)
        removeLiquidityButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(testTickButton.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        removeLiquidityButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        removeLiquidityButton.setTitleColor(.systemBlue, for: .normal)
        removeLiquidityButton.setTitleColor(.lightGray, for: .disabled)
        removeLiquidityButton.setTitle("removeLiquidity", for: .normal)
        removeLiquidityButton.addTarget(self, action: #selector(testRemoveLiquidity), for: .touchUpInside)
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(testTickButton.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        addButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.setTitleColor(.lightGray, for: .disabled)
        addButton.setTitle("addLiquidity", for: .normal)
        addButton.addTarget(self, action: #selector(testAddLiquidity), for: .touchUpInside)
        
        
        view.addSubview(syncAllowanceButton)
        syncAllowanceButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(removeLiquidityButton.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        syncAllowanceButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        syncAllowanceButton.setTitleColor(.systemBlue, for: .normal)
        syncAllowanceButton.setTitleColor(.lightGray, for: .disabled)
        syncAllowanceButton.setTitle("Sync Allowance", for: .normal)
        syncAllowanceButton.addTarget(self, action: #selector(syncAllowance), for: .touchUpInside)

        view.addSubview(approveButton)
        approveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(addButton.snp.bottom).offset(28)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        approveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        approveButton.setTitleColor(.systemBlue, for: .normal)
        approveButton.setTitleColor(.lightGray, for: .disabled)
        approveButton.setTitle("Approve", for: .normal)
        approveButton.addTarget(self, action: #selector(approve), for: .touchUpInside)
        
        syncCoinLabels()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        view.endEditing(true)
    }

    @objc private func onTapButton(_ button: UIButton) {
        let isFrom = button == fromButton

        let viewController = TokenSelectController()
        viewController.onSelect = { [weak self] token in
            self?.syncToken(isFrom: isFrom, token: token)
        }
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    private func checkValidAmount(text: String?) -> Bool {
        let text = text ?? ""
        if text.isEmpty {
            return false
        }
        if let decimalValue = Decimal(string: text), !decimalValue.isZero {
            return true
        }
        return false
    }
    
    private func syncEstimated(tradeType: TradeType, exact _: BigUInt, bestTrade: TradeDataV3) {
        
        tickLowerField.text = bestTrade.tickInfo?.tickLowerPrice?.description
        tickUpperField.text = bestTrade.tickInfo?.tickUpperPrice?.description
        tickCurrentField.text = bestTrade.tickInfo?.tickcurrentPrice?.description
        
        let estimatedAmount = tradeType == .exactIn ? bestTrade.amountOut : bestTrade.amountIn

        switch tradeType {
        case .exactIn: toTextField.text = estimatedAmount?.description
        case .exactOut: fromTextField.text = estimatedAmount?.description
        }

        state = .success(bestTrade: bestTrade)
    }

    private func syncToken(isFrom: Bool, token: Erc20Token) {
        if isFrom {
            guard fromToken.code != token.code else {
                return
            }
            let oldToken = fromToken

            fromToken = token
            if toToken.code == token.code {
                toToken = oldToken
            }
        } else {
            guard toToken.code != token.code else {
                return
            }
            let oldToken = toToken

            toToken = token
            if fromToken.code == token.code {
                fromToken = oldToken
            }
        }
        syncCoinLabels()

        let textField = tradeType == .exactIn ? fromTextField : toTextField
        guard checkValidAmount(text: textField.text) else {
            return
        }

    }

    private func syncCoinLabels() {
        let fromText = "From: \(fromToken.code)" + (tradeType == .exactIn ? "" : " (estimated)")
        let toText = "To: \(toToken.code)" + (tradeType == .exactOut ? "" : " (estimated)")

        fromButton.setTitle(fromText, for: .normal)
        toButton.setTitle(toText, for: .normal)
    }
    
    private func sync(allowance: String?) {
        allowanceLabel.text = "Allowance: \(allowance ?? "N/A")"
    }
    
    @objc private func bestTradeData() {
                        
        let tickLower: BigInt? = nil
        let tickUpper: BigInt? = nil
        
        Task {
            do {
                guard let amountString = fromTextField.text, let amount = Decimal(string: amountString),
                      let amountBigUInt = BigUInt(amount.hs.roundedString(decimal: fromToken.decimals))
                else { return }
                let tokenIn = token(fromToken)
                let tokenOut = token(toToken)
                let tradeData = try await uniswapKit.liquidityBestTradeExact(rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, tokenIn: tokenIn, tokenOut: tokenOut, amountIn: amount, options: getTradeOptions(), tickType: .range(lower: tickLower, upper: tickUpper))
                print("============>tickLower:\(tradeData.tickInfo?.tickLower.description)\n============>tickUpper:\(tradeData.tickInfo?.tickUpper.description)")
                
                self.tradeData = tradeData
                
                let exactAmount: BigUInt = amountBigUInt
                syncEstimated(tradeType: .exactIn, exact: exactAmount, bestTrade: tradeData)
            }catch{}
        }
    }
    //
    @objc private func testAddLiquidity() {
        let receiveAddress = Manager.shared.evmKit.receiveAddress//evmKit!.receiveAddress
        print("receiveAddress: \(receiveAddress.hex)")
        let tickLower: BigInt? = nil//7650 // test
        let tickUpper: BigInt? = nil//9950 // test
        Task {
            do {
                guard let amountString = fromTextField.text, let amount = Decimal(string: amountString),
                      let amountBigUInt = BigUInt(amount.hs.roundedString(decimal: fromToken.decimals))
                else { return }
                let tokenIn = token(fromToken)
                let tokenOut = token(toToken)
                let tradeData = try await uniswapKit.liquidityBestTradeExact(rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, tokenIn: tokenIn, tokenOut: tokenOut, amountIn: amount, options: getTradeOptions(), tickType: .range(lower: tickLower, upper: tickUpper))
                let exactAmount: BigUInt = amountBigUInt
                syncEstimated(tradeType: .exactIn, exact: exactAmount, bestTrade: tradeData)
                
                let tradeOptions = TradeOptions()
                let transactionData = try await uniswapKit.addLiquidityTransactionData(bestTrade: tradeData, tradeOptions: tradeOptions, recipient: receiveAddress, rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, deadline: getDeadLine())
                print("add input Data: \(transactionData.input.hs.hexString)")
//                let fullTransaction = try await send(transactionData: transactionData)

            }catch{}
        }
    }
    
    @objc private func testRemoveLiquidity() {
        let receiveAddress = evmKit!.receiveAddress
        Task {
            do {
                
                let array = try await uniswapKit.ownedLiquidity(rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, owner: receiveAddress)
                let tId: BigUInt = 1235038
                guard let positions = array.first(where: {$0.tokenId == tId}) else { return }
                
//                let positions = array[0]
                let tokenId = positions.tokenId // 1235038
                let liquidity = positions.liquidity /// 20 // test
                let slippage = BigUInt((getTradeOptions().allowedSlippage).description)!
                
                print("============>tokenId:\(positions.tokenId)\n============>liquidity:\(positions.liquidity.description)\n============>tokensOwed0:\(positions.tokensOwed0.description)\n============>tokensOwed1:\(positions.tokensOwed1.description)\n============>tickLower:\(positions.tickLower.description)\n============>tickUpper:\(positions.tickUpper.description)\n============>slippage:\(slippage.description)")
                
                let (amount0, amount1, _) = try await uniswapKit.getAmountsForLiquidity(positions: positions, rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, liquidity: liquidity)
                let amount0Min = amount0 - amount0.multiplied(by: slippage)/1000
                let amount1Min = amount1 - amount1.multiplied(by: slippage)/1000
                                 
                let transactionData = try await uniswapKit.removeLiquidityTransactionData(positions: positions, rpcSource: RpcSource.bscRpcHttp(), chain: Configuration.shared.chain, liquidity: liquidity, slippage: slippage, recipient: receiveAddress, deadline: getDeadLine())
                print("remove input Data: \(transactionData.input.hs.hexString)")
//                let fullTransaction = try await send(transactionData: transactionData)
            } catch {}
        }
    }
    
    @objc private func syncAllowance() {
        let token = token(fromToken)
        if token.isEther {
            sync(allowance: nil)
            return
        }
        Task {
            do {
                let spenderAddress = uniswapKit.nonfungiblePositionAddress(chain: Configuration.shared.chain)
                let eip20Kit = try Eip20Kit.Kit.instance(evmKit: Manager.shared.evmKit, contractAddress: token.address)
                let allowance = try await eip20Kit.allowance(spenderAddress: spenderAddress)
                sync(allowance: allowance)
            } catch {
                sync(allowance: nil)
                show(error: error.localizedDescription)
            }
        }
    }

    @objc private func approve() {
        approveToken0()
        approveToken1()
    }
    
    private func approveToken0() {
        guard let amountString = fromTextField.text, let amount = Decimal(string: amountString),
              let amountIn = BigUInt(amount.hs.roundedString(decimal: fromToken.decimals))
        else {
            show(error: "Invalid amount from")
            return
        }
        
        guard let eip20Kit = try? Eip20Kit.Kit.instance(evmKit: Manager.shared.evmKit, contractAddress: token(fromToken).address) else {
            show(error: "Can't create Eip20 Kit for token!")
            return
        }
        let routerAddress = uniswapKit.nonfungiblePositionAddress(chain: Configuration.shared.chain)
        let transactionData = eip20Kit.approveTransactionData(spenderAddress: routerAddress, amount: amountIn)
        
        sendApprove(amountString: amountString, transactionData: transactionData)
    }
    
    private func approveToken1() {
        guard let amountString = toTextField.text, let amount = Decimal(string: amountString),
              let amountIn = BigUInt(amount.hs.roundedString(decimal: toToken.decimals))
        else {
            show(error: "Invalid amount from")
            return
        }
        
        guard let eip20Kit = try? Eip20Kit.Kit.instance(evmKit: Manager.shared.evmKit, contractAddress: token(toToken).address) else {
            show(error: "Can't create Eip20 Kit for token!")
            return
        }
        let routerAddress = uniswapKit.nonfungiblePositionAddress(chain: Configuration.shared.chain)
        let transactionData = eip20Kit.approveTransactionData(spenderAddress: routerAddress, amount: amountIn)
        
        sendApprove(amountString: amountString, transactionData: transactionData)
    }
    
    private func sendApprove(amountString: String, transactionData: TransactionData) {
        
        estimatedCancellationTask?.cancel()
        estimatedCancellationTask = Task { [weak self] in
            do {
                guard let evmKit = self?.evmKit else { return }
                let gasPrice = try await self?.syncgasPrice(evmKit: evmKit)
                let gasLimit = try await evmKit.fetchEstimateGas(transactionData: transactionData, gasPrice: gasPrice!)
                print("GasLimit = \(gasLimit)")
                let raw = try await Manager.shared.evmKit.fetchRawTransaction(transactionData: transactionData, gasPrice: gasPrice!, gasLimit: gasLimit)

                let signature = try Manager.shared.signer.signature(rawTransaction: raw)
                let _ = try await Manager.shared.evmKit.send(rawTransaction: raw, signature: signature)

                self?.showSuccess(message: "Approve \(amountString) \(self?.fromToken.code ?? "Tokens")")
            } catch {
                self?.show(error: error.localizedDescription)
            }
        }
    }
    
    private func show(error: String) {
        let alert = UIAlertController(title: "Swap Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func showSuccess(amountIn: BigUInt, amountOut: BigUInt) {
        DispatchQueue.main.async {
            self.showSuccess(message: "\(amountIn.description) swap to \(amountOut.description)")
        }
    }

    private func showSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

extension LiquidityController {
    
    // test sqrtRatioX96、tick、price
    @objc private func testTickData() {
        do {
            // tick to sqrtRatioX96
            let sqrtRatioX96 = try uniswapKit.getSqrtRatioAtTick(tick: BigInt(7111))
            print("1.>>>>>>>> sqrtRatioX96: \(sqrtRatioX96.description)")
            
            // sqrtRatioX96 to tick
            let tick = try uniswapKit.getTickAtSqrtRatio(sqrtRatioX96: sqrtRatioX96)
            print("2.>>>>>>>>>> tick: \(tick.description)")
            
            // sqrtRatioX96 to price
            guard let price = uniswapKit.correctedX96Price(sqrtPriceX96: sqrtRatioX96, tokenIn: token(fromToken), tokenOut: token(toToken)) else { return }
            print("3. >>>>>>>>>> price: \(price.description)")
            
            // price to sqrtRatioX96  // 0.5856 -> 5352  // 5451
            guard let sqrtPriceX96 = uniswapKit.encodeSqrtRatioX96(price: 0.5798, tokenA: token(fromToken), tokenB: token(toToken)) else { return }
            print("4.>>>>>>>>>> sqrtPriceX96: \(sqrtPriceX96.description)")
            
            // tick to sqrtRatioX96
            let xtick = try uniswapKit.getTickAtSqrtRatio(sqrtRatioX96: sqrtPriceX96)
            print("5.>>>>>>>>>> xtick: \(xtick)")
            
            
        }catch{}
        
    }
    
    func tickToPrice(tick: BigInt, tokenIn: Token, tokenOut: Token) throws -> Decimal? {
        do {
            let sqrtRatioX96 = try uniswapKit.getSqrtRatioAtTick(tick: tick)
            return uniswapKit.correctedX96Price(sqrtPriceX96: sqrtRatioX96, tokenIn: tokenIn, tokenOut: tokenOut)
        }catch {
            return nil
        }
    }
}
extension LiquidityController {
    func token(_ erc20Token: Erc20Token) -> Token {
        guard let contractAddress = erc20Token.contractAddress else {
            return try! uniswapKit.etherToken(chain: .binanceSmartChain)
        }

        return .erc20(address: contractAddress, decimals: erc20Token.decimals)
    }

    enum State {
        case idle
        case success(bestTrade: TradeDataV3)
    }
}

extension LiquidityController {
    @objc func textFieldDidChange(_ textField: UITextField) {
        let newTradeType: TradeType = textField == fromTextField ? .exactIn : .exactOut

        print("textField did change")
        if tradeType != newTradeType {
            print("Change Trade Type to : \(newTradeType)")
            tradeType = newTradeType
        }

        if !checkValidAmount(text: textField.text) {
            switch newTradeType {
            case .exactIn: toTextField.text = ""
            case .exactOut: fromTextField.text = ""
            }
            return
        }
    }
}

extension LiquidityController {
    
    private func send(transactionData: TransactionData) async throws -> FullTransaction? {
        guard let evmKit else { return nil }
        let nonce = try await evmKit.nonce(defaultBlockParameter: .pending)
        let gasPrice = try await syncgasPrice(evmKit: evmKit)
        let gasLimit = try await evmKit.fetchEstimateGas(transactionData: transactionData, gasPrice: gasPrice)
        
        let rawTransaction = try await evmKit.fetchRawTransaction(transactionData: transactionData, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce)
        guard let signature = try signer?.signature(rawTransaction: rawTransaction)  else { return nil }

        let fullTransaction = try await evmKit.send(rawTransaction: rawTransaction, signature: signature)
        return fullTransaction
    }
        
    private func syncgasPrice(evmKit: EvmKit.Kit) async throws -> GasPrice {
        let gasPriceProvider = LegacyGasPriceProvider(evmKit: evmKit)
        return try await gasPriceProvider.gasPrice()
    }
    
    func getDeadLine() -> BigUInt {
        let deadLine: Int = 20 // 20 min
        let txDeadLine = (UInt64(Date().timeIntervalSince1970) + UInt64(60 * deadLine))
        return BigUInt(integerLiteral: txDeadLine)
    }
    
    func getTradeOptions() -> TradeOptions {
        let slippage: Decimal = (token(fromToken).address.hex == "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c" || token(toToken).address.hex == "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c") ? 25 : 5
        return TradeOptions(allowedSlippage: slippage)
    }
}

class GetDomainSeparatorMethod: ContractMethod {
    override var methodSignature: String { "DOMAIN_SEPARATOR()" }
    override var arguments: [Any] { [] }
}

class GetPermitTypeHashMethod: ContractMethod {
    override var methodSignature: String { "PERMIT_TYPEHASH()" }
    override var arguments: [Any] { [] }
}
