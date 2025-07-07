// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SimpleSwap Smart Contract
/// @author mateori0s
/// @notice Implements basic liquidity management and token swap
contract SimpleSwap is ERC20 {
    IERC20 public tokenA;
    IERC20 public tokenB;

    /// @notice Initializes the pool with token addresses and sets LP token name and symbol
    /// @param _tokenA Address of token A
    /// @param _tokenB Address of token B
    constructor(
        address _tokenA,
        address _tokenB
    ) ERC20("SimpleSwap Token", "SST") {
        require(_tokenA != _tokenB, "Identical tokens");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Adds liquidity to the pool
    /// @param amountADesired Amount of token A to add
    /// @param amountBDesired Amount of token B to add
    /// @param amountAMin Minimum acceptable amount of token A
    /// @param amountBMin Minimum acceptable amount of token B
    /// @param to Address to receive liquidity tokens
    /// @param deadline Transaction deadline timestamp
    /// @return amountA Final amount of token A added
    /// @return amountB Final amount of token B added
    /// @return liquidity Amount of liquidity tokens minted
    function addLiquidity(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(block.timestamp <= deadline, "Expired");

        uint256 totalLiquidity = totalSupply();
        if (totalLiquidity > 0) {
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

    /// @notice Removes liquidity from the pool
    /// @param liquidity Amount of liquidity tokens to burn
    /// @param amountAMin Minimum acceptable amount of token A
    /// @param amountBMin Minimum acceptable amount of token B
    /// @param to Address to receive withdrawn tokens
    /// @param deadline Transaction deadline timestamp
    /// @return amountA Final amount of token A returned
    /// @return amountB Final amount of token B returned
    function removeLiquidity(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "Expired");

        uint256 totalLiquidity = totalSupply();
        uint256 balanceA = tokenA.balanceOf(address(this));
        uint256 balanceB = tokenB.balanceOf(address(this));

        amountA = (liquidity * balanceA) / totalLiquidity;
        amountB = (liquidity * balanceB) / totalLiquidity;

        require(amountA >= amountAMin, "A not min");
        require(amountB >= amountBMin, "B not min");

        _burn(msg.sender, liquidity);

        tokenA.transfer(to, amountA);
        tokenB.transfer(to, amountB);
    }

    /// @notice Swaps exact tokens for another token
    /// @param amountIn Amount of input token to swap
    /// @param amountOutMin Minimum acceptable amount of output token
    /// @param path Address array [tokenIn, tokenOut]
    /// @param to Address to receive swapped tokens
    /// @param deadline Transaction deadline timestamp
    /// @return amounts Array with input and output amounts
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(block.timestamp <= deadline, "Expired");
        require(path.length == 2, "Invalid path");

        IERC20 tokenIn = IERC20(path[0]);
        IERC20 tokenOut = IERC20(path[1]);

        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));

        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "Output not min");

        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(to, amountOut);

        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /// @notice Gets price of tokenA in terms of tokenB
    function getPrice(
        address _tokenA,
        address _tokenB
    ) public view returns (uint256 price) {
        uint256 reserveA = IERC20(_tokenA).balanceOf(address(this));
        uint256 reserveB = IERC20(_tokenB).balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "No liquidity");

        price = (reserveB * 1e18) / reserveA;
    }

    /// @notice Calculates output amount based on reserves
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");
        require(reserveIn > 0 && reserveOut > 0, "No liquidity");

        amountOut = (amountIn * reserveOut) / (amountIn + reserveIn);
    }

    /// @notice Utility function for square root calculation
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
