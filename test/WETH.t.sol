// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { WETH } from "../src/WETH.sol";

contract WETHTest is Test {
    WETH weth;
    address alice = address(0xb9F79fc8cae15b7713e7603FdE3fDE7cC5FB8C05);
    address bob = address(0xb9F79fc8cae15b7713e7603FdE3fDE7cC5FB8C05);
    function setUp() public {
        weth = new WETH();
    }

    function testMint() public {
        hoax(bob, 0.01 ether);
        weth.mint{value: 10000}();
        assertEq(weth.totalSupply(), 10000);
        assertEq(weth.balanceOf(bob), 10000);
    }

    function testAllowance() public {
        hoax(bob, 0.01 ether);
        weth.mint{value: 2000}();
        vm.startPrank(bob);
        weth.approve(alice, 2000);
        uint allowance = weth.allowance(bob, alice);
        assertEq(allowance, 2000);
    }
}