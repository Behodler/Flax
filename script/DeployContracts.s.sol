// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Coupon.sol";
import "../src/Issuer.sol";

contract DeployContracts is Script {
    function run() public {
        AddressToString addressToString = new AddressToString();
        vm.startBroadcast();

        // Deploy Coupon
        Coupon coupon = new Coupon("Coupon", "CSCX");
        Coupon mockInputTokenBurnable = new Coupon("EYE", "EYE");
        Coupon mockInputTokenNonBurnable = new Coupon(
            "Uni V2 EYE/SCX",
            "EYE/SCX"
        );

        // Deploy Issuer with the address of Coupon
        Issuer issuer = new Issuer(address(coupon));
        issuer.setMaxIssuancePerDay(100 ether);
        issuer.setTokenInfo(address(mockInputTokenBurnable), true, true, 2e12);
        issuer.setTokenInfo(
            address(mockInputTokenNonBurnable),
            true,
            false,
            304e10
        );
        vm.stopBroadcast();

        // Creating a JSON array of input token addresses
        string memory inputs = string(
            abi.encodePacked(
                '["',
                addressToString.toAsciiString(address(mockInputTokenBurnable)),
                '", "',
                addressToString.toAsciiString(
                    address(mockInputTokenNonBurnable)
                ),
                '"]'
            )
        );

        // Constructing the full JSON output
        string memory jsonOutput = string(
            abi.encodePacked(
                '{"Coupon":"',
                addressToString.toAsciiString(address(coupon)),
                '", "Issuer":"',
                addressToString.toAsciiString(address(issuer)),
                '", "Inputs":',
                inputs,
                "}"
            )
        );
        // vm.writeFile("/home/justin/code/BehodlerReborn/coupon/script/output/deployed_addresses.json", jsonOutput);
        console.log(jsonOutput);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}

contract AddressToString {
    // Helper function to convert address to string
    function toAsciiString(address x) public pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(abi.encodePacked("0x", s));
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
