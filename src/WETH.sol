// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {}

    function mint() public payable {
        _mint(msg.sender, msg.value);
    }

    function burn(uint _amount) external {
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
    }
}