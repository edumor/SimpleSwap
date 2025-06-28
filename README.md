# SimpleSwap - Automated Market Maker (AMM)

![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-363636?style=flat-square&logo=solidity)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)
![Network](https://img.shields.io/badge/Network-Sepolia-orange?style=flat-square)
![Verified](https://img.shields.io/badge/Contract-Verified-green?style=flat-square)
![University](https://img.shields.io/badge/University-Verified-success?style=flat-square)

A minimal, zero-fee Automated Market Maker (AMM) implementation similar to Uniswap, Successfully deployed and verified on Sepolia testnet.

## � Project Overview

SimpleSwap is an educational implementation of an Automated Market Maker that demonstrates core DeFi concepts:
- **Zero-fee token swapping** using constant product formula (x * y = k)
- **Liquidity provision** with proportional rewards
- **Price discovery** through mathematical calculations
- **Gas-optimized** smart contract design

## 📋 Repository Contents

This repository contains only the essential deployed contracts:

```
SimpleSwap/
├── SimpleSwap.sol          # Main AMM contract (deployed & verified)
├── TokenA.sol             # Test token A for swapping
├── TokenB.sol             # Test token B for swapping
├── README.md              # This documentation
└── .gitignore            # Git ignore rules
```

## 📄 Contract Information

### 🎯 **SimpleSwap Contract (Main AMM)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0x56D856c058a07001a646A8a347CA5Fd498766360`](https://sepolia.etherscan.io/address/0x56D856c058a07001a646A8a347CA5Fd498766360) |
| **Network** | Sepolia Testnet |
| **Compiler** | Solidity v0.8.20+commit.a1b79de6 |
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
| **Contract Address** | [`0xD9F19b47c1Ad33C8dfa7f21fD7915Ac7BF1f6B5f`](https://sepolia.etherscan.io/address/0xD9F19b47c1Ad33C8dfa7f21fD7915Ac7BF1f6B5f) |
| **Type** | ERC20 Token |
| **Network** | Sepolia Testnet |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0xD9F19b47c1Ad33C8dfa7f21fD7915Ac7BF1f6B5f#code) |
| **Purpose** | Test token for AMM operations |

## ✅ Coden Verification

### 🏛️ **ETH-KIPU**
The project has been successfully verified:

| Property | Value |
|----------|-------|
| **Verifier Contract** | [`0x9f8F02DAB384DDdf1591C3366069Da3Fb0018220`](https://sepolia.etherscan.io/address/0x9f8F02DAB384DDdf1591C3366069Da3Fb0018220) |
| **Verification Transaction** | [`0x8472fa75b50700c0111458c8c8031fe935f9e62ad4b8d1dc631773a440c0449d`](https://sepolia.etherscan.io/tx/0x8472fa75b50700c0111458c8c8031fe935f9e62ad4b8d1dc631773a440c0449d) |
| **Status** | ✅ **SUCCESS** |
| **Block Number** | 8648206 |
| **Timestamp** | Jun-28-2025 03:13:36 PM UTC |

### 🧪 **Tests Performed by University Verifier**
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

## 🏗️ Technical Architecture

### Core AMM Implementation
```
SimpleSwap Contract
├── State Variables
│   ├── reserves: mapping(address => mapping(address => uint256))
│   ├── liquidityBalances: mapping(address => mapping(address => mapping(address => uint256)))
│   └── totalLiquidity: mapping(address => mapping(address => uint256))
├── Core Functions
│   ├── addLiquidity() - Add tokens to liquidity pool
│   ├── removeLiquidity() - Remove tokens from pool
│   ├── swapExactTokensForTokens() - Swap tokens with zero fees
│   ├── getPrice() - Get current token price
│   └── getAmountOut() - Calculate swap output
└── Internal Helpers
    ├── _addLiq() - Internal liquidity addition logic
    ├── _remLiq() - Internal liquidity removal logic
    ├── _swap() - Internal swap execution
    ├── _transfer() - Token transfer helper
    └── _transferFrom() - Token transferFrom helper
```

### Mathematical Foundation
The AMM uses the **Constant Product Formula**:
```
x * y = k (where k is constant)
```

**Zero-Fee Output Calculation:**
```
amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
```

## 🔧 Key Functions

### Public AMM Functions
```solidity
// Add liquidity to token pair
function addLiquidity(
    address tokenA, address tokenB,
    uint256 amountADesired, uint256 amountBDesired,
    uint256, uint256, address to, uint256
) external returns (uint256, uint256, uint256);

// Remove liquidity from token pair
function removeLiquidity(
    address tokenA, address tokenB, uint256 liquidity,
    uint256, uint256, address to, uint256
) external returns (uint256, uint256);

// Swap exact input tokens for output tokens
function swapExactTokensForTokens(
    uint256 amountIn, uint256,
    address[] calldata path, address to, uint256
) external;

// Get price of tokenA in terms of tokenB
function getPrice(address tokenA, address tokenB) 
    external view returns (uint256);

// Calculate expected output amount
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
    public pure returns (uint256);
```

## 🚀 Usage Examples

### Interacting with the Contract

```javascript
// Contract addresses
const SIMPLESWAP = "0x56D856c058a07001a646A8a347CA5Fd498766360";
const TOKEN_A = "0xa00dC451faB5B80145d636EeE6A9b794aA81D48C";
const TOKEN_B = "0x99Cd59d18C1664Ae32baA1144E275Eee34514115";

// Add liquidity example
await simpleSwap.addLiquidity(
    TOKEN_A, TOKEN_B,
    ethers.utils.parseEther("1.0"), // 1 TokenA
    ethers.utils.parseEther("1.0"), // 1 TokenB
    0, 0, userAddress, deadline
);

// Swap tokens example
const path = [TOKEN_A, TOKEN_B];
await simpleSwap.swapExactTokensForTokens(
    ethers.utils.parseEther("0.5"), // 0.5 TokenA
    0, path, userAddress, deadline
);

// Get current price
const price = await simpleSwap.getPrice(TOKEN_A, TOKEN_B);
console.log(`Price: ${ethers.utils.formatEther(price)} TokenB per TokenA`);
```

## 📊 Project Features

### ✅ **Implemented Features**
- **Zero Trading Fees**: Pure constant product formula implementation
- **Complete AMM Functionality**: All core AMM operations supported
- **Gas Optimization**: Efficient contract design with 200 optimization runs
- **ERC20 Compatibility**: Works with standard ERC20 tokens
- **Comprehensive Documentation**: Full NatSpec comments in English
- **University Grade**: Passes academic verification requirements

### 🎓 **ETH-KIPU Value**
This project demonstrates:
- **DeFi Primitives**: Core decentralized finance concepts
- **Smart Contract Development**: Best practices in Solidity
- **Mathematical Implementation**: Constant product market maker formula
- **Gas Optimization Techniques**: Efficient contract design
- **Testing and Verification**: Academic-grade validation

## 🔒 Security Considerations

### Implemented Safety Measures
- ✅ **Solidity ^0.8.20**: Built-in overflow protection
- ✅ **Low-level calls**: Proper error handling for token transfers
- ✅ **Token sorting**: Consistent pair ordering to prevent errors
- ✅ **Mathematical precision**: Accurate calculations with proper rounding

###  Simplifications
- ⚠️ **Fixed liquidity rewards**: Simplified to 1000 tokens for educational clarity
- ⚠️ **No slippage protection**: Parameters present but unused for simplicity
- ⚠️ **No deadline enforcement**: Simplified for academic purposes

## 📚 ETH-KIPU Context

### Requirements Met
- ✅ **Zero-fee implementation**: Required by academic specification
- ✅ **Complete interface**: All required functions implemented
- ✅ **English documentation**: Full NatSpec comments
- ✅ **Verification compatibility**: Passes university verifier
- ✅ **Gas efficiency**: Optimized for deployment costs

### Learning Objectives Achieved
- Understanding of AMM mechanics and constant product formula
- Smart contract development with Solidity best practices
- DeFi protocol implementation and testing
- Blockchain deployment and verification processes

## 📞 Project Information

**Implementation Date**: June 28, 2025  
**Network**: Sepolia Testnet  


**Key Links:**
- [SimpleSwap Contract](https://sepolia.etherscan.io/address/0x56D856c058a07001a646A8a347CA5Fd498766360)
- [Verification Transaction](https://sepolia.etherscan.io/tx/0x8472fa75b50700c0111458c8c8031fe935f9e62ad4b8d1dc631773a440c0449d)
- [Verifier](https://sepolia.etherscan.io/address/0x9f8F02DAB384DDdf1591C3366069Da3Fb0018220)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---


*This implementation successfully demonstrates core AMM functionality with zero trading fees, as verified by the university's automated testing system.*
