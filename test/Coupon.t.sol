// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Coupon.sol";
import {IERC20Errors} from "lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CouponTest is Test {
    Coupon coupon;
    address owner;
    address minter = address(0x1);
    address nonMinter = address(0x2);
    address recipient = address(0x3);

    function setUp() public {
        owner = address(this);
        coupon = new Coupon("TestCoupon", "TC");
    }

    function testNonOwnerCannotSetMinters() public {
        address nonOwner = nonMinter; // The address trying to set a minter
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        coupon.setMinter(minter, true);
    }

    function testNonMintersCannotMint() public {
        uint256 amountToMint = 100; // Set a minting amount for testing
        vm.prank(nonMinter);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnauthorizedMinter.selector,
                nonMinter,
                false
            )
        );
        coupon.mint(amountToMint, recipient);
    }
    function testMintersCanMint() public {
        coupon.setMinter(minter, true);
        vm.startPrank(minter);
        coupon.mint(100, recipient);
        vm.stopPrank();
    }

    function testToggleMinterBackToFalse() public {
        coupon.setMinter(minter, true);
        coupon.setMinter(minter, false);
        vm.prank(minter);
        vm.expectRevert(
            abi.encodeWithSelector(UnauthorizedMinter.selector, minter, false)
        );
        coupon.mint(100, recipient);
    }

    function testBurningTooMuchReverts() public {
        uint256 tooMuchAmount = 1; // This should be more than the balance available to `nonMinter`
        vm.prank(nonMinter);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                nonMinter,
                0,
                tooMuchAmount
            )
        );
        coupon.burn(tooMuchAmount);
    }

    function testBurningNothingDoesNothing() public {
        uint256 preBalance = coupon.balanceOf(nonMinter);
        vm.prank(nonMinter);
        coupon.burn(0);
        uint256 postBalance = coupon.balanceOf(nonMinter);
        assertEq(preBalance, postBalance);
    }

    function testBurningPositiveAmount() public {
        coupon.setMinter(minter, true);
        vm.startPrank(minter);
        coupon.mint(100, minter);
        uint256 preSupply = coupon.totalSupply();
        uint256 preBalance = coupon.balanceOf(minter);
        uint256 burnAmount = 50;

        coupon.burn(burnAmount);
        vm.stopPrank();
        uint256 postSupply = coupon.totalSupply();
        uint256 postBalance = coupon.balanceOf(minter);
        assertEq(preSupply - burnAmount, postSupply);
        assertEq(preBalance - burnAmount, postBalance);
    }

    function testBurningEntireSupply() public {
        coupon.setMinter(minter, true);
        vm.startPrank(minter);
        coupon.mint(100, minter);
        coupon.burn(100);
        vm.stopPrank();
        assertEq(coupon.totalSupply(), 0);
    }

    function testApprovingAllowances() public {
        address spender = address(0x4);
        coupon.approve(spender, 100);
        coupon.approve(spender, 50);
        assertEq(coupon.allowance(owner, spender), 50);
    }
}
