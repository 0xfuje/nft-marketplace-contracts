// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { NFT } from "../src/ERC721.sol";
import { WETH } from "../src/WETH.sol";
import { NFTSell } from "../src/NFTSell.sol";

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

contract NFTSellTest is Test {
    event NewBid (address indexed bidder, uint indexed amount);
    event Sold (address buyer, SellType, uint amount);
    enum SellType { AcceptBid, InstantBuy }

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

        vm.startPrank(chloe);
        market = new NFTSell(
            address(nft),
            777,
            5000,
            weth
        );
        nft.approve(address(market), 777);
        vm.stopPrank();
    }

    function testBids() public {
        vm.startPrank(alice);
        weth.approve(address(market), 700);
        vm.expectEmit(true, true, false, false);
        emit NewBid(alice, 700);
        market.bid(700);
        vm.stopPrank();

        vm.startPrank(bob);
        weth.approve(address(market), 1400);
        market.bid(1400);
        address bidder0;
        uint amount0;
        (bidder0, amount0) = market.getBid(1);
        assertEq(bidder0, bob);
        assertEq(amount0, 1400);
    }

    function testAcceptBid() public {
        vm.startPrank(alice);
        weth.approve(address(market), 2000);
        market.bid(2000);
        vm.stopPrank();

        vm.startPrank(chloe);
        vm.expectEmit(false, false, false, true);
        emit Sold(alice, SellType.AcceptBid, 2000);
        market.acceptBid(0);

        assertEq(weth.balanceOf(chloe), 2000);
        assertEq(nft.ownerOf(777), alice);
    }

    function testInstantBuy() public {
        vm.startPrank(daniel);
        weth.approve(address(market), 5000);
        vm.expectEmit(false, false, false, true);
        emit Sold(daniel, SellType.InstantBuy, 5000);
        market.instantBuy();

        assertEq(weth.balanceOf(chloe), 5000);
        assertEq(nft.ownerOf(777), daniel);
    }

    
}
