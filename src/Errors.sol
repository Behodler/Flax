// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error UnauthorizedMinter(address minter, bool hasMintingRight);
error InvalidMintTarget(uint target);
error InvalidLockConfig(uint threshold_size,uint days_multiple,uint offset);
error minFlaxMintThresholdTooLow(uint threshold);