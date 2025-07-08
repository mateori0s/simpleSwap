// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SimpleSwap Smart Contract
/// @author mateori0s
/// @notice Implements Uniswap-like add/remove liquidity and token swap logic
contract SimpleSwap is ERC20 {
    /// @notice ERC20 token A
    IERC20 public immutable tokenA;
    /// @notice ERC20 token B
    IERC20 public immutable tokenB;

    /// @notice Initializes the pool with the token pair and sets LP token details
    /// @param _tokenA Address of token A
    /// @param _tokenB Address of token B
    constructor(address _tokenA, address _tokenB) ERC20("SimpleSwap Token", "SST") {
        require(_tokenA != _tokenB, "Identical tokens");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Adds liquidity to the pool and mints LP tokens to `to`
    /// @dev Calculates proportional contribution based on reserves
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(_tokenA == address(tokenA) && _tokenB == address(tokenB), "Invalid tokens");
        require(block.timestamp <= deadline, "Expired");

        uint256 totalLiquidity = totalSupply();

        if (totalLiquidity > 0) {
            // Calculate optimal B given A to maintain price ratio
            uint256 balanceA = tokenA.balanceOf(address(this));
            uint256 balanceB = tokenB.balanceOf(address(this));

            uint256 amountBOptimal = (amountADesired * balanceB) / balanceA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Insufficient B");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * balanceA) / balanceB;
                require(amountAOptimal >= amountAMin, "Insufficient A");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        } else {
            // First liquidity provision sets the pool ratio
            amountA = amountADesired;
            amountB = amountBDesired;
            liquidity = sqrt(amountA * amountB);
        }

        require(amountA >= amountAMin, "A not min");
        require(amountB >= amountBMin, "B not min");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        liquidity = liquidity > 0 ? liquidity : sqrt(amountA * amountB);
        _mint(to, liquidity);
    }

    /// @notice Removes liquidity from the pool and returns tokens A and B
    /// @dev Burns LP tokens and transfers proportional amounts
    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(_tokenA == address(tokenA) && _tokenB == address(tokenB), "Invalid tokens");
        require(block.timestamp <= deadline, "Expired");

        uint256 totalLiquidity = totalSupply();
        uint256 balanceA = tokenA.balanceOf(address(this));
        uint256 balanceB = tokenB.balanceOf(address(this));

        // Calculate share of liquidity
        amountA = (liquidity * balanceA) / totalLiquidity;
        amountB = (liquidity * balanceB) / totalLiquidity;

        require(amountA >= amountAMin, "A not min");
        require(amountB >= amountBMin, "B not min");

        _burn(msg.sender, liquidity);

        tokenA.transfer(to, amountA);
        tokenB.transfer(to, amountB);
    }

    /// @notice Swaps exact `amountIn` of one token for the other token
    /// @dev Uses constant product formula without fees
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        require(block.timestamp <= deadline, "Expired");
        require(path.length == 2, "Invalid path");

        IERC20 tokenIn = IERC20(path[0]);
        IERC20 tokenOut = IERC20(path[1]);

        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));

        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "Output too low");

        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(to, amountOut);
    }

    /// @notice Returns price of tokenA in terms of tokenB (or vice versa)
    /// @dev Used for external price queries
    function getPrice(address _tokenA, address _tokenB) external view returns (uint256 price) {
        require((_tokenA == address(tokenA) && _tokenB == address(tokenB)) || (_tokenA == address(tokenB) && _tokenB == address(tokenA)), "Invalid tokens");

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "No liquidity");

        if (_tokenA == address(tokenA)) {
            price = (reserveB * 1e18) / reserveA;
        } else {
            price = (reserveA * 1e18) / reserveB;
        }
    }

    /// @notice Computes output amount for a given input and reserves
    /// @dev Formula: out = (in * reserveOut) / (in + reserveIn)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");
        require(reserveIn > 0 && reserveOut > 0, "No liquidity");
        amountOut = (amountIn * reserveOut) / (amountIn + reserveIn);
    }

    /// @notice Calculates square root
    /// @dev Used to determine initial LP token supply
    function sqrt(uint256 y) internal pure returns (uint256 z) {
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
}