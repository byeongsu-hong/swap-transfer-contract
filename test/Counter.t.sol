// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/Counter.sol";

contract CounterTest is Test {
    ERC20 public aToken;
    ERC20 public bToken;

    Counter public counter;

    function setUp() public {
        aToken = new ERC20("name-a", "symbol-a");
        bToken = new ERC20("name-b", "symbol-b");

        counter = new Counter();
        counter.setNumber(0);
    }

    function testIncrement() public {
        counter.increment();

        assertEq(counter.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x);

        assertEq(counter.number(), x);
    }
}
