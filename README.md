# SimpleSwap Smart Contract

This smart contract replicates basic Uniswap V2 functionalities. It allows users to add/remove liquidity and perform token swaps between two ERC-20 tokens using the constant product formula.

## Features

- **Liquidity Provision**: Users can deposit token pairs to the pool and receive LP tokens.
- **Token Swap**: Swaps between tokenA and tokenB using the constant product formula.
- **Liquidity Removal**: LP token holders can withdraw their share of the pool.
- **Price Oracle**: Returns tokenA price in terms of tokenB or vice versa.
- **Amount Calculation**: Computes how many tokens will be received given reserves.

## Functions

### `constructor(address _tokenA, address _tokenB)`
Initializes the liquidity pool with two distinct ERC-20 tokens.

### `addLiquidity(address _tokenA, address _tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline)`
Adds liquidity to the pool and mints LP tokens proportionally.
- Returns: `amountA`, `amountB`, and `liquidity` minted.

### `removeLiquidity(address _tokenA, address _tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline)`
Removes liquidity and returns the corresponding amount of tokens A and B.
- Returns: `amountA`, `amountB`

### `swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)`
Swaps a fixed amount of input token for the output token using reserves.
- Requires a valid path of exactly two tokens.

### `getPrice(address tokenA, address tokenB)`
Returns the price of `tokenA` in terms of `tokenB`, assuming both tokens are the pool's tokens.

### `getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)`
Calculates the output token amount for a given input using the constant product formula.

## Internal Helpers

### `sqrt(uint y)`
Computes square root using the Babylonian method. Used for initial liquidity minting.

## Notes

- Token addresses must match the pool's tokens; otherwise functions will revert.
- Liquidity must be added in proportion to current reserves to maintain price.
- No fee is included in the swap (idealized).
- Reverts on expiration to prevent front-running.

## Compatibility

This contract is **compatible with the verifier contract** used in the course for automatic evaluation.

## Author

Mateo Rios (@mateori0s)

---

© 2025
