// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Coupon is ERC20, Ownable {
    mapping(address => bool) public minters;

    // Custom error for failed minting right checks
    error UnauthorizedMinter(address minter, bool hasMintingRight);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupDecimals(18);
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
