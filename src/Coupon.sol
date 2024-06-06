// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@oz_flax/contracts/token/ERC20/ERC20.sol";
import "@oz_flax/contracts/access/Ownable.sol";
import {UnauthorizedMinter} from "./Errors.sol";

contract Coupon is ERC20, Ownable {
    mapping(address => bool) public minters;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
    }

    function setMinter(address minter, bool canMint) public onlyOwner {
        minters[minter] = canMint;
    }

    function mint(uint256 amount, address recipient) public {
        // Check if the caller is a minter, if not, revert with custom error
        if (!minters[msg.sender]) {
            revert UnauthorizedMinter(msg.sender, minters[msg.sender]);
        }
        _mint(recipient, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
