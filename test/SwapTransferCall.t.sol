// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {UniswapV2Factory, UniswapV2Pair} from "@uniswap/UniswapV2Factory.sol";
import {UniswapV2Router02} from "@uniswap/UniswapV2Router02.sol";

import {SwapTransferCall} from "../src/SwapTransferCall.sol";

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract ERC20Mock is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mintInternal(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract SwapTransferTest is Test {
    ERC20Mock public aToken;
    ERC20Mock public bToken;

    ERC20Mock public w_ETH;

    UniswapV2Factory public factory;
    UniswapV2Router02 public router;

    SwapTransferCall public testContract;

    function setUp() public {
        aToken = new ERC20Mock("a-name", "a-symbol");
        bToken = new ERC20Mock("b-name", "b-symbol");
        w_ETH = new ERC20Mock("WETH", "WETH");

        factory = new UniswapV2Factory(address(this));
        // factory.setFeeTo(address(this));

        router = new UniswapV2Router02(address(factory), address(w_ETH));

        testContract = new SwapTransferCall();
    }

    function testMint() public {
        aToken.mintInternal(address(this), 1_000);
        bToken.mintInternal(address(this), 1_000);

        assertEq(aToken.balanceOf(address(this)), 1_000);
        assertEq(bToken.balanceOf(address(this)), 1_000);
    }

    function testTransfer() public {
        aToken.mintInternal(address(this), 1_000);
        aToken.transfer(address(bToken), 1_000);

        assertEq(aToken.balanceOf(address(this)), 0);
        assertEq(aToken.balanceOf(address(bToken)), 1_000);
    }

    function testCreatePair() public {
        factory.createPair(address(aToken), address(bToken));
    }

    function testGetReserves() public {
        factory.createPair(address(aToken), address(bToken));

        UniswapV2Pair pair = UniswapV2Pair(factory.getPair(address(aToken), address(bToken)));

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        assertEq(reserve0, 0);
        assertEq(reserve1, 0);
    }

    function testAddLiquidity() public {
        factory.createPair(address(aToken), address(bToken));

        aToken.mintInternal(address(this), 10_000);
        bToken.mintInternal(address(this), 10_000);

        aToken.approve(address(router), 10_000);
        bToken.approve(address(router), 10_000);

        router.addLiquidity(address(aToken), address(bToken), 10_000, 5_000, 0, 0, address(this), block.timestamp);

        assertEq(aToken.balanceOf(address(this)), 0);
        assertEq(bToken.balanceOf(address(this)), 5_000);
    }

    function testSwap() public {
        factory.createPair(address(aToken), address(bToken));

        aToken.mintInternal(address(this), 100_000);
        bToken.mintInternal(address(this), 50_000);

        aToken.approve(address(router), 100_000);
        bToken.approve(address(router), 50_000);

        router.addLiquidity(address(aToken), address(bToken), 100_000, 50_000, 0, 0, address(this), block.timestamp);

        assertEq(aToken.balanceOf(address(this)), 0);
        assertEq(bToken.balanceOf(address(this)), 0);

        aToken.mintInternal(address(this), 100_000);
        aToken.approve(address(router), 100_000);

        assertEq(aToken.balanceOf(address(this)), 100_000);

        address[] memory addrs = new address[](2);
        addrs[0] = address(aToken);
        addrs[1] = address(bToken);

        router.swapTokensForExactTokens(1_000, 3_000, addrs, address(this), block.timestamp);

        assertEq(aToken.balanceOf(address(this)), 97_953);
        assertEq(bToken.balanceOf(address(this)), 1_000);
    }

    function testSwapTransferCall() public {
        factory.createPair(address(aToken), address(bToken));

        aToken.mintInternal(address(this), 100_000);
        bToken.mintInternal(address(this), 50_000);

        aToken.approve(address(router), 100_000);
        bToken.approve(address(router), 50_000);

        router.addLiquidity(address(aToken), address(bToken), 100_000, 50_000, 0, 0, address(this), block.timestamp);

        assertEq(aToken.balanceOf(address(this)), 0);
        assertEq(bToken.balanceOf(address(this)), 0);

        aToken.mintInternal(address(this), 3_000);

        assertEq(aToken.balanceOf(address(this)), 3_000);

        address[] memory path = new address[](2);
        path[0] = address(aToken);
        path[1] = address(bToken);

        aToken.approve(address(testContract), 3_000);

        CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
        address fromAddr = cheats.addr(1);

        testContract.swapTransferCall(address(router), path, 1_000, 3_000, address(fromAddr));

        assertEq(bToken.balanceOf(address(fromAddr)), 1_000);
    }
}
