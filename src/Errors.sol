// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error UnauthorizedMinter(address minter, bool hasMintingRight);
error ExcessiveMinting (uint attemptedAmount, uint remaining);
error InvalidMintTarget(uint target);