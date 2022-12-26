// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {UniswapV2Router02} from "@uniswap/UniswapV2Router02.sol";

contract SwapTransferCall {
    function swapTransferCall(
        address _UNISWAP_ROUTER,
        address[] memory _path,
        uint256 _amountOut,
        uint256 _amountInMax,
        address _to
    ) public {
        address payable uniswapRouterAddress = payable(
            address(_UNISWAP_ROUTER)
        );
        UniswapV2Router02 router = UniswapV2Router02(uniswapRouterAddress);

        address tokenIn = _path[0];

        IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountInMax);
        IERC20(tokenIn).approve(address(router), _amountInMax);
        uint256[] memory amounts = router.swapTokensForExactTokens(
            _amountOut,
            _amountInMax,
            _path,
            _to,
            block.timestamp
        );

        uint256 inAmount = amounts[0];
        IERC20(tokenIn).transfer(msg.sender, _amountInMax - inAmount);
    }
}
