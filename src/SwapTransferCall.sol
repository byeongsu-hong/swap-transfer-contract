// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {UniswapV2Router02} from "@uniswap/UniswapV2Router02.sol";

contract SwapTransferCall {
    function swapTransferCall(
        address _UNISWAP_ROUTER,
        // address _tokenIn,
        // address _tokenOut,
        address[] calldata _path,
        uint256 _amountIn,
        uint256 _amountOut,
        address _to
    ) public {
        // Create a Uniswap router instance.
        address payable uniswapRouterAddress = payable(
            address(_UNISWAP_ROUTER)
        );
        UniswapV2Router02 router = UniswapV2Router02(uniswapRouterAddress);

        // // Create a path array with the token addresses.
        // address[] memory path = new address[](2);
        // path[0] = _tokenIn;
        // path[1] = _tokenOut;

        address tokenIn = _path[0];

        // Approve the router to spend the token.
        IERC20(tokenIn).approve(address(router), _amountIn);

        // Swap the tokens.
        router.swapTokensForExactTokens(
            _amountOut,
            _amountIn,
            _path,
            _to,
            block.timestamp
        );
    }
}
