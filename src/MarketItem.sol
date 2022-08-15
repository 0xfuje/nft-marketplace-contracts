// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC721 } from "./ERC721.sol";
import { WETH } from "../src/WETH.sol";

contract MarketItem {
    event NewBid (address indexed bidder, uint indexed amount);
    event Sold (address buyer, SellType, uint amount);

    enum SellType {
        AcceptBid,
        InstantBuy
    }

    struct Bid {
        address bidder;
        uint amount;
    }

    modifier onlySeller {
        require(msg.sender == seller, "only seller can use this function");
        _;
    }
    modifier notSeller {
        require(msg.sender != seller, "seller can't use this function");
        _;
    }

    WETH public weth;
    IERC721 public immutable nft;
    uint public immutable nftId;
    uint public instantBuyPrice;
    Bid[] public bids;
    address payable seller;
    bool isSold;

    constructor(
        address _nftAddress,
        uint _nftId,
        address _seller,
        uint _instantBuyPrice,
        WETH _weth
    ) {
        nft = IERC721(_nftAddress);
        nftId = _nftId;
        seller = payable(_seller);
        instantBuyPrice = _instantBuyPrice;
        weth = _weth;
    }

    function bid(uint _amount) notSeller external {
        require(!isSold, "nft already sold");
        uint allowance = weth.allowance(msg.sender, address(this));
        require(allowance == _amount, "weth not allowed");

        bids.push(Bid(
            msg.sender,
            _amount
        ));

        emit NewBid(msg.sender, _amount);
    }

    function acceptBid(uint index) onlySeller external {
        uint amount = bids[index].amount;
        address bidder = bids[index].bidder;

        bool sentETH = weth.transferFrom(bidder, seller, amount);
        require(sentETH, "failed to transfer weth");
        nft.safeTransferFrom(seller, bidder, nftId);

        isSold = true;
        emit Sold(bidder, SellType.AcceptBid, amount);
    }

    function instantBuy() notSeller external {
        require(!isSold, "nft already sold");
        uint allowance = weth.allowance(msg.sender, address(this));
        require(allowance == instantBuyPrice, "weth not allowed");

        bool sentETH = weth.transferFrom(msg.sender, seller, instantBuyPrice);
        require(sentETH, "failed to transfer weth");
        nft.safeTransferFrom(seller, msg.sender, nftId);

        isSold = true;
        emit Sold(msg.sender, SellType.InstantBuy, instantBuyPrice);
    }

    function getBid(uint index) public view returns (address bidder, uint amount) {
        return (bids[index].bidder, bids[index].amount);
    }
    
}

