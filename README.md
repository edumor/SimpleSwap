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
| **Contract Address** | [`0xFbCdF72b772B604A8A38d58F806B0bf5a4b2b3e6`](https://sepolia.etherscan.io/address/0xFbCdF72b772B604A8A38d58F806B0bf5a4b2b3e6) |
| **Type** | AMM Contract |
| **Network** | Sepolia Testnet |
| **Compiler** | Solidity v0.8.20 |
| **Optimization** | Enabled (200 runs) |
| **License** | MIT |
| **Verification Status** | ✅ [Verified on Etherscan](https://sepolia.etherscan.io/address/0xFbCdF72b772B604A8A38d58F806B0bf5a4b2b3e6#code) |
| **Purpose** | Main AMM implementation |

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

## 📋 Contract Verification
Successfully verified by the official verifier contract:
- Verifier Contract: [`0x9f8f02dab384dddf1591c3366069da3fb0018220`](https://sepolia.etherscan.io/address/0x9f8f02dab384dddf1591c3366069da3fb0018220)
- Verification Transaction: [`0xdc78187eb7b40a389c54b6ef137670375afbd8dabf240ff8099f08a311f9c5e3`](https://sepolia.etherscan.io/tx/0xdc78187eb7b40a389c54b6ef137670375afbd8dabf240ff8099f08a311f9c5e3)

## 🔍 Core Features

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
- Allows users to provide liquidity to token pairs
- Calculates and mints liquidity tokens
- Implements slippage protection with minimum amounts
- Returns actual amounts added and liquidity minted

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
- Enables liquidity providers to withdraw their tokens
- Burns liquidity tokens
- Returns underlying assets
- Includes slippage protection

### 3. Token Swapping
```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts)
```
- Executes token swaps using constant product formula
- Ensures minimum output amount (slippage protection)
- Returns array of input and output amounts
- Implements deadline for transaction validity

### 4. Price Oracle
```solidity
function getPrice(
    address tokenA,
    address tokenB
) external view returns (uint256)
```
- Returns current price ratio between tokens
- Uses 18 decimal precision
- Based on current reserves

### 5. Amount Calculator
```solidity
function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
) public pure returns (uint256)
```
- Calculates output amount for swaps
- Uses constant product formula (x * y = k)
- Pure function for gas efficiency

## 🏗 Technical Implementation

### State Variables
```solidity
mapping(address => mapping(address => uint256)) public reserves;
mapping(address => mapping(address => mapping(address => uint256))) public liquidityBalances;
mapping(address => mapping(address => uint256)) public totalLiquidity;
```

### Events
```solidity
event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
event LiquidityChange(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, uint256 liquidity, bool isAdded);
```

## ⚡ Optimization Features
- Gas-optimized storage patterns
- Efficient mathematical operations
- Minimal external calls
- Optimized for 200 runs in compiler
- Single-responsibility functions

## 🔒 Security Features
- Deadline checks for transaction validity
- Slippage protection
- Overflow/underflow protection (Solidity ^0.8.20)
- Input validation
- Clear error messages

## 🎯 ETH-KIPU Requirements Fulfillment

### Mandatory Requirements
✅ Implementation of all required functions  
✅ Gas optimization  
✅ Proper documentation  
✅ Successful verification  
✅ No unnecessary features  
✅ Proper storage variable handling

### Additional Achievements
✅ NatSpec documentation  
✅ English documentation  
✅ Clear function naming  
✅ Efficient code organization

## 📚 Development Environment
- Solidity Version: ^0.8.20
- Network: Sepolia Testnet
- Compiler Optimization: Enabled (200 runs)
- Development Tools: Remix IDE

## 🔧 Testing
Successfully passed all verification tests including:
- Liquidity provision
- Token swapping
- Price calculations
- Reserve management
- Event emissions

## 📄 License
This project is licensed under the MIT License.

## 👨‍💻 Author
Developed as part of ETH-KIPU Ethereum Developer Training Program.
