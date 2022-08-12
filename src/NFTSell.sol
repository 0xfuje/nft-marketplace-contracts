// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC721 } from "./ERC721.sol";

contract NFTSell {
    event EventBid (address indexed bidder, uint indexed amount, uint date);

    struct Bid {
        address bidder;
        uint amount;
    }

    modifier onlySeller {
        require(msg.sender == seller, "only seller can use this function");
        _;
    }

    IERC721 public nft;
    uint public nftId;
    uint public instantBuyPrice;
    Bid[] public bids;
    address payable seller;
    uint public endAt;

    constructor(
        address _nft,
        uint _nftId,
        uint _endAt,
        uint _instantBuyPrice
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        endAt = _endAt;
        instantBuyPrice = _instantBuyPrice;
    }



    function bid(uint _amount) external {
        require(msg.sender != seller, "seller can't bid");
        bids.push(Bid(
            msg.sender,
            _amount
        ));
        emit EventBid(msg.sender, _amount, block.timestamp);
    }

    function acceptBid(uint index) onlySeller external {
        uint amount = bids[index].amount;
        address bidder = bids[index].bidder;
        
    }

    function changeInstantBuyPrice(uint _amount) onlySeller external {
        instantBuyPrice = _amount;
    }

    function changeEndAt(uint _endAt) onlySeller external {
        endAt = _endAt;
    }

    
}

