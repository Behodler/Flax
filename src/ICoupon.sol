// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ICoupon is IERC20 {
    // Ownable functions
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;

    // Coupon specific functions
    function setMinter(address minter, bool canMint) external;
    function mint(uint256 amount, address recipient) external;
    function burn(uint256 amount) external;

    // State variables
    function minters(address minter) external view returns (bool);
}
