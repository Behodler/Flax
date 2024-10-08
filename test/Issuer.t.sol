// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Issuer.sol";
import "../src/Coupon.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

import "../src/Errors.sol";
import "../src/HedgeyAdapter.sol";
import {TokenLockupPlans} from "@hedgey/lockup/TokenLockupPlans.sol";

//TODO: all mints of NFTs can't be to test contract

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
    address user;
    address notOwner;
    address increaser;
    address nonIncreaser;
    address recipient;
    TokenLockupPlans tokenLockupPlan;
    uint standardGrowth = 10_000_000_000;
    HedgeyAdapter hedgeyAdapter;

    function setUp() public {
        owner = address(this); // Test contract is the owner
        burnableToken = new MockToken("BurnableToken", "BTN");
        nonBurnableToken = new MockToken("NonBurnableToken", "NBTN");
        oneToOnetoken = new MockToken("OneToOne", "NBTN");
        couponContract = new Coupon("Coupon", "CPN");

        tokenLockupPlan = new TokenLockupPlans("Hedge", "HDG");
        hedgeyAdapter = new HedgeyAdapter(
            address(couponContract),
            address(tokenLockupPlan)
        );

        issuer = new Issuer(
            address(couponContract),
            address(hedgeyAdapter),
            true
        );
        couponContract.setMinter(address(issuer), true);

        issuer.setLimits(10000, 60, 1, 1);

        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        issuer.setTokenInfo(
            address(nonBurnableToken),
            true,
            false,
            standardGrowth,
            false
        );
        issuer.setTokenInfo(
            address(oneToOnetoken),
            true,
            false,
            standardGrowth,
            false
        );

        notOwner = address(0x1);
        increaser = address(0x2);
        nonIncreaser = address(0x3);
        user = address(0x4);
        recipient = address(0x5);
    }

    function flxBalance(address holder) private view returns (uint) {
        TokenLockupPlans plan = hedgeyAdapter.tokenLockupPlan();
        return plan.lockedBalances(holder, address(couponContract));
    }

    function test_invalid_lock_config() public {
        //max values passing
        issuer.setLimits(20000, 180, 1460, 7);
        vm.expectRevert(
            abi.encodeWithSelector(InvalidLockConfig.selector, 20001, 180, 1460)
        );
        issuer.setLimits(20001, 180, 1460, 7);
        vm.expectRevert(
            abi.encodeWithSelector(InvalidLockConfig.selector, 20000, 181, 1460)
        );
        issuer.setLimits(20000, 181, 1460, 7);
        vm.expectRevert(
            abi.encodeWithSelector(InvalidLockConfig.selector, 20000, 180, 1461)
        );
        issuer.setLimits(20000, 180, 1461, 7);
    }

    function test_set_many_tokens_info() public {
        // Before state
        (
            bool enabled_burnable_before,
            bool burnable_burnable_before,
            ,
            uint burnable_rate_before,

        ) = issuer.whitelist(address(burnableToken));
        (
            bool enabled_non_before,
            bool burnable_non_before,
            ,
            uint non_rate_before,

        ) = issuer.whitelist(address(nonBurnableToken));
        (
            bool enabled_one_before,
            bool burnable_one_before,
            ,
            uint burnable_one_rate_before,

        ) = issuer.whitelist(address(oneToOnetoken));

        // Assertions for before state
        vm.assertEq(enabled_burnable_before, true);
        vm.assertEq(burnable_burnable_before, true);
        vm.assertEq(enabled_non_before, true);
        vm.assertEq(burnable_non_before, false);
        vm.assertEq(enabled_one_before, true);
        vm.assertEq(burnable_one_before, false);

        vm.assertEq(burnable_rate_before, standardGrowth);
        vm.assertEq(non_rate_before, standardGrowth);
        vm.assertEq(burnable_one_rate_before, standardGrowth);

        // Setting up the arrays
        address[] memory tokenAddresses = new address[](3);
        bool[] memory enabled = new bool[](3);
        bool[] memory burnable = new bool[](3);
        uint[] memory rate = new uint[](3);
        bool[] memory rewardsEnabled = new bool[](3);
        tokenAddresses[0] = address(burnableToken);
        tokenAddresses[1] = address(nonBurnableToken);
        tokenAddresses[2] = address(oneToOnetoken);

        enabled[0] = false;
        enabled[1] = true;
        enabled[2] = false;

        burnable[0] = false;
        burnable[1] = true;
        burnable[2] = false;

        rate[0] = 20_000_000;
        rate[1] = 40_000_000;
        rate[2] = 1000_000_000_000_000;

        rewardsEnabled[0] = false;
        rewardsEnabled[1] = true;
        rewardsEnabled[2] = false;

        // Setting token info
        issuer.setTokensInfo(
            tokenAddresses,
            enabled,
            burnable,
            rate,
            rewardsEnabled
        );

        // After state
        (
            bool enabled_burnable_after,
            bool burnable_burnable_after,
            ,
            uint rate_burnable_after,
            bool rewards_burnable_enabled_after
        ) = issuer.whitelist(address(burnableToken));
        (
            bool enabled_non_after,
            bool burnable_non_after,
            ,
            uint rate_non_after,
            bool rewards_burnable_non_after
        ) = issuer.whitelist(address(nonBurnableToken));
        (
            bool enabled_one_after,
            bool burnable_one_after,
            ,
            uint rate_one_after,
            bool rewards_one_after
        ) = issuer.whitelist(address(oneToOnetoken));

        // Assertions for after state
        vm.assertEq(enabled_burnable_after, false);
        vm.assertEq(burnable_burnable_after, false);
        vm.assertEq(enabled_non_after, true);
        vm.assertEq(burnable_non_after, true);
        vm.assertEq(enabled_one_after, false);
        vm.assertEq(burnable_one_after, false);

        vm.assertEq(rate_burnable_after, 20_000_000);
        vm.assertEq(rate_non_after, 40_000_000);
        vm.assertEq(rate_one_after, 1000_000_000_000_000);

        vm.assertEq(rewards_burnable_enabled_after, false);
        vm.assertEq(rewards_burnable_non_after, true);
        vm.assertEq(rewards_one_after, false);
    }

    function test_dynamic_pricing_and_bounds_1_per_day() public {
        uint target = 7;
        issuer.setLimits(1000, 60, 180, target);

        burnableToken.mint(user, 100e18);
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(user);
        burnableToken.approve(address(issuer), 100e18);
        vm.stopPrank();

        (, , uint lastMint, uint growthRate, ) = issuer.whitelist(
            address(burnableToken)
        );
        uint timeSinceLast = block.timestamp - lastMint;
        uint expectedNewGrowthRate = (growthRate * timeSinceLast) /
            ((7 days) / target);

        vm.assertLt(expectedNewGrowthRate, growthRate);

        vm.prank(user);
        issuer.issue(address(burnableToken), 1e10, user);
        vm.stopPrank();

        (, , , uint newGrowthRate, ) = issuer.whitelist(address(burnableToken));

        //1041666666
        vm.assertEq(newGrowthRate, expectedNewGrowthRate);
    }

    function test_dynamic_pricing_and_bounds_2_per_day() public {
        uint target = 14;
        issuer.setLimits(1000, 60, 180, target);

        burnableToken.mint(user, 100e18);
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(user);
        burnableToken.approve(address(issuer), 100e18);
        vm.stopPrank();

        (, , uint lastMint, uint growthRate, ) = issuer.whitelist(
            address(burnableToken)
        );
        uint timeSinceLast = block.timestamp - lastMint;
        uint expectedNewGrowthRate = (growthRate * timeSinceLast) /
            ((7 days) / target);

        vm.assertLt(expectedNewGrowthRate, standardGrowth);

        vm.assertLt(1, growthRate);

        vm.prank(user);
        issuer.issue(address(burnableToken), 1e10, user);
        vm.stopPrank();

        (, , , uint growthRate_post_mint, ) = issuer.whitelist(
            address(burnableToken)
        );

        //2083333333
        vm.assertEq(growthRate_post_mint, expectedNewGrowthRate);

        vm.roll(block.number + 1);
        //18 hours in the future
        vm.warp(currentTime + 64800);

        (, , lastMint, growthRate, ) = issuer.whitelist(address(burnableToken));
        timeSinceLast = block.timestamp - lastMint;
        uint expectedNewGrowthRate2 = (growthRate * timeSinceLast) /
            ((7 days) / target);

        vm.assertGt(expectedNewGrowthRate2, expectedNewGrowthRate);

        vm.prank(user);
        issuer.issue(address(burnableToken), 1e10, user);
        vm.stopPrank();

        (, , , growthRate_post_mint, ) = issuer.whitelist(
            address(burnableToken)
        );
        vm.assertEq(growthRate_post_mint, expectedNewGrowthRate2);
    }

    function test_invalid_mint_target_should_fail() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidMintTarget.selector, 0));
        issuer.setLimits(100, 1, 1, 0);
        vm.expectRevert(
            abi.encodeWithSelector(InvalidMintTarget.selector, 1001)
        );
        issuer.setLimits(100, 1, 1, 1001);
    }

    function test_currentPrice_is_accurate() public {
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);
        //we expect the price to now be (9000*10_000_000_000) = 9e13
        uint actualPrice = issuer.currentPrice(address(burnableToken));
        vm.assertEq(actualPrice, 9e13);
    }

    function test_issue_burnable_token() public {
        burnableToken.mint(user, 100e18);
        uint burnableTotalSupplyBefore = burnableToken.totalSupply();

        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(user);
        burnableToken.approve(address(issuer), 100e18);
        vm.stopPrank();

        //also test that minting token makes no additional transfers
        couponContract.setMinter(address(this), true);
        couponContract.mint(100 ether, address(issuer));
        uint flaxBalanceOnIssuerBefore = couponContract.balanceOf(
            address(issuer)
        );

        vm.prank(user);
        issuer.issue(address(burnableToken), 35e17, recipient);
        vm.stopPrank();
        assertEq(flxBalance(recipient), 315e18, "Coupons should be minted");

        uint flaxBalanceOnIssuerAfter = couponContract.balanceOf(
            address(issuer)
        );
        vm.assertEq(flaxBalanceOnIssuerAfter, flaxBalanceOnIssuerBefore);

        uint burntAmount = burnableTotalSupplyBefore -
            burnableToken.totalSupply();

        assertEq(burntAmount, 35e17);

        //failing from here
        vm.roll(block.number + 2);
        vm.warp(block.timestamp + 86600);

        vm.roll(block.number + 3);

        uint balanceOfUserBefore = couponContract.balanceOf(user);
        uint balanceBefore = couponContract.balanceOf(recipient);
        vm.prank(recipient);
        tokenLockupPlan.redeemAllPlans();

        vm.stopPrank();
        uint balanceAfter = couponContract.balanceOf(recipient);
        uint balanceOfUserAfter = couponContract.balanceOf(user);
        vm.assertEq(balanceAfter - balanceBefore, 315e18);

        vm.assertEq(balanceOfUserAfter - balanceOfUserBefore, 0);
    }

    //Note: coupons issued are fewer than 1
    function test_issue_non_burnable_token() public {
        nonBurnableToken.mint(user, 1e20);

        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //1 day in the future should mint 864 tokens per 1 token
        vm.warp(currentTime + 86400);

        vm.prank(user);
        nonBurnableToken.approve(address(issuer), 100e18);
        vm.stopPrank();
        vm.prank(user);
        issuer.issue(address(nonBurnableToken), 1e18, user);
        vm.stopPrank();

        assertEq(flxBalance(user), 864 ether, "Coupons should be minted");
        uint balanceOfTokenOnIssuer = nonBurnableToken.balanceOf(
            address(issuer)
        );
        assertEq(balanceOfTokenOnIssuer, 1e18);
    }

    //when deploying on mainnet, we want to initially set growth low so that no one misses out
    function test_one_coupon_per_token_per_year_growth() public {
        //expection: 32150 tera is ONE per year.

        //resets price to zero
        uint target = 1;
        issuer.setLimits(1000, 60, 180, target);
        issuer.setTokenInfo(
            address(nonBurnableToken),
            true,
            false,
            32150,
            false
        );
        uint priceBefore = issuer.currentPrice(address(nonBurnableToken));
        vm.assertEq(priceBefore, 0);
        //jump 1 year
        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 31104000);

        uint priceAfter = issuer.currentPrice(address(nonBurnableToken));
        vm.assertEq(priceAfter, 999993600000);

        uint flx_balanceBefore = flxBalance(user);
        vm.prank(user);
        nonBurnableToken.approve(address(issuer), 1e18);
        vm.stopPrank();
        vm.prank(user);
        nonBurnableToken.mint(user, 1 ether);
        vm.stopPrank();
        vm.prank(user);
        issuer.issue(address(nonBurnableToken), 1 ether, user);
        vm.stopPrank();
        uint flx_balanceAfter = flxBalance(user);

        uint increase = flx_balanceAfter - flx_balanceBefore;

        //precision loss
        vm.assertGt(increase, (1 ether * 999) / 1000);
        vm.assertLt(increase, (1 ether * 1001) / 1000);
    }

    function test_issue_fail_on_disabled_token() public {
        issuer.setTokenInfo(
            address(nonBurnableToken),
            false,
            false,
            standardGrowth,
            false
        ); // Disable the token
        vm.prank(owner);
        nonBurnableToken.approve(address(issuer), 1e18);
        vm.expectRevert("Token not enabled for issuance");
        issuer.issue(address(nonBurnableToken), 1e18, owner);
    }

    function test_access_control() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        ); // Should revert
        vm.stopPrank();

        vm.startPrank(address(0x1));
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                notOwner
            )
        );
        issuer.setLimits(10, 1, 1, 1);
        vm.stopPrank();
    }

    function test_switch_custom_reward_token_flushes_old_balance() public {
        MockToken reward1 = new MockToken("Reward", "V1");
        reward1.mint(address(issuer), 4 ether);
        uint balanceOfCallerBefore = reward1.balanceOf(address(this));

        vm.assertEq(balanceOfCallerBefore, 0);

        issuer.setRewardConfig(address(reward1), 10 ether, 1 ether);

        MockToken reward2 = new MockToken("Reward", "V2");

        issuer.setRewardConfig(address(reward2), 2 ether, 1 ether);

        uint balanceOfCallerAfter = reward1.balanceOf(address(this));

        vm.assertEq(balanceOfCallerAfter, 4 ether);
    }

    function test_reward_token_flax_threshold_too_low_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                minFlaxMintThresholdTooLow.selector,
                1 ether - 1
            )
        );
        issuer.setRewardConfig(address(burnableToken), 1 ether - 1, 1 ether);
    }

    function test_mint_below_and_above_reward_threshold() public {
        MockToken reward1 = new MockToken("Reward", "V1");
        reward1.mint(address(issuer), 2000 ether);
        issuer.setLimits(8000, 40, 180, 1);
        issuer.setRewardConfig(address(reward1), 10 ether, 12 ether);
        issuer.setTokenInfo(address(burnableToken), true, true, 11574074, true);

        //price = (duration*teraCouponPerSecon)/1e12
        //=> price*1e12 = (duration*teraCouponPerSecond)
        //=>duration = (price*1e12)/teraCouponPerSecond
        vm.deal(user, 1 ether);
        vm.prank(user);
        burnableToken.approve(address(issuer), type(uint).max);
        vm.stopPrank();
        burnableToken.mint(user, 20 ether);
        vm.warp(block.timestamp + 1 days);
        vm.roll(block.number + 1);

        uint rewardBalanceBefore = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceBefore, 0);
        //mint above threshold
        vm.prank(user);
        issuer.issue(address(burnableToken), 11 ether, user);
        vm.stopPrank();
        uint rewardBalanceAfter = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceAfter, 12 ether);

        vm.warp(block.timestamp + 1 days);
        vm.roll(block.number + 1);

        //mint below flax threshold
        vm.prank(user);
        issuer.issue(address(burnableToken), 1 ether, user);

        uint rewardBalanceAfterBelow = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceAfterBelow, 12 ether);
    }

    function test_mint_above_threshold_does_nothing_for_disabled() public {
        MockToken reward1 = new MockToken("Reward", "V1");
        reward1.mint(address(issuer), 2000 ether);

        issuer.setRewardConfig(address(reward1), 10 ether, 12 ether);
        issuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );

        //price = (duration*teraCouponPerSecon)/1e12
        //=> price*1e12 = (duration*teraCouponPerSecond)
        //=>duration = (price*1e12)/teraCouponPerSecond
        uint durationPerToken = (10 ether * 1e12) / 10_000_000;
        vm.deal(user, 1 ether);
        vm.prank(user);
        burnableToken.approve(address(issuer), type(uint).max);
        vm.stopPrank();
        burnableToken.mint(user, 20 ether);
        vm.warp(block.timestamp + (durationPerToken) / 10);

        uint rewardBalanceBefore = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceBefore, 0);
        //mint above threshold
        vm.prank(user);
        issuer.issue(address(burnableToken), 20 ether, user);
        vm.stopPrank();
        uint rewardBalanceAfter = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceAfter, 0 ether);
    }

    function test_mint_when_balance_of_reward_token_too_low_does_nothing()
        public
    {
        MockToken reward1 = new MockToken("Reward", "V1");
        reward1.mint(address(issuer), 12 ether - 1);
        issuer.setLimits(8000, 40, 180, 1);
        issuer.setRewardConfig(address(reward1), 10 ether, 12 ether);
        issuer.setTokenInfo(address(burnableToken), true, true, 11574074, true);

        //price = (duration*teraCouponPerSecon)/1e12
        //=> price*1e12 = (duration*teraCouponPerSecond)
        //=>duration = (price*1e12)/teraCouponPerSecond
        vm.deal(user, 1 ether);
        vm.prank(user);
        burnableToken.approve(address(issuer), type(uint).max);
        vm.stopPrank();
        burnableToken.mint(user, 20 ether);
        vm.warp(block.timestamp + 1 days);
        vm.roll(block.number + 1);

        uint rewardBalanceBefore = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceBefore, 0);
        //mint above threshold
        vm.prank(user);
        issuer.issue(address(burnableToken), 11 ether, user);
        vm.stopPrank();
        uint rewardBalanceAfter = reward1.balanceOf(user);
        vm.assertEq(rewardBalanceAfter, 0);
    }

    function test_non_minting_with_insufficient_balance_fails() public {
        Issuer nonMintingIssuer = new Issuer(
            address(couponContract),
            address(hedgeyAdapter),
            false
        );
        burnableToken.mint(user, 100e18);
        nonMintingIssuer.setLimits(10000, 60, 1, 1);
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        nonMintingIssuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(user);
        burnableToken.approve(address(nonMintingIssuer), 100e18);
        vm.stopPrank();

        couponContract.setMinter(address(this), true);
        couponContract.mint(315e18 - 1, address(nonMintingIssuer));
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                address(nonMintingIssuer),
                315e18 - 1,
                315e18
            )
        );
        nonMintingIssuer.issue(address(burnableToken), 35e17, recipient);
    }

    function test_non_mint_with_sufficient_balance_succeeds() public {
        Issuer nonMintingIssuer = new Issuer(
            address(couponContract),
            address(hedgeyAdapter),
            false
        );
        burnableToken.mint(user, 100e18);
        nonMintingIssuer.setLimits(10000, 60, 1, 1);
        uint currentTime = block.timestamp;
        //reset token price to zero at current timestamp
        nonMintingIssuer.setTokenInfo(
            address(burnableToken),
            true,
            true,
            standardGrowth,
            false
        );
        vm.roll(block.number + 1);
        //2.5 hours in the future
        vm.warp(currentTime + 9000);

        vm.prank(user);
        burnableToken.approve(address(nonMintingIssuer), 100e18);
        vm.stopPrank();

        couponContract.setMinter(address(this), true);
        couponContract.mint(315e18, address(nonMintingIssuer));

        uint total_flax_supply_before = couponContract.totalSupply();
        vm.prank(user);
        nonMintingIssuer.issue(address(burnableToken), 35e17, recipient);
        vm.stopPrank();
        assertEq(
            flxBalance(recipient),
            315e18,
            "Coupons should be transferred"
        );

        uint total_flax_supply_after = couponContract.totalSupply();
        //assert no new minting
        vm.assertEq(total_flax_supply_after, total_flax_supply_before);
    }
}
