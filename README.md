# SimpleSwap Smart Contract

##  Project Description

**SimpleSwap** is a Solidity smart contract that replicates the basic functionalities of a Uniswap-like decentralized exchange.
It allows users to:

* Add and remove liquidity to a token pair pool.
* Swap tokens between two ERC20 tokens.
* Retrieve token prices and calculate output amounts.

The contract automatically manages liquidity provider (LP) tokens, which represent the user's share in the pool.

---

##  Features

* ✅ Add Liquidity
* ✅ Remove Liquidity
* ✅ Token Swapping
* ✅ Price Retrieval
* ✅ Swap Output Calculation
* ✅ Deadline Protection
* ✅ Proportional Liquidity Management

---

## Main Functions

| Function                   | Description                                           |
| -------------------------- | ----------------------------------------------------- |
| `addLiquidity`             | Adds liquidity to the token pool and mints LP tokens. |
| `removeLiquidity`          | Removes liquidity and burns LP tokens.                |
| `swapExactTokensForTokens` | Swaps a fixed amount of token A for token B.          |
| `getPrice`                 | Returns the price of token A in terms of token B.     |
| `getAmountOut`             | Calculates output token amount based on reserves.     |

---

## Function Details

### 1. `addLiquidity`

```solidity
function addLiquidity(
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB, uint256 liquidity)
```

* Adds liquidity to the pool.
* Transfers tokens from the user to the pool.
* Mints LP tokens as proof of liquidity.
* Parameters:

  * `amountADesired` / `amountBDesired`: Tokens the user wants to deposit.
  * `amountAMin` / `amountBMin`: Minimum accepted amounts to avoid slippage.
  * `to`: Recipient of LP tokens.
  * `deadline`: Transaction expiration timestamp.

---

### 2. `removeLiquidity`

```solidity
function removeLiquidity(
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB)
```

* Removes liquidity from the pool.
* Burns LP tokens.
* Transfers proportional token amounts back to the user.
* Parameters:

  * `liquidity`: LP tokens to burn.
  * `amountAMin` / `amountBMin`: Minimum accepted amounts to avoid slippage.
  * `to`: Recipient of the tokens.
  * `deadline`: Transaction expiration timestamp.

---

### 3. `swapExactTokensForTokens`

```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts)
```

* Swaps a fixed amount of input token for another token.
* Uses the formula without fees:

  ```
  amountOut = (amountIn * reserveOut) / (amountIn + reserveIn)
  ```
* Parameters:

  * `amountIn`: Exact input token amount.
  * `amountOutMin`: Minimum output tokens accepted.
  * `path`: Array of token addresses \[tokenIn, tokenOut].
  * `to`: Recipient of the output tokens.
  * `deadline`: Transaction expiration timestamp.

---

### 4. `getPrice`

```solidity
function getPrice(address _tokenA, address _tokenB) public view returns (uint256 price)
```

* Returns the price of token A in terms of token B using current pool reserves.
* Calculation:

  ```
  price = (reserveB * 1e18) / reserveA
  ```

---

### 5. `getAmountOut`

```solidity
function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
) public pure returns (uint256 amountOut)
```

* Calculates the output token amount based on reserves.
* Formula:

  ```
  amountOut = (amountIn * reserveOut) / (amountIn + reserveIn)
  ```

---

### 6. `sqrt`

```solidity
function sqrt(uint256 y) internal pure returns (uint256 z)
```

* Internal utility function to calculate square roots.
* Used to determine initial liquidity when creating a new pool.

---

## Security Features

* Deadlines required to protect against stuck transactions.
* Minimum accepted amounts to prevent slippage.
* `require` statements placed at the beginning of each function for gas efficiency.
* Permissions controlled via ERC20 allowances.

---

## Technologies Used

* Solidity ^0.8.0
* OpenZeppelin ERC20 contracts

---

## Author

**Mateo Rios**
@mateori0s
