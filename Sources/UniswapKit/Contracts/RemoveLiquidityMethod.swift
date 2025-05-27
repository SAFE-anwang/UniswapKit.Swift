import EvmKit
import BigInt

protocol RemoveLiquidityProtocol {
    var tokenA: Address { get }
    var tokenB: Address { get }
    var liquidity: BigUInt { get }
    var amountAMin: BigUInt { get }
    var amountBMin: BigUInt { get }
    var to: Address { get }
    var deadline: BigUInt { get }
}

class RemoveLiquidityMethod: ContractMethod, RemoveLiquidityProtocol {

    
    static let methodSignature = "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)"

    var tokenA: Address
    var tokenB: Address
    var liquidity: BigUInt
    var amountAMin: BigUInt
    var amountBMin: BigUInt
    var to: Address
    var deadline: BigUInt

    init(tokenA: Address, tokenB: Address, liquidity: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, to: Address, deadline: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.liquidity = liquidity
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.to = to
        self.deadline = deadline

        super.init()
    }

    override var methodSignature: String { RemoveLiquidityMethod.methodSignature }

    override var arguments: [Any] {
        [tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline]
    }

}

class RemoveLiquidityWithPermitMethod: ContractMethod, RemoveLiquidityProtocol {
    static let methodSignature = "removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)"

    var tokenA: Address
    var tokenB: Address
    var liquidity: BigUInt
    var amountAMin: BigUInt
    var amountBMin: BigUInt
    var to: Address
    var deadline: BigUInt
    let approveMax: String
    let v: BigUInt
    let r: BigUInt
    let s: BigUInt
    
    init(tokenA: Address, tokenB: Address, liquidity: BigUInt, amountAMin: BigUInt, amountBMin: BigUInt, to: Address, deadline: BigUInt, approveMax: Bool, v: BigUInt, r: BigUInt, s: BigUInt) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.liquidity = liquidity
        self.amountAMin = amountAMin
        self.amountBMin = amountBMin
        self.to = to
        self.deadline = deadline
        self.approveMax = approveMax ? "1" : "0"
        self.v = v
        self.r = r
        self.s = s
        super.init()
    }

    override var methodSignature: String { RemoveLiquidityWithPermitMethod.methodSignature }

    override var arguments: [Any] {
        [tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline, approveMax, v, r, s]
    }

}
