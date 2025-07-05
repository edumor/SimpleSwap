# SimpleSwap - Decentralized Token Exchange

![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-363636?style=flat-square&logo=solidity)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)
![Network](https://img.shields.io/badge/Network-Sepolia-orange?style=flat-square)

## Overview
SimpleSwap is an Automated Market Maker (AMM) implementation that enables token swapping and liquidity provision on the Ethereum network. This project was developed as part of the ETH-KIPU training program for Ethereum developers.

## 🚀 Contract Deployments

### 🎯 **SimpleSwap Contract (Main AMM)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0x7659B6f3B1fFc79a26728e43fE8Dd9613e35Bc18`](https://sepolia.etherscan.io/address/0x7659B6f3B1fFc79a26728e43fE8Dd9613e35Bc18) |
| **Type** | AMM Contract |
| **Network** | Sepolia Testnet |
| **Compiler** | Solidity v0.8.20 |
| **Optimization** | Enabled (200 runs) |
| **License** | MIT |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0x7659B6f3B1fFc79a26728e43fE8Dd9613e35Bc18#code) |
| **Purpose** | Main AMM implementation |

### 🪙 **TokenA (Test Token)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0xa00dC451faB5B80145d636EeE6A9b794aA81D48C`](https://sepolia.etherscan.io/address/0xa00dC451faB5B80145d636EeE6A9b794aA81D48C) |
| **Type** | ERC20 Token |
| **Network** | Sepolia Testnet |
| **Symbol** | TKA |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0xa00dC451faB5B80145d636EeE6A9b794aA81D48C#code) |
| **Purpose** | Test token for AMM operations |

### 🪙 **TokenB (Test Token)**
| Property | Value |
|----------|-------|
| **Contract Address** | [`0x99Cd59d18C1664Ae32baA1144E275Eee34514115`](https://sepolia.etherscan.io/address/0x99Cd59d18C1664Ae32baA1144E275Eee34514115) |
| **Type** | ERC20 Token |
| **Network** | Sepolia Testnet |
| **Symbol** | TKB |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0x99Cd59d18C1664Ae32baA1144E275Eee34514115#code) |
| **Purpose** | Test token for AMM operations |

## 📋 Contract Verification
Successfully verified by the official verifier contract:
- **Verifier Contract**: [`0x9f8f02dab384dddf1591c3366069da3fb0018220`](https://sepolia.etherscan.io/address/0x9f8f02dab384dddf1591c3366069da3fb0018220)
- **Verification Transaction**: [`0xa20b46207cb1448d5cf9986551738b275e0bb04e59e2c4c405302d04db911611`](https://sepolia.etherscan.io/tx/0xa20b46207cb1448d5cf9986551738b275e0bb04e59e2c4c405302d04db911611)
- **Verification Status**: ✅ **PASSED** - All tests completed successfully
- **Verification Date**: July 5, 2025

### 🎯 Verification Results
The contract successfully passed all verification tests:
- ✅ **Liquidity Addition**: 1 TKA + 2 TKB added to pool
- ✅ **Token Swapping**: 0.1 TKA → 0.181818181818181818 TKB (correct AMM calculation)
- ✅ **Liquidity Removal**: Full liquidity withdrawn successfully
- ✅ **Mathematical Accuracy**: Constant product formula K = x * y maintained
- ✅ **No Fees**: Pure AMM implementation without trading fees
- ✅ **Gas Optimization**: Efficient storage patterns verified

## 🔍 Core Features

### 1. Add Liquidity
```solidity
function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external returns (uint amountA, uint amountB, uint liquidity)
```
- Allows users to provide liquidity to token pairs
- Calculates and mints liquidity tokens
- Implements slippage protection with minimum amounts
- Returns actual amounts added and liquidity minted

### 2. Remove Liquidity
```solidity
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external returns (uint amountA, uint amountB)
```
- Enables liquidity providers to withdraw their tokens
- Burns liquidity tokens
- Returns underlying assets
- Includes slippage protection

### 3. Token Swapping
```solidity
function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) external
```
- Executes token swaps using constant product formula
- Ensures minimum output amount (slippage protection)
- No return value (compatible with verifier contract)
- Implements deadline for transaction validity

### 4. Price Oracle
```solidity
function getPrice(
    address tokenA,
    address tokenB
) external view returns (uint)
```
- Returns current price ratio between tokens
- Uses 18 decimal precision
- Based on current reserves

### 5. Amount Calculator
```solidity
function getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
) public pure returns (uint)
```
- Calculates output amount for swaps
- Uses constant product formula (x * y = k)
- Pure function for gas efficiency

## 🏗 Technical Implementation

### Optimized State Variables
```solidity
struct ReserveData {
    uint reserveA;
    uint reserveB;
}

struct LiquidityData {
    uint totalLiquidity;
    mapping(address => uint) balances;
}

mapping(bytes32 => ReserveData) public reserves;
mapping(bytes32 => LiquidityData) public liquidityData;
```

### Events
```solidity
event Swap(address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut);
event LiquidityChange(address indexed tokenA, address indexed tokenB, uint amountA, uint amountB, uint liquidity, bool isAdded);
```

## ⚡ Optimization Features
- **Gas-optimized storage patterns** using structs
- **Efficient mathematical operations**
- **Minimal external calls**
- **Optimized for 200 runs** in compiler
- **Single-responsibility functions**
- **Stack depth optimization** to avoid compilation errors

## 🔒 Security Features
- Deadline checks for transaction validity
- Slippage protection
- Overflow/underflow protection (Solidity ^0.8.20)
- Input validation
- Clear error messages with short strings

## 🎯 ETH-KIPU Requirements Fulfillment

### Mandatory Requirements
✅ **All required functions implemented**:
- `addLiquidity()` - Add liquidity to token pairs
- `removeLiquidity()` - Remove liquidity from pairs  
- `swapExactTokensForTokens()` - Execute token swaps
- `getPrice()` - Get current token price ratio
- `getAmountOut()` - Calculate swap output amounts

✅ **Gas optimization implemented**  
✅ **Proper documentation provided**  
✅ **Successfully verified on Etherscan**  
✅ **Successfully verified by official verifier**  
✅ **No unnecessary features added**  
✅ **Proper storage variable handling with structs**  
✅ **No trading fees (pure AMM implementation)**

### Additional Achievements
✅ **NatSpec documentation**  
✅ **English documentation**  
✅ **Clear function naming**  
✅ **Efficient code organization**  
✅ **Verifier contract compatibility**  
✅ **Complete deployment on Sepolia testnet**

## 📊 Verification Test Results

The contract passed comprehensive testing by the official verifier:

### Initial State
- Pool: Empty
- TokenA Balance: 1000 TKA (available for testing)  
- TokenB Balance: 2000 TKB (available for testing)

### Test Sequence
1. **Liquidity Addition**: 1 TKA + 2 TKB → Pool established with K = 2
2. **Swap Test**: 0.1 TKA → 0.181818... TKB (mathematically correct)
3. **Liquidity Removal**: Complete withdrawal → 1.1 TKA + 1.818... TKB returned
4. **Mathematical Verification**: K constant maintained throughout all operations

## 📚 Development Environment
- **Solidity Version**: ^0.8.20
- **Network**: Sepolia Testnet
- **Compiler Optimization**: Enabled (200 runs)
- **Development Tools**: Remix IDE
- **Verification**: Etherscan + Official Verifier Contract

## 🔧 Testing
Successfully passed all verification tests including:
- ✅ Liquidity provision and removal
- ✅ Token swapping with correct calculations
- ✅ Price calculations and reserve management
- ✅ Event emissions
- ✅ Gas optimization validation
- ✅ Mathematical accuracy (constant product formula)
- ✅ No-fee implementation verification

## 📄 License
This project is licensed under the MIT License.

## 👨‍💻 Author
Eduardo Moreno  
ETH-KIPU Ethereum Developer Training Program

---

**🎉 Project Status: COMPLETED ✅**  
**Final Verification: PASSED ✅**  
**Date: July 5, 2025**
