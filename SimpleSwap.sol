/**
 *Submitted for verification at Etherscan.io on 2025-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleSwap
 * @notice An automated market maker (AMM) for token swapping without fees
 * @dev Implements constant product formula x * y = k without any fees
 * @author Eduardo Moreno
 * @custom:security-contact eduardomoreno2503@gmail.com
 */
contract SimpleSwap {
    /// @notice Stores the reserve balances for each token pair
    /// @dev Maps tokenA => tokenB => reserve amount
    mapping(address => mapping(address => uint256)) public reserves;
    
    /// @notice Stores liquidity token balances for each user in each pair
    /// @dev Maps tokenA => tokenB => user => liquidity balance
    mapping(address => mapping(address => mapping(address => uint256))) public liquidityBalances;
    
    /// @notice Total liquidity tokens issued for each trading pair
    /// @dev Maps tokenA => tokenB => total liquidity
    mapping(address => mapping(address => uint256)) public totalLiquidity;

    /// @notice Emitted when tokens are swapped
    /// @param tokenIn The input token address
    /// @param tokenOut The output token address
    /// @param amountIn The amount of input tokens
    /// @param amountOut The amount of output tokens
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /// @notice Emitted when liquidity is added or removed
    /// @param tokenA The first token of the pair
    /// @param tokenB The second token of the pair
    /// @param amountA The amount of first token
    /// @param amountB The amount of second token
    /// @param liquidity The amount of liquidity tokens
    /// @param isAdded True if liquidity was added, false if removed
    event LiquidityAction(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, uint256 liquidity, bool isAdded);

    /**
     * @notice Internal function to calculate liquidity tokens to mint
     * @dev Uses sqrt of product for first provision, proportional for subsequent ones
     * @param tokenA First token of the pair
     * @param tokenB Second token of the pair
     * @param amountA Amount of first token
     * @param amountB Amount of second token
     * @param isFirstProvision True if this is the first liquidity provision
     * @return Amount of liquidity tokens to mint
     */
    function _calculateLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        bool isFirstProvision
    ) internal view returns (uint256) {
        if (isFirstProvision) {
            return _sqrt(amountA * amountB);
        }
        uint256 totalLiq = totalLiquidity[tokenA][tokenB];
        return _min(
            (amountA * totalLiq) / reserves[tokenA][tokenB],
            (amountB * totalLiq) / reserves[tokenB][tokenA]
        );
    }

    /**
     * @notice Adds liquidity to a token pair pool
     * @dev Transfers tokens from user to contract and mints liquidity tokens
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param amountADesired Amount of first token to add
     * @param amountBDesired Amount of second token to add
     * @param amountAMin Minimum amount of first token to add
     * @param amountBMin Minimum amount of second token to add
     * @param to Address that will receive the liquidity tokens
     * @param deadline Maximum timestamp until which the transaction is valid
     * @return amountA The actual amount of first token added
     * @return amountB The actual amount of second token added
     * @return liquidity The amount of liquidity tokens minted
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256, uint256, uint256) {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");
        require(amountADesired >= amountAMin && amountBDesired >= amountBMin, "SimpleSwap: INSUFFICIENT_AMOUNT");

        bool isFirst = reserves[tokenA][tokenB] == 0;
        uint256 liquidity = _calculateLiquidity(tokenA, tokenB, amountADesired, amountBDesired, isFirst);

        _transferFrom(tokenA, msg.sender, address(this), amountADesired);
        _transferFrom(tokenB, msg.sender, address(this), amountBDesired);

        reserves[tokenA][tokenB] += amountADesired;
        reserves[tokenB][tokenA] += amountBDesired;
        liquidityBalances[tokenA][tokenB][to] += liquidity;
        totalLiquidity[tokenA][tokenB] += liquidity;

        emit LiquidityAction(tokenA, tokenB, amountADesired, amountBDesired, liquidity, true);
        return (amountADesired, amountBDesired, liquidity);
    }

    /**
     * @notice Removes liquidity from a token pair pool
     * @dev Burns liquidity tokens and returns underlying tokens
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @param liquidity Amount of liquidity tokens to burn
     * @param amountAMin Minimum amount of first token to receive
     * @param amountBMin Minimum amount of second token to receive
     * @param to Address that will receive the tokens
     * @param deadline Maximum timestamp until which the transaction is valid
     * @return amountA The amount of first token returned
     * @return amountB The amount of second token returned
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");

        uint256 totalLiq = totalLiquidity[tokenA][tokenB];
        amountA = (liquidity * reserves[tokenA][tokenB]) / totalLiq;
        amountB = (liquidity * reserves[tokenB][tokenA]) / totalLiq;
        require(amountA >= amountAMin && amountB >= amountBMin, "SimpleSwap: INSUFFICIENT_AMOUNT");

        liquidityBalances[tokenA][tokenB][msg.sender] -= liquidity;
        totalLiquidity[tokenA][tokenB] -= liquidity;
        reserves[tokenA][tokenB] -= amountA;
        reserves[tokenB][tokenA] -= amountB;

        _transfer(tokenA, to, amountA);
        _transfer(tokenB, to, amountB);

        emit LiquidityAction(tokenA, tokenB, amountA, amountB, liquidity, false);
    }

    /**
     * @notice Swaps exact amount of input tokens for output tokens
     * @dev Uses constant product formula without fees
     * @param amountIn Amount of input tokens to swap
     * @param amountOutMin Minimum amount of output tokens to receive
     * @param path Array containing [tokenIn, tokenOut] addresses
     * @param to Address that will receive the output tokens
     * @param deadline Maximum timestamp until which the transaction is valid
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");
        require(path.length == 2, "SimpleSwap: INVALID_PATH");

        address tokenIn = path[0];
        address tokenOut = path[1];
        uint256 amountOut = getAmountOut(amountIn, reserves[tokenIn][tokenOut], reserves[tokenOut][tokenIn]);
        require(amountOut >= amountOutMin, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");

        _transferFrom(tokenIn, msg.sender, address(this), amountIn);
        reserves[tokenIn][tokenOut] += amountIn;
        reserves[tokenOut][tokenIn] -= amountOut;
        _transfer(tokenOut, to, amountOut);

        emit Swap(tokenIn, tokenOut, amountIn, amountOut);
    }

    /**
     * @notice Gets the current price of tokenA in terms of tokenB
     * @dev Price is returned with 18 decimal places
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @return Price of tokenA in terms of tokenB multiplied by 1e18
     */
    function getPrice(address tokenA, address tokenB) external view returns (uint256) {
        return (reserves[tokenB][tokenA] * 1e18) / reserves[tokenA][tokenB];
    }

    /**
     * @notice Calculates the output amount for a swap
     * @dev Uses constant product formula: amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
     * @param amountIn Amount of input tokens
     * @param reserveIn Reserve of input token
     * @param reserveOut Reserve of output token
     * @return Amount of output tokens to receive
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "SimpleSwap: INVALID_AMOUNTS");
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /**
     * @dev Internal function to handle transferFrom operations
     * @param token The token to transfer
     * @param from Address to transfer from
     * @param to Address to transfer to
     * @param amount Amount of tokens to transfer
     */
    function _transferFrom(address token, address from, address to, uint256 amount) internal {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount)
        );
        require(success, "SimpleSwap: TRANSFER_FROM_FAILED");
    }

    /**
     * @dev Internal function to handle transfer operations
     * @param token The token to transfer
     * @param to Address to transfer to
     * @param amount Amount of tokens to transfer
     */
    function _transfer(address token, address to, uint256 amount) internal {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success, "SimpleSwap: TRANSFER_FAILED");
    }

    /**
     * @dev Internal function to calculate square root
     * @param y The number to calculate the square root of
     * @return z The square root of y
     */
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Internal function to return the minimum of two numbers
     * @param x First number
     * @param y Second number
     * @return The smaller of the two numbers
     */
    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }
}
