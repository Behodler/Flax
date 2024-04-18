// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Issuer.sol";
import "../src/Coupon.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

contract IssuerTest is Test {
    Issuer issuer;
    MockToken burnableToken;
    MockToken nonBurnableToken;
    Coupon couponContract;
    address owner;
    address notOwner;
    function setUp() public {
        owner = address(this); // Test contract is the owner
        burnableToken = new MockToken("BurnableToken", "BTN");
        nonBurnableToken = new MockToken("NonBurnableToken", "NBTN");
        couponContract = new Coupon("Coupon", "CPN");
        issuer = new Issuer(address(couponContract));
        couponContract.setMinter(address(issuer), true);
        
        burnableToken.mint(address(this), 1e18); // 1 token
        nonBurnableToken.mint(address(this), 1e18); // 1 token

        issuer.setTokenInfo(address(burnableToken), true, true, 1e12);
        issuer.setTokenInfo(address(nonBurnableToken), true, false, 1e12);
        issuer.setMaxIssuancePerDay(1e18); // 1 coupon per day
        notOwner = address(0x1);
    }

    function testIssueBurnableToken() public {
        vm.prank(owner);
        burnableToken.approve(address(issuer), 1e18);
        issuer.issue(address(burnableToken), 1e18);
        assertEq(couponContract.balanceOf(address(this)), 1e18, "Coupons should be minted");
    }

    function testIssueNonBurnableToken() public {
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e18);
        issuer.issue(address(nonBurnableToken), 1e18);
        assertEq(couponContract.balanceOf(address(this)), 1e18, "Coupons should be minted");
    }

    function testIssueFailOnDisabledToken() public {
        issuer.setTokenInfo(address(nonBurnableToken), false, false, 1e12); // Disable the token
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e18);
        vm.expectRevert("Token not enabled for issuance");
        issuer.issue(address(nonBurnableToken), 1e18);
    }

    function testMintingExceedsLimit() public {
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 2e18);
        issuer.issue(address(nonBurnableToken), 1e18); // First issuance, within limit
        vm.expectRevert("Max issuance limit exceeded for today");
        issuer.issue(address(nonBurnableToken), 1e18); // Second issuance, exceeds limit
    }

    function testAccessControl() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(         abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            ));
        issuer.setTokenInfo(address(burnableToken), true, true, 2e12); // Should revert
        vm.stopPrank();
    }
}
