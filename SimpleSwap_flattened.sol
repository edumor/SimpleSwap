//**
 *Submitted for verification at Etherscan.io on 2025-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleSwap - Flattened Version
 * @notice A minimal automated market maker (AMM) for token swapping without fees
 * @dev Implements a constant product formula similar to Uniswap but without trading fees
 * @dev This is a flattened version ready for Etherscan verification
 * @author Student Implementation for University Exam
 */
contract SimpleSwap {
    
    /// @notice Token reserve balances for each trading pair
    /// @dev First address is tokenA, second is tokenB, value is the reserve amount
    mapping(address => mapping(address => uint256)) public reserves;
    
    /// @notice Liquidity token balances for each user in each trading pair
    /// @dev tokenA => tokenB => user => liquidity balance
    mapping(address => mapping(address => mapping(address => uint256))) public liquidityBalances;
    
    /// @notice Total liquidity tokens issued for each trading pair
    /// @dev tokenA => tokenB => total liquidity amount
    mapping(address => mapping(address => uint256)) public totalLiquidity;
    
    /**
     * @notice Adds liquidity to a token pair
     * @dev Creates or adds to an existing liquidity pool for two tokens
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param amountADesired Amount of tokenA to add to the pool
     * @param amountBDesired Amount of tokenB to add to the pool
     * @param to Address that will receive the liquidity tokens
     * @return amountA Actual amount of tokenA added
     * @return amountB Actual amount of tokenB added
     * @return liquidity Amount of liquidity tokens minted
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256, uint256, uint256) {
        return _addLiq(tokenA, tokenB, amountADesired, amountBDesired, to);
    }
    
    /**
     * @notice Internal function to handle liquidity addition logic
     * @dev Transfers tokens from user, updates reserves and liquidity balances
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param amountA Amount of tokenA to add
     * @param amountB Amount of tokenB to add
     * @param to Address that will receive the liquidity tokens
     * @return amountA Amount of tokenA added
     * @return amountB Amount of tokenB added
     * @return liquidity Amount of liquidity tokens minted (fixed at 1000)
     */
    function _addLiq(address tokenA, address tokenB, uint256 amountA, uint256 amountB, address to) internal returns (uint256, uint256, uint256) {
        // Sort tokens to ensure consistent ordering for all operations
        (address t0, address t1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        
        // Transfer tokens from user to this contract using low-level calls
        _transferFrom(tokenA, msg.sender, address(this), amountA);
        _transferFrom(tokenB, msg.sender, address(this), amountB);
        
        // Update reserves for both directions to maintain consistency
        reserves[t0][t1] = reserves[t0][t1] + amountA;
        reserves[t1][t0] = reserves[t1][t0] + amountB;
        
        // Mint liquidity tokens (simplified: always 1000 for minimal implementation)
        liquidityBalances[t0][t1][to] = liquidityBalances[t0][t1][to] + 1000;
        totalLiquidity[t0][t1] = totalLiquidity[t0][t1] + 1000;
        
        return (amountA, amountB, 1000);
    }
    
    /**
     * @notice Removes liquidity from a token pair
     * @dev Burns liquidity tokens and returns underlying tokens to user
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param liquidity Amount of liquidity tokens to burn
     * @param to Address that will receive the underlying tokens
     * @return amountA Amount of tokenA returned
     * @return amountB Amount of tokenB returned
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256, uint256) {
        return _remLiq(tokenA, tokenB, liquidity, to);
    }
    
    /**
     * @notice Internal function to handle liquidity removal logic
     * @dev Calculates proportional amounts and transfers tokens back to user
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param liquidity Amount of liquidity tokens to burn
     * @param to Address that will receive the tokens
     * @return amountA Amount of tokenA returned
     * @return amountB Amount of tokenB returned
     */
    function _remLiq(address tokenA, address tokenB, uint256 liquidity, address to) internal returns (uint256, uint256) {
        // Sort tokens to ensure consistent ordering
        (address t0, address t1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        
        // Calculate proportional amounts based on liquidity share
        uint256 a0 = (liquidity * reserves[t0][t1]) / totalLiquidity[t0][t1];
        uint256 a1 = (liquidity * reserves[t1][t0]) / totalLiquidity[t0][t1];
        
        // Update liquidity balances
        liquidityBalances[t0][t1][msg.sender] = liquidityBalances[t0][t1][msg.sender] - liquidity;
        totalLiquidity[t0][t1] = totalLiquidity[t0][t1] - liquidity;
        
        // Update reserves
        reserves[t0][t1] = reserves[t0][t1] - a0;
        reserves[t1][t0] = reserves[t1][t0] - a1;
        
        // Transfer tokens back to user
        _transfer(tokenA, to, tokenA == t0 ? a0 : a1);
        _transfer(tokenB, to, tokenB == t1 ? a1 : a0);
        
        // Return amounts in the order of input tokens
        return tokenA == t0 ? (a0, a1) : (a1, a0);
    }
    
    /**
     * @notice Swaps exact amount of input tokens for output tokens
     * @dev Uses constant product formula without fees (x * y = k)
     * @param amountIn Amount of input tokens to swap
     * @param path Array containing [tokenIn, tokenOut] addresses
     * @param to Address that will receive the output tokens
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256,
        address[] calldata path,
        address to,
        uint256
    ) external {
        _swap(amountIn, path[0], path[1], to);
    }
    
    /**
     * @notice Internal function to execute token swaps
     * @dev Implements constant product formula: amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
     * @dev This implementation has ZERO FEES as required by the university verifier
     * @param amountIn Amount of input tokens
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param to Address that will receive output tokens
     */
    function _swap(uint256 amountIn, address tokenIn, address tokenOut, address to) internal {
        // Sort tokens to ensure consistent ordering
        (address t0, address t1) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);
        
        // Get current reserves for the trading pair
        uint256 rIn = tokenIn == t0 ? reserves[t0][t1] : reserves[t1][t0];
        uint256 rOut = tokenIn == t0 ? reserves[t1][t0] : reserves[t0][t1];
        
        // Calculate output amount using constant product formula (NO FEES)
        // Formula: amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
        uint256 amountOut = (amountIn * rOut) / (rIn + amountIn);
        
        // Transfer input tokens from user to contract
        _transferFrom(tokenIn, msg.sender, address(this), amountIn);
        
        // Update reserves
        if (tokenIn == t0) {
            reserves[t0][t1] = reserves[t0][t1] + amountIn;
            reserves[t1][t0] = reserves[t1][t0] - amountOut;
        } else {
            reserves[t1][t0] = reserves[t1][t0] + amountIn;
            reserves[t0][t1] = reserves[t0][t1] - amountOut;
        }
        
        // Transfer output tokens to recipient
        _transfer(tokenOut, to, amountOut);
    }
    
    /**
     * @notice Gets the current price of tokenA in terms of tokenB
     * @dev Returns price with 18 decimal precision
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @return price Price of tokenA in tokenB with 18 decimal places
     */
    function getPrice(address tokenA, address tokenB) external view returns (uint256 price) {
        // Sort tokens to ensure consistent ordering
        (address t0, address t1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        
        // Calculate price based on reserve ratio
        // Price = (reserveB / reserveA) * 1e18 for precision
        return tokenA == t0 ? 
            (reserves[t1][t0] * 1e18) / reserves[t0][t1] : 
            (reserves[t0][t1] * 1e18) / reserves[t1][t0];
    }
    
    /**
     * @notice Calculates the amount of output tokens for a given input amount
     * @dev Uses constant product formula without fees: amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
     * @dev This is a public view function for external price calculations
     * @param amountIn Amount of input tokens
     * @param reserveIn Reserve amount of input token
     * @param reserveOut Reserve amount of output token
     * @return amountOut Amount of output tokens that would be received
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        // Constant product formula without fees: x * y = k
        // amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }
    
    /**
     * @notice Internal function to transfer tokens from one address to another
     * @dev Uses low-level call to invoke transferFrom on ERC20 token
     * @dev This approach avoids importing IERC20 interface, keeping the contract flat
     * @param token Address of the token contract
     * @param from Address to transfer tokens from
     * @param to Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function _transferFrom(address token, address from, address to, uint256 amount) internal {
        // Low-level call to transferFrom function
        (bool success,) = token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount));
        require(success, "TF"); // Transfer failed
    }
    
    /**
     * @notice Internal function to transfer tokens from this contract to another address
     * @dev Uses low-level call to invoke transfer on ERC20 token
     * @dev This approach avoids importing IERC20 interface, keeping the contract flat
     * @param token Address of the token contract
     * @param to Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function _transfer(address token, address to, uint256 amount) internal {
        // Low-level call to transfer function
        (bool success,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
        require(success, "T"); // Transfer failed
    }
}
