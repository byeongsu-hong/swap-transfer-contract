// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {UniswapV2Router02} from "@uniswap/UniswapV2Router02.sol";

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface Permitable {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}

contract SwapTransferCall {
    function swapTransferCall(
        address _UNISWAP_ROUTER,
        address[] memory _path,
        uint256 _amountOut,
        uint256 _amountInMax,
        address _to,
        uint256 _deadline
    ) public {
        address payable uniswapRouterAddress = payable(address(_UNISWAP_ROUTER));
        UniswapV2Router02 router = UniswapV2Router02(uniswapRouterAddress);

        address tokenIn = _path[0];

        IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountInMax);
        IERC20(tokenIn).approve(address(router), _amountInMax);
        uint256[] memory amounts =
            router.swapTokensForExactTokens(_amountOut, _amountInMax, _path, _to, _deadline);

        uint256 inAmount = amounts[0];
        IERC20(tokenIn).transfer(msg.sender, _amountInMax - inAmount);
    }

    function swapTransferCall(
        address _UNISWAP_ROUTER,
        address[] memory _path,
        uint256 _amountOut,
        uint256 _amountInMax,
        address _to,
        uint256 _deadline,
        Signature memory _signature
    ) public {
        address payable uniswapRouterAddress = payable(address(_UNISWAP_ROUTER));
        UniswapV2Router02 router = UniswapV2Router02(uniswapRouterAddress);

        address tokenIn = _path[0];
        Permitable(tokenIn).permit(msg.sender, address(this), _amountInMax, _deadline, _signature.v, _signature.r, _signature.s);

        IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountInMax);
        IERC20(tokenIn).approve(address(router), _amountInMax);
        uint256[] memory amounts =
            router.swapTokensForExactTokens(_amountOut, _amountInMax, _path, _to, _deadline);

        uint256 inAmount = amounts[0];
        IERC20(tokenIn).transfer(msg.sender, _amountInMax - inAmount);
    }
}
