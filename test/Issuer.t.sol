// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Issuer.sol";
import "../src/Coupon.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/Errors.sol";

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
    MockToken oneToOnetoken;
    Coupon couponContract;
    address owner;
    address notOwner;
    address increaser;
    address nonIncreaser;
    function setUp() public {
        owner = address(this); // Test contract is the owner
        burnableToken = new MockToken("BurnableToken", "BTN");
        nonBurnableToken = new MockToken("NonBurnableToken", "NBTN");
        oneToOnetoken = new MockToken("OneToOne", "NBTN");
        couponContract = new Coupon("Coupon", "CPN");
        issuer = new Issuer(address(couponContract));
        couponContract.setMinter(address(issuer), true);

        issuer.setTokenInfo(address(burnableToken), true, true, 3e12);
        issuer.setTokenInfo(address(nonBurnableToken), true, false, 2e10);
        issuer.setTokenInfo(address(oneToOnetoken), true, false, 1e12);

        notOwner = address(0x1);
        increaser = address(0x2);
        nonIncreaser = address(0x3);
    }

    function testFail_burn_non_whitelisted_token() public {
        MockToken nonListedToken = new MockToken("Non-Listed Token", "NLT");
        issuer.burnBurnable(address(nonListedToken));
    }

    function testFail_burn_non_burnable_token() public {
        issuer.burnBurnable(address(nonBurnableToken));
    }

    function test_burn_burnable_token() public {
        uint256 initialBalance = 1000 * 10 ** 18;
        burnableToken.mint(address(issuer), initialBalance);

        assertEq(burnableToken.balanceOf(address(issuer)), initialBalance);
        issuer.burnBurnable(address(burnableToken));
        assertEq(
            burnableToken.balanceOf(address(issuer)),
            0,
            "Token should be completely burned"
        );
    }

    function test_burn_zero_balance() public {
        assertEq(burnableToken.balanceOf(address(issuer)), 0);
        issuer.burnBurnable(address(burnableToken)); // Should not fail, but no action is needed
        assertEq(
            burnableToken.balanceOf(address(issuer)),
            0,
            "Balance should still be zero"
        );
    }

    function test_issue_burnable_token() public {
        burnableToken.mint(address(this), 1e18);
        issuer.whitelistAllowanceIncreasers(increaser, true);

        vm.prank(increaser);
        issuer.increaseAllowance(3e18);
        vm.stopPrank();

        uint burnableTotalSupplyBefore = burnableToken.totalSupply();

        vm.prank(owner);
        burnableToken.approve(address(issuer), 1e18);
        issuer.issue(address(burnableToken), 1e18);
        assertEq(
            couponContract.balanceOf(address(this)),
            3e18,
            "Coupons should be minted"
        );

        uint burntAmount = burnableTotalSupplyBefore -
            burnableToken.totalSupply();

        assertEq(burntAmount, 1e18);
    }

    function test_non_approved_increaser_cannot_increase() public {
        vm.prank(nonIncreaser);
        burnableToken.approve(address(issuer), 1e25);
        vm.stopPrank();

        vm.prank(nonIncreaser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OnlyWhitelistedIncreasers.selector,
                nonIncreaser
            )
        );
        issuer.increaseAllowance(1e10);
        vm.stopPrank();
    }

    function test_increaser_can_increase_approvals() public {
        issuer.whitelistAllowanceIncreasers(increaser, true);
        bool isWhiteListed = issuer.allowanceIncreasers(increaser);
        assertEq(isWhiteListed, true, "increaser should be whitelisted");

        uint allowance = issuer.mintAllowance();
        assertEq(allowance, 0);
        vm.prank(increaser);
        issuer.increaseAllowance(1e40);
        vm.stopPrank();

        allowance = issuer.mintAllowance();
        assertEq(allowance, 1e40, "allowance should have increased");

        oneToOnetoken.mint(owner, 1e60);
        oneToOnetoken.approve(address(issuer), 1e60);
        issuer.issue(address(oneToOnetoken), 1e40 - 1000);

        allowance = issuer.mintAllowance();
        assertEq(allowance, 1000, "allowance should have increased");

        issuer.whitelistAllowanceIncreasers(increaser, false);

        vm.prank(increaser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OnlyWhitelistedIncreasers.selector,
                increaser
            )
        );
        issuer.increaseAllowance(1e10);
        vm.stopPrank();
    }

    function test_non_owner_cannot_whitelist_increasers() public {
        vm.prank(notOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.whitelistAllowanceIncreasers(increaser, true);
        vm.stopPrank();
    }

    //Note: coupons issued are fewer than 1
    function test_issue_non_burnable_token() public {
        nonBurnableToken.mint(address(this), 1e20);
        issuer.whitelistAllowanceIncreasers(increaser, true);

        vm.prank(increaser);
        issuer.increaseAllowance(2e18);
        vm.stopPrank();

        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e20);
        issuer.issue(address(nonBurnableToken), 1e20);
        assertEq(
            couponContract.balanceOf(address(this)),
            2e18,
            "Coupons should be minted"
        );
    }

    function test_issue_fail_on_disabled_token() public {
        issuer.setTokenInfo(address(nonBurnableToken), false, false, 1e12); // Disable the token
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e18);
        vm.expectRevert("Token not enabled for issuance");
        issuer.issue(address(nonBurnableToken), 1e18);
    }

    function test_minting_exceeds_limit() public {
        issuer.whitelistAllowanceIncreasers(increaser, true);
        vm.prank(increaser);
        issuer.increaseAllowance(2e18 - 1);
        vm.stopPrank();

        oneToOnetoken.mint(owner, 1e18);
        vm.prank(owner);
        oneToOnetoken.approve(address(issuer), 2e18);
        issuer.issue(address(oneToOnetoken), 1e18); // First issuance, within limit
        vm.expectRevert(
            abi.encodeWithSelector(ExcessiveMinting.selector, 1e18, 1e18 - 1)
        );
        issuer.issue(address(oneToOnetoken), 1e18); // Second issuance, exceeds limit
    }

    function test_access_control() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.setTokenInfo(address(burnableToken), true, true, 2e12); // Should revert
        vm.stopPrank();
    }
}
