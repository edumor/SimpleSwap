// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleSwap - Flattened Version
 * @notice A minimal automated market maker (AMM) for token swapping
 * @dev Implements a constant product formula similar to Uniswap
 * @author Student Implementation for University Exam
 * 
 * FLATTENED CONTRACT - Ready for Etherscan verification
 * Original file: SimpleSwap.sol
 * Flattened on: 2025-06-28
 */
contract SimpleSwap {
    
    /// @notice Pool structure to store reserves and liquidity data
    struct Pool {
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        mapping(address => uint256) liquidity;
    }
    
    /// @notice Mapping from pool ID to pool data
    mapping(bytes32 => Pool) public pools;
    
    // ===== EVENTS =====
    
    /**
     * @dev Emitted when liquidity is added to a pool
     * @param user Address that added liquidity
     * @param tokenA Address of first token
     * @param tokenB Address of second token
     * @param amountA Amount of tokenA added
     * @param amountB Amount of tokenB added
     * @param liquidity Liquidity tokens minted
     */
    event LiquidityAdded(
        address indexed user, 
        address tokenA, 
        address tokenB, 
        uint256 amountA, 
        uint256 amountB, 
        uint256 liquidity
    );
    
    /**
     * @dev Emitted when liquidity is removed from a pool
     * @param user Address that removed liquidity
     * @param tokenA Address of first token
     * @param tokenB Address of second token
     * @param amountA Amount of tokenA removed
     * @param amountB Amount of tokenB removed
     * @param liquidity Liquidity tokens burned
     */
    event LiquidityRemoved(
        address indexed user, 
        address tokenA, 
        address tokenB, 
        uint256 amountA, 
        uint256 amountB, 
        uint256 liquidity
    );
    
    /**
     * @dev Emitted when a token swap occurs
     * @param user Address that performed the swap
     * @param tokenIn Address of input token
     * @param amountIn Amount of input token
     * @param tokenOut Address of output token
     * @param amountOut Amount of output token
     */
    event Swap(
        address indexed user, 
        address tokenIn, 
        uint256 amountIn, 
        address tokenOut, 
        uint256 amountOut
    );

    // ===== MAIN FUNCTIONS =====

    /**
     * @notice Adds liquidity to a token pair pool
     * @dev Creates pool if it doesn't exist, calculates optimal amounts based on current reserves
     * @param tokenA Address of first token
     * @param tokenB Address of second token
     * @param amountADesired Desired amount of tokenA to add
     * @param amountBDesired Desired amount of tokenB to add
     * @param amountAMin Minimum amount of tokenA (slippage protection)
     * @param amountBMin Minimum amount of tokenB (slippage protection)
     * @param to Address to receive liquidity tokens
     * @param deadline Transaction deadline timestamp
     * @return amountA Actual amount of tokenA added
     * @return amountB Actual amount of tokenB added
     * @return liquidity Amount of liquidity tokens minted
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(block.timestamp <= deadline, "EXPIRED");
        require(tokenA != tokenB, "SAME_TOKEN");
        require(tokenA != address(0) && tokenB != address(0), "ZERO_ADDR");
        require(to != address(0), "ZERO_TO");
        require(amountADesired > 0 && amountBDesired > 0, "ZERO_AMOUNT");

        bytes32 poolId = _getPoolId(tokenA, tokenB);
        Pool storage pool = pools[poolId];

        (amountA, amountB) = _calculateLiquidityAmounts(
            pool.reserveA, 
            pool.reserveB, 
            amountADesired, 
            amountBDesired, 
            amountAMin, 
            amountBMin
        );

        // Transfer tokens with error handling
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "TRANSFER_A_FAIL");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "TRANSFER_B_FAIL");

        // Calculate liquidity tokens to mint
        if (pool.totalLiquidity == 0) {
            liquidity = _sqrt(amountA * amountB);
            require(liquidity > 1000, "MIN_LIQ"); // Minimum liquidity lock
            liquidity -= 1000; // Burn minimum liquidity
        } else {
            liquidity = _min(
                (amountA * pool.totalLiquidity) / pool.reserveA,
                (amountB * pool.totalLiquidity) / pool.reserveB
            );
        }
        require(liquidity > 0, "NO_LIQ_MINT");

        // Update pool state
        pool.reserveA += amountA;
        pool.reserveB += amountB;
        pool.totalLiquidity += liquidity;
        pool.liquidity[to] += liquidity;

        emit LiquidityAdded(to, tokenA, tokenB, amountA, amountB, liquidity);
    }

    /**
     * @notice Removes liquidity from a token pair pool
     * @dev Burns liquidity tokens and returns proportional amounts of both tokens
     * @param tokenA Address of first token
     * @param tokenB Address of second token
     * @param liquidityAmount Amount of liquidity tokens to burn
     * @param amountAMin Minimum amount of tokenA to receive
     * @param amountBMin Minimum amount of tokenB to receive
     * @param to Address to receive tokens
     * @param deadline Transaction deadline timestamp
     * @return amountA Amount of tokenA received
     * @return amountB Amount of tokenB received
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidityAmount,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "EXPIRED");
        require(tokenA != tokenB, "SAME_TOKEN");
        require(tokenA != address(0) && tokenB != address(0), "ZERO_ADDR");
        require(to != address(0), "ZERO_TO");
        require(liquidityAmount > 0, "ZERO_LIQ");

        bytes32 poolId = _getPoolId(tokenA, tokenB);
        Pool storage pool = pools[poolId];

        require(liquidityAmount <= pool.liquidity[msg.sender], "INSUF_LIQ");
        require(pool.totalLiquidity > 0, "NO_POOL");

        // Calculate amounts to return
        amountA = (liquidityAmount * pool.reserveA) / pool.totalLiquidity;
        amountB = (liquidityAmount * pool.reserveB) / pool.totalLiquidity;
        require(amountA >= amountAMin, "INSUF_A");
        require(amountB >= amountBMin, "INSUF_B");

        // Update pool state
        pool.liquidity[msg.sender] -= liquidityAmount;
        pool.totalLiquidity -= liquidityAmount;
        pool.reserveA -= amountA;
        pool.reserveB -= amountB;

        // Transfer tokens with error handling
        require(IERC20(tokenA).transfer(to, amountA), "TRANSFER_A_FAIL");
        require(IERC20(tokenB).transfer(to, amountB), "TRANSFER_B_FAIL");

        emit LiquidityRemoved(to, tokenA, tokenB, amountA, amountB, liquidityAmount);
    }

    /**
     * @notice Swaps exact amount of input tokens for output tokens
     * @dev Uses constant product formula without fees
     * @param amountIn Exact amount of input tokens
     * @param amountOutMin Minimum amount of output tokens (slippage protection)
     * @param path Array containing [tokenIn, tokenOut]
     * @param to Address to receive output tokens
     * @param deadline Transaction deadline timestamp
     * @return amounts Array with [amountIn, amountOut]
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(block.timestamp <= deadline, "EXPIRED");
        require(path.length == 2, "INVALID_PATH");
        require(to != address(0), "ZERO_TO");
        require(amountIn > 0, "ZERO_IN");

        address tokenIn = path[0];
        address tokenOut = path[1];
        require(tokenIn != tokenOut, "SAME_TOKEN");
        require(tokenIn != address(0) && tokenOut != address(0), "ZERO_ADDR");

        bytes32 poolId = _getPoolId(tokenIn, tokenOut);
        Pool storage pool = pools[poolId];
        require(pool.totalLiquidity > 0, "NO_POOL");

        (uint256 reserveIn, uint256 reserveOut) = _getReserves(tokenIn, tokenOut, pool.reserveA, pool.reserveB);
        require(reserveIn > 0 && reserveOut > 0, "NO_LIQ");

        uint256 amountOut = _getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "INSUF_OUT");
        require(amountOut < reserveOut, "INSUF_LIQ");

        // Transfer input tokens
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "TRANSFER_IN_FAIL");

        // Update reserves
        if (tokenIn < tokenOut) {
            pool.reserveA += amountIn;
            pool.reserveB -= amountOut;
        } else {
            pool.reserveB += amountIn;
            pool.reserveA -= amountOut;
        }
        
        // Transfer output tokens
        require(IERC20(tokenOut).transfer(to, amountOut), "TRANSFER_OUT_FAIL");

        // Return amounts array as required by interface
        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;

        emit Swap(to, tokenIn, amountIn, tokenOut, amountOut);
    }

    /**
     * @notice Gets the current price of tokenA in terms of tokenB
     * @dev Returns price as tokenB per tokenA with 18 decimals precision
     * @param tokenA Address of base token
     * @param tokenB Address of quote token
     * @return price Price of tokenA in tokenB (scaled by 1e18)
     */
    function getPrice(address tokenA, address tokenB) external view returns (uint256 price) {
        require(tokenA != tokenB, "SAME_TOKEN");
        require(tokenA != address(0) && tokenB != address(0), "ZERO_ADDR");
        
        bytes32 poolId = _getPoolId(tokenA, tokenB);
        Pool storage pool = pools[poolId];
        require(pool.reserveA > 0 && pool.reserveB > 0, "NO_LIQ");
        
        (uint256 reserveA, uint256 reserveB) = tokenA < tokenB 
            ? (pool.reserveA, pool.reserveB) 
            : (pool.reserveB, pool.reserveA);
        
        price = (reserveB * 1e18) / reserveA;
    }

    /**
     * @notice Calculates output amount for a given input amount and reserves
     * @dev Uses constant product formula: x * y = k without fees
     * @param amountIn Input amount
     * @param reserveIn Input token reserve
     * @param reserveOut Output token reserve
     * @return amountOut Output amount
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut) {
        return _getAmountOut(amountIn, reserveIn, reserveOut);
    }

    // ===== INTERNAL HELPER FUNCTIONS =====

    /**
     * @dev Internal function to calculate output amount using constant product formula
     * @param amountIn Input amount
     * @param reserveIn Input token reserve
     * @param reserveOut Output token reserve
     * @return amountOut Output amount
     */
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "ZERO_IN");
        require(reserveIn > 0 && reserveOut > 0, "ZERO_RESERVES");
        
        // Pure constant product formula without fees: x * y = k
        // amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    /**
     * @dev Generates unique pool identifier for token pair
     * @param tokenA First token address
     * @param tokenB Second token address
     * @return Pool identifier hash
     */
    function _getPoolId(address tokenA, address tokenB) internal pure returns (bytes32) {
        return tokenA < tokenB 
            ? keccak256(abi.encodePacked(tokenA, tokenB)) 
            : keccak256(abi.encodePacked(tokenB, tokenA));
    }

    /**
     * @dev Gets reserves in correct order based on token addresses
     * @param tokenA First token address
     * @param tokenB Second token address
     * @param reserveA Reserve of tokenA
     * @param reserveB Reserve of tokenB
     * @return reserveIn Reserve of input token
     * @return reserveOut Reserve of output token
     */
    function _getReserves(
        address tokenA, 
        address tokenB, 
        uint256 reserveA, 
        uint256 reserveB
    ) internal pure returns (uint256 reserveIn, uint256 reserveOut) {
        return tokenA < tokenB ? (reserveA, reserveB) : (reserveB, reserveA);
    }

    /**
     * @dev Calculates optimal liquidity amounts based on current pool reserves
     * @param reserveA Current reserve of tokenA
     * @param reserveB Current reserve of tokenB
     * @param amountADesired Desired amount of tokenA
     * @param amountBDesired Desired amount of tokenB
     * @param amountAMin Minimum amount of tokenA
     * @param amountBMin Minimum amount of tokenB
     * @return amountA Optimal amount of tokenA
     * @return amountB Optimal amount of tokenB
     */
    function _calculateLiquidityAmounts(
        uint256 reserveA,
        uint256 reserveB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal pure returns (uint256 amountA, uint256 amountB) {
        if (reserveA == 0 && reserveB == 0) {
            // First liquidity addition
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            // Calculate optimal amounts based on current ratio
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "INSUF_B");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "INSUF_A");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    /**
     * @dev Calculates square root using Babylonian method
     * @param y Input value
     * @return z Square root of y
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
     * @dev Returns minimum of two numbers
     * @param a First number
     * @param b Second number
     * @return Minimum value
     */
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

/**
 * @title IERC20 Interface
 * @notice Minimal ERC20 interface for token interactions
 * @dev Contains only the functions needed by SimpleSwap
 */
interface IERC20 {
    /**
     * @notice Transfers tokens to a specified address
     * @param to Recipient address
     * @param value Amount to transfer
     * @return success True if transfer succeeded
     */
    function transfer(address to, uint256 value) external returns (bool success);
    
    /**
     * @notice Transfers tokens from one address to another
     * @param from Sender address
     * @param to Recipient address
     * @param value Amount to transfer
     * @return success True if transfer succeeded
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
}
