// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { NFT } from "../src/ERC721.sol";
import { WETH } from "../src/WETH.sol";
import { NFTSell } from "../src/NFTSell.sol";

contract WETHTest is Test {
    WETH weth;
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
}

contract NFTSellTest is Test {
    event NewBid (address indexed bidder, uint indexed amount);

    WETH weth;
    NFT nft;
    NFTSell market;

    address alice = address(0xb9F79fc8cae15b7713e7603FdE3fDE7cC5FB8C05);
    address bob = address(0xd882C00D7E9687c7f93F1B6299B747833891708D);
    address chloe = address(0xe2c5638B878562994CB6aC4bB21c4d20BD88fF6c);
    address daniel = address(0xd38C6E64BabFF7D57EAF61Afd11BAae4272e5f76);

    function setUp() public {
        weth = new WETH();
        hoax(alice, 0.01 ether);
        weth.mint{value: 2000}();
        hoax(bob, 0.01 ether);
        weth.mint{value: 3000}();
        hoax(daniel, 0.01 ether);
        weth.mint{value: 5000}();

        nft = new NFT();
        nft.mint(chloe, 777);

        vm.prank(chloe);
        market = new NFTSell(
            address(nft),
            777,
            5000,
            weth
        );
    }

    function testBid() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, false);
        emit NewBid(alice, 700);
        market.bid(700);

        vm.prank(bob);
        market.bid(1400);
    }   
}
