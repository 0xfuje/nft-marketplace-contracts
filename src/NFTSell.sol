// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC721 } from "./ERC721.sol";
import { WETH } from "../src/WETH.sol";

contract NFTSell {
    event NewBid (address indexed bidder, uint indexed amount);
    event Sold (address buyer, SellType);

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
    IERC721 public nft;
    uint public nftId;
    uint public instantBuyPrice;
    Bid[] public bids;
    address payable seller;
    bool isSold;

    constructor(
        address _nft,
        uint _nftId,
        uint _instantBuyPrice,
        WETH _weth
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        instantBuyPrice = _instantBuyPrice;
        weth = WETH(_weth);
    }

    function bid(uint _amount) notSeller external {
        bids.push(Bid(
            msg.sender,
            _amount
        ));
        weth.approve(address(this), _amount);

        emit NewBid(msg.sender, _amount);
    }

    function acceptBid(uint index) onlySeller external {
        uint amount = bids[index].amount;
        address bidder = bids[index].bidder;

        bool sent = weth.transferFrom(bidder, address(this), amount);
        require(sent, "failed to transfer weth");

        isSold = true;
        
        emit Sold(bidder, SellType.AcceptBid);
    }

    function instantBuy() notSeller external {
        weth.approve(address(this), instantBuyPrice);

        bool sent = weth.transferFrom(msg.sender, address(this), instantBuyPrice);
        require(sent, "failed to transfer weth");

        isSold = true;

        emit Sold(msg.sender, SellType.InstantBuy);
    }

    function withdraw() onlySeller external {
        require(isSold, "nft not yet sold");
        require(address(this).balance > 0, "balance is 0");
    }

    
}

