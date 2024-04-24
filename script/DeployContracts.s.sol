// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Coupon.sol";
import "../src/Issuer.sol";

contract DeployContracts is Script {
    function run() public {
        AddressToString addressToString  = new AddressToString();
        vm.startBroadcast();

        // Deploy Coupon
        Coupon coupon = new Coupon("Coupon","CSCX");

        // Deploy Issuer with the address of Coupon
        Issuer issuer = new Issuer(address(coupon));

        vm.stopBroadcast();

        // Write addresses to a JSON file using Script's file system capabilities
        string memory jsonOutput = string(abi.encodePacked(
            '{"Coupon":"', addressToString.toAsciiString(address(coupon)),
            '", "Issuer":"', addressToString.toAsciiString(address(issuer)), '"}'
        ));
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
