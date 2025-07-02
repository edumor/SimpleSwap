# SimpleSwap - Decentralized Token Exchange

![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-363636?style=flat-square&logo=solidity)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)
![Network](https://img.shields.io/badge/Network-Sepolia-orange?style=flat-square)


A simple and efficient Automated Market Maker (AMM) implementation that replicates basic Uniswap functionality without external dependencies.

## 🎯 Project Overview

SimpleSwap is an educational implementation of a decentralized exchange (DEX) smart contract that demonstrates core DeFi concepts including:

- **Liquidity Management**: Add and remove liquidity from token pairs
- **Token Swapping**: Exchange tokens using constant product formula
- **Price Discovery**: Calculate real-time exchange rates
- **Zero Fees**: Simplified implementation without trading fees
- **Gas Optimized**: Efficient contract design for reduced transaction costs

## 🏗️ Architecture

### Core Components

1. **Liquidity Pools**: Each token pair has its own pool with reserves
2. **AMM Algorithm**: Uses constant product formula (x * y = k)
3. **Liquidity Tokens**: Users receive LP tokens representing their share
4. **Price Oracle**: Real-time price calculation based on reserves

### Smart Contract Features

- ✅ **Add Liquidity**: Deposit tokens to earn trading fees
- ✅ **Remove Liquidity**: Withdraw tokens and accumulated fees  
- ✅ **Token Swaps**: Exchange tokens at current market rates
- ✅ **Price Queries**: Get current exchange rates
- ✅ **Amount Calculations**: Preview swap outcomes

## 📋 Contract Functions

### 1. Add Liquidity
```solidity
function addLiquidity(
    address tokenA,
    address tokenB, 
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB, uint256 liquidity)
```

**Purpose**: Add liquidity to a token pair pool  
**Parameters**: 
- `tokenA/tokenB`: Token contract addresses
- `amountADesired/amountBDesired`: Desired amounts to deposit
- `amountAMin/amountBMin`: Minimum amounts (slippage protection)
- `to`: Address to receive LP tokens
- `deadline`: Transaction expiration timestamp

### 2. Remove Liquidity
```solidity
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB)
```

**Purpose**: Remove liquidity from a pool and receive underlying tokens  
**Parameters**: 
- `liquidity`: Amount of LP tokens to burn
- `amountAMin/amountBMin`: Minimum amounts to receive

### 3. Swap Tokens
```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts)
```

**Purpose**: Exchange exact input amount for output tokens  
**Parameters**: 
- `amountIn`: Exact amount of input tokens
- `amountOutMin`: Minimum output amount
- `path`: [tokenIn, tokenOut] array

### 4. Get Price
```solidity
function getPrice(address tokenA, address tokenB) external view returns (uint256 price)
```

**Purpose**: Get current exchange rate between tokens  
**Returns**: Price of tokenA in terms of tokenB (scaled by 1e18)

### 5. Calculate Output Amount
```solidity
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut)
```

**Purpose**: Calculate expected output for a given input  
**Formula**: `amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)`

## 🔧 Technical Implementation

### Pool Management
- Pools are identified by ordered token pairs
- Consistent token ordering ensures unique pool IDs
- Reserves are updated atomically during operations

### Liquidity Calculation
- Initial liquidity: `sqrt(amountA * amountB)`
- Additional liquidity: Proportional to existing reserves
- LP tokens represent proportional ownership

### Swap Mechanics
- Follows constant product formula (x * y = k)
- No trading fees for educational simplicity
- Automatic slippage protection via minimum amounts

### Safety Features
- Deadline checks prevent expired transactions
- Input validation prevents zero amounts and addresses
- Sufficient balance checks before operations
- Slippage protection with minimum amount parameters

## 🚀 Deployment Guide

### Prerequisites
- Node.js and npm/yarn
- Hardhat or Truffle development environment
- Sepolia testnet ETH for gas fees
- TokenA and TokenB contracts deployed

### Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/your-username/SimpleSwap.git
   cd SimpleSwap
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Deploy to Sepolia**
   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```

4. **Verify Contract**
   ```bash
   npx hardhat verify --network sepolia CONTRACT_ADDRESS
   ```

## 📊 Usage Examples

### Adding Liquidity
```javascript
// Approve tokens first
await tokenA.approve(simpleSwap.address, amountA);
await tokenB.approve(simpleSwap.address, amountB);

// Add liquidity
await simpleSwap.addLiquidity(
    tokenA.address,
    tokenB.address,
    amountA,
    amountB,
    amountAMin,
    amountBMin,
    userAddress,
    deadline
);
```

### Swapping Tokens
```javascript
// Approve input token
await tokenA.approve(simpleSwap.address, amountIn);

// Execute swap
await simpleSwap.swapExactTokensForTokens(
    amountIn,
    amountOutMin,
    [tokenA.address, tokenB.address],
    userAddress,
    deadline
);
```

### Getting Price
```javascript
const price = await simpleSwap.getPrice(tokenA.address, tokenB.address);
console.log(`Price: ${price.toString()}`);
```

## 🧪 Testing

### Test Coverage
- ✅ Liquidity addition/removal
- ✅ Token swapping mechanics
- ✅ Price calculation accuracy
- ✅ Error handling and edge cases
- ✅ Gas optimization validation

### Running Tests
```bash
npm test
```

## � Gas Optimization

### Efficient Design Choices
- Minimal storage variables
- Optimized loop structures
- Batch operations where possible
- Efficient token ordering algorithm

### Gas Usage (Approximate)
- Add Liquidity: ~120k gas
- Remove Liquidity: ~100k gas
- Token Swap: ~80k gas
- Price Query: ~30k gas

## 🔒 Security Considerations

### Implemented Safeguards
- Input validation for all parameters
- Overflow/underflow protection
- Deadline expiration checks
- Slippage protection mechanisms
- Reentrancy prevention

### Audit Recommendations
- Formal verification of mathematical formulas
- Comprehensive test coverage
- Integration testing with various token types
- Performance testing under high load

## 🎓 Educational Value

This project demonstrates:
- **DeFi Mechanics**: Core AMM functionality
- **Smart Contract Development**: Solidity best practices
- **Gas Optimization**: Efficient code patterns
- **Testing**: Comprehensive test coverage
- **Documentation**: Clear technical documentation

## 📚 Related Contracts

- **TokenA**: ERC20 test token for trading pairs
- **TokenB**: ERC20 test token for trading pairs
- **Verification Contract**: ETH-KIPU
## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests
4. Update documentation
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
### 🎯 **SimpleSwap Contract (Main AMM)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0x13f7C492F568EEE5F809e46f0806F279BD243c82`](https://sepolia.etherscan.io/address/0x13f7C492F568EEE5F809e46f0806F279BD243c82) |
| **Type** | AMM Contract |
| **Network** | Sepolia Testnet |
| **Compiler** | Solidity v0.8.20+commit.a1b79de6 |
| **Optimization** | Enabled (200 runs) |
| **License** | MIT |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0x13f7C492F568EEE5F809e46f0806F279BD243c82#code) |
| **Purpose** | Main AMM implementation |


**⚠️ Disclaimer**: This is an educational project for university coursework. Use in production environments requires additional security audits and testing.
| **Optimization** | Enabled (200 runs) |
| **License** | MIT |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0x56D856c058a07001a646A8a347CA5Fd498766360#code) |

### 🪙 **TokenA (Test Token)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0xa00dC451faB5B80145d636EeE6A9b794aA81D48C`](https://sepolia.etherscan.io/address/0xa00dC451faB5B80145d636EeE6A9b794aA81D48C) |
| **Type** | ERC20 Token |
| **Network** | Sepolia Testnet |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0xa00dC451faB5B80145d636EeE6A9b794aA81D48C#code) |
| **Purpose** | Test token for AMM operations |

### 🪙 **TokenB (Test Token)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0x99Cd59d18C1664Ae32baA1144E275Eee34514115`](https://sepolia.etherscan.io/address/0x99Cd59d18C1664Ae32baA1144E275Eee34514115) |
| **Type** | ERC20 Token |
| **Network** | Sepolia Testnet |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0x99Cd59d18C1664Ae32baA1144E275Eee34514115#code) |
| **Purpose** | Test token for AMM operations |

## ✅ Coden Verification

### 🏛️ **ETH-KIPU**
The project has been successfully verified:

| Property | Value |
|----------|-------|
| **Verifier Contract** | [`0x9f8F02DAB384DDdf1591C3366069Da3Fb0018220`](https://sepolia.etherscan.io/address/0x9f8F02DAB384DDdf1591C3366069Da3Fb0018220) |
| **Verification Transaction** | [`0xf57ce58099c964f20c4d9f2a12119bb841e0f110485f21500850a826018a4393`](https://sepolia.etherscan.io/tx/0xf57ce58099c964f20c4d9f2a12119bb841e0f110485f21500850a826018a4393) |
| **Status** | ✅ **SUCCESS** |
| **Block Number** | 8672723 |
| **Timestamp** | Jul-02-2025 01:17:24 AM UTC |

### 🧪 **Tests Performed Verifier**
1. ✅ **addLiquidity()** - Liquidity addition functionality
2. ✅ **getPrice()** - Price calculation accuracy  
3. ✅ **getAmountOut()** - Output amount calculations
4. ✅ **swapExactTokensForTokens()** - Token swapping with zero fees
5. ✅ **removeLiquidity()** - Proportional liquidity removal

**Verification Parameters Used:**
```
- amountA: 1,000,000,000,000,000,000 (1 ETH)
- amountB: 1,000,000,000,000,000,000 (1 ETH)  
- amountIn: 500,000,000,000,000,000 (0.5 ETH)
- Author: "Eduardo Moreno"
```

## 🏗️ Technical Overview

SimpleSwap implements a constant product AMM (x * y = k) with zero trading fees.

**Core Functions:**
- `addLiquidity()` - Add tokens to liquidity pool
- `removeLiquidity()` - Remove tokens from pool  
- `swapExactTokensForTokens()` - Swap tokens with zero fees
- `getPrice()` - Get current token price
- `getAmountOut()` - Calculate swap output

## � Quick Start

```javascript
// Contract addresses on Sepolia
const SIMPLESWAP = "0x13f7C492F568EEE5F809e46f0806F279BD243c82";
const TOKEN_A = "0xa00dC451faB5B80145d636EeE6A9b794aA81D48C";
const TOKEN_B = "0x99Cd59d18C1664Ae32baA1144E275Eee34514115";

// Add liquidity
await simpleSwap.addLiquidity(TOKEN_A, TOKEN_B, amount1, amount2, 0, 0, user, deadline);

// Swap tokens
await simpleSwap.swapExactTokensForTokens(amountIn, 0, [TOKEN_A, TOKEN_B], user, deadline);
```

## ✅ Features & Status

- ✅ **Zero Trading Fees** - Pure constant product formula
- ✅ **Complete AMM** - Add/remove liquidity, swap tokens
- ✅ **Gas Optimized** - Efficient Solidity ^0.8.20 implementation
- ✅ **Deployed & Verified** - Live on Sepolia testnet
- ✅ **ETH-KIPU Verified** - Passes academic requirements

## 📞 Links

- [Contract on Etherscan](https://sepolia.etherscan.io/address/0x56D856c058a07001a646A8a347CA5Fd498766360)
- [Verification Transaction](https://sepolia.etherscan.io/tx/0x8472fa75b50700c0111458c8c8031fe935f9e62ad4b8d1dc631773a440c0449d)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Zero-fee AMM implementation deployed on Sepolia testnet for ETH-KIPU.*
