/**
 *Submitted for verification at Etherscan.io on 2025-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleSwap
 * @notice An optimized automated market maker (AMM) for token swapping without fees
 * @dev Implements constant product formula x * y = k without any fees using structs for gas optimization
 * @author Eduardo Moreno - Optimized Version
 * @custom:security-contact eduardomoreno2503@gmail.com
 */
contract SimpleSwap {
    
    /// @notice Struct to store all reserve and liquidity data for a trading pair
    /// @dev Packs related data together to minimize storage slots and gas costs
    struct PairData {
        uint256 reserveA;           // Reserve of tokenA
        uint256 reserveB;           // Reserve of tokenB
        uint256 totalLiquidity;     // Total liquidity tokens issued
    }
    
    /// @notice Struct to cache storage values during function execution
    /// @dev Used to minimize storage reads/writes within functions
    struct LocalPairData {
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        bool isFirstProvision;
    }
    
    /// @notice Maps token pair hash to pair data
    /// @dev Uses keccak256(abi.encodePacked(tokenA, tokenB)) as key for deterministic ordering
    mapping(bytes32 => PairData) public pairs;
    
    /// @notice Stores liquidity token balances for each user in each pair
    /// @dev Maps pair hash => user => liquidity balance
    mapping(bytes32 => mapping(address => uint256)) public liquidityBalances;

    /// @notice Emitted when tokens are swapped
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /// @notice Emitted when liquidity is added or removed
    event LiquidityAction(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, uint256 liquidity, bool isAdded);

    /**
     * @notice Internal function to get deterministic pair hash
     * @dev Ensures consistent ordering regardless of input order
     */
    function _getPairHash(address tokenA, address tokenB) internal pure returns (bytes32, bool) {
        if (tokenA < tokenB) {
            return (keccak256(abi.encodePacked(tokenA, tokenB)), false);
        } else {
            return (keccak256(abi.encodePacked(tokenB, tokenA)), true);
        }
    }

    /**
     * @notice Internal function to load pair data from storage (single read)
     * @dev Reads all pair data in one storage access to minimize gas costs
     */
    function _loadPairData(address tokenA, address tokenB) internal view returns (LocalPairData memory localData, bytes32 pairHash, bool reversed) {
        (pairHash, reversed) = _getPairHash(tokenA, tokenB);
        PairData storage pairData = pairs[pairHash];
        
        if (reversed) {
            localData = LocalPairData({
                reserveA: pairData.reserveB,
                reserveB: pairData.reserveA,
                totalLiquidity: pairData.totalLiquidity,
                isFirstProvision: pairData.totalLiquidity == 0
            });
        } else {
            localData = LocalPairData({
                reserveA: pairData.reserveA,
                reserveB: pairData.reserveB,
                totalLiquidity: pairData.totalLiquidity,
                isFirstProvision: pairData.totalLiquidity == 0
            });
        }
    }

    /**
     * @notice Internal function to save pair data to storage (single write)
     * @dev Updates all pair data in one storage access to minimize gas costs
     */
    function _savePairData(bytes32 pairHash, bool reversed, LocalPairData memory localData) internal {
        PairData storage pairData = pairs[pairHash];
        
        if (reversed) {
            pairData.reserveA = localData.reserveB;
            pairData.reserveB = localData.reserveA;
        } else {
            pairData.reserveA = localData.reserveA;
            pairData.reserveB = localData.reserveB;
        }
        pairData.totalLiquidity = localData.totalLiquidity;
    }

    /**
     * @notice Internal function to calculate liquidity tokens to mint
     * @dev Uses sqrt of product for first provision, proportional for subsequent ones
     */
    function _calculateLiquidity(
        uint256 amountA,
        uint256 amountB,
        LocalPairData memory localData
    ) internal pure returns (uint256) {
        if (localData.isFirstProvision) {
            return _sqrt(amountA * amountB);
        }
        return _min(
            (amountA * localData.totalLiquidity) / localData.reserveA,
            (amountB * localData.totalLiquidity) / localData.reserveB
        );
    }

    /**
     * @notice Adds liquidity to a token pair pool
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(block.timestamp <= deadline, "EXPIRED");
        require(amountADesired >= amountAMin && amountBDesired >= amountBMin, "INSUFFICIENT_AMOUNT");

        (LocalPairData memory data, bytes32 hash, bool rev) = _loadPairData(tokenA, tokenB);
        
        liquidity = _calculateLiquidity(amountADesired, amountBDesired, data);

        _transferFrom(tokenA, msg.sender, address(this), amountADesired);
        _transferFrom(tokenB, msg.sender, address(this), amountBDesired);

        data.reserveA += amountADesired;
        data.reserveB += amountBDesired;
        data.totalLiquidity += liquidity;

        _savePairData(hash, rev, data);
        liquidityBalances[hash][to] += liquidity;

        emit LiquidityAction(tokenA, tokenB, amountADesired, amountBDesired, liquidity, true);
        return (amountADesired, amountBDesired, liquidity);
    }

    /**
     * @notice Removes liquidity from a token pair pool
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
        require(block.timestamp <= deadline, "EXPIRED");

        (LocalPairData memory data, bytes32 hash, bool rev) = _loadPairData(tokenA, tokenB);
        
        amountA = (liquidity * data.reserveA) / data.totalLiquidity;
        amountB = (liquidity * data.reserveB) / data.totalLiquidity;
        require(amountA >= amountAMin && amountB >= amountBMin, "INSUFFICIENT_AMOUNT");
        require(liquidityBalances[hash][msg.sender] >= liquidity, "INSUFFICIENT_LIQUIDITY");

        data.reserveA -= amountA;
        data.reserveB -= amountB;
        data.totalLiquidity -= liquidity;

        _savePairData(hash, rev, data);
        liquidityBalances[hash][msg.sender] -= liquidity;

        _transfer(tokenA, to, amountA);
        _transfer(tokenB, to, amountB);

        emit LiquidityAction(tokenA, tokenB, amountA, amountB, liquidity, false);
    }

    /**
     * @notice Swaps exact amount of input tokens for output tokens - VERIFIER COMPATIBLE
     * @dev Modified to match verifier interface (no return value)
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
        require(block.timestamp <= deadline, "EXPIRED");
        require(path.length == 2, "INVALID_PATH");

        (LocalPairData memory data, bytes32 hash, bool rev) = _loadPairData(path[0], path[1]);
        
        uint256 amountOut = getAmountOut(amountIn, data.reserveA, data.reserveB);
        require(amountOut >= amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");

        _transferFrom(path[0], msg.sender, address(this), amountIn);

        data.reserveA += amountIn;
        data.reserveB -= amountOut;

        _savePairData(hash, rev, data);
        _transfer(path[1], to, amountOut);

        emit Swap(path[0], path[1], amountIn, amountOut);
    }

    /**
     * @notice Gets the current price of tokenA in terms of tokenB
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token  
     * @return price Price of tokenA in terms of tokenB
     */
    function getPrice(address tokenA, address tokenB) external view returns (uint256 price) {
        (LocalPairData memory data,,) = _loadPairData(tokenA, tokenB);
        return (data.reserveB * 1e18) / data.reserveA;
    }

    /**
     * @notice Gets reserve amounts for a token pair
     */
    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB) {
        (LocalPairData memory data,,) = _loadPairData(tokenA, tokenB);
        return (data.reserveA, data.reserveB);
    }

    /**
     * @notice Calculates the output amount for a swap
     * @param amountIn Amount of input tokens
     * @param reserveIn Reserve of input token
     * @param reserveOut Reserve of output token
     * @return amountOut Amount of output tokens to receive
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "INVALID_AMOUNTS");
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /**
     * @dev Internal function to handle transferFrom operations
     */
    function _transferFrom(address token, address from, address to, uint256 amount) internal {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount)
        );
        require(success, "TRANSFER_FROM_FAILED");
    }

    /**
     * @dev Internal function to handle transfer operations
     */
    function _transfer(address token, address to, uint256 amount) internal {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success, "TRANSFER_FAILED");
    }

    /**
     * @dev Internal function to calculate square root
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
     */
    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }
}
