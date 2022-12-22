// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {UniswapV2Factory, UniswapV2Pair} from "./contracts/UniswapV2Factory.sol";
import "../src/Counter.sol";

contract AToken is ERC20 {
    constructor() ERC20("name-a", "symbol-a") {}

    function getAddress() public view returns (address) {
        return address(this);
    }

    function mintInternal(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract BToken is ERC20 {
    constructor() ERC20("name-b", "symbol-b") {}

    function getAddress() public view returns (address) {
        return address(this);
    }

    function mintInternal(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract SwapTransferTest is Test {
    AToken public aToken;
    BToken public bToken;

    UniswapV2Factory public factory;

    Counter public counter;

    function setUp() public {
        aToken = new AToken();
        bToken = new BToken();

        factory = new UniswapV2Factory(address(this));

        counter = new Counter();
        counter.setNumber(0);
    }

    function testCreatePair() public {
        factory.createPair(aToken.getAddress(), bToken.getAddress());
    }
}
