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

        issuer.setLimits(1000 ether, 10_000_000_000);

        issuer.setTokenInfo(address(burnableToken), true, true);
        issuer.setTokenInfo(address(nonBurnableToken), true, false);
        issuer.setTokenInfo(address(oneToOnetoken), true, false);

        notOwner = address(0x1);
        increaser = address(0x2);
        nonIncreaser = address(0x3);
    }

    function test_currentPrice_is_accurate() public {
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(address(burnableToken), true, true);
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);
        //we expect the price to now be (9000*10_000_000_000) = 9e13
        uint actualPrice = issuer.currentPrice(address(burnableToken));
        vm.assertEq(actualPrice, 9e13);
    }

    function test_issue_burnable_token() public {
        burnableToken.mint(address(this), 100e18);
        uint burnableTotalSupplyBefore = burnableToken.totalSupply();

        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(address(burnableToken), true, true);
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(owner);
        burnableToken.approve(address(issuer), 100e18);
        issuer.issue(address(burnableToken), 35e17);
        assertEq(
            couponContract.balanceOf(address(this)),
            315e18,
            "Coupons should be minted"
        );

        uint burntAmount = burnableTotalSupplyBefore -
            burnableToken.totalSupply();

        assertEq(burntAmount, 35e17);
    }

    //Note: coupons issued are fewer than 1
    function test_issue_non_burnable_token() public {
        nonBurnableToken.mint(address(this), 1e20);

        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(address(burnableToken), true, true);
        vm.roll(block.number + 1);
        //1 day in the future should mint 864 tokens per 1 token
        vm.warp(currentTime + 86400);

        nonBurnableToken.approve(address(issuer), 100e18);
        issuer.issue(address(nonBurnableToken), 1e18);

        assertEq(
            couponContract.balanceOf(owner),
            864 ether,
            "Coupons should be minted"
        );
        uint balanceOfTokenOnIssuer = nonBurnableToken.balanceOf(
            address(issuer)
        );
        assertEq(balanceOfTokenOnIssuer, 1e18);
    }

    function test_excessive_minting() public {
        nonBurnableToken.mint(address(this), 1e20);

        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(address(burnableToken), true, true);
        vm.roll(block.number + 1);
        //1 day in the future should mint 864 tokens per 1 token
        vm.warp(currentTime + 86400);

        nonBurnableToken.approve(address(issuer), 100e18);
        vm.expectRevert(
            abi.encodeWithSelector(
                ExcessiveMinting.selector,
                1728 ether,
                1000 ether
            )
        );
        issuer.issue(address(nonBurnableToken), 2e18);
    }

    function test_issue_fail_on_disabled_token() public {
        issuer.setTokenInfo(address(nonBurnableToken), false, false); // Disable the token
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e18);
        vm.expectRevert("Token not enabled for issuance");
        issuer.issue(address(nonBurnableToken), 1e18);
    }

    function test_access_control() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.setTokenInfo(address(burnableToken), true, true); // Should revert
        vm.stopPrank();

        vm.startPrank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.setLimits(10, 10); // Should revert
        vm.stopPrank();
    }
}
