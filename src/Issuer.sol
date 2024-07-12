// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@oz_flax/contracts/access/Ownable.sol";
import "./ICoupon.sol";
import "./Errors.sol";
import "@oz_flax/contracts/utils/ReentrancyGuard.sol";
import "./IIssuer.sol";
import "./HedgeyAdapter.sol";
import {TokenLockupPlans} from "@hedgey/lockup/TokenLockupPlans.sol";

/*
let T = time in secods since token last mint. Let G = flax_per_token_per_second. Start of at a rate such that price grows at 1 flax per token per day.
If T > 1 day
  factor = day/T
else if T < day
  factor = T/day
*/

contract Issuer is IIssuer, Ownable, ReentrancyGuard {
    mapping(address => TokenInfo) public whitelist;
    uint public override mintAllowance; //max mint allowance per tx
    ICoupon public couponContract;
    HedgeyAdapter stream;
    uint public lockupDuration;
    uint targetedMintsPerday;

    constructor(
        address couponAddress,
        address streamAddress
    ) Ownable(msg.sender) {
        couponContract = ICoupon(couponAddress);
        stream = HedgeyAdapter(streamAddress);
    }

    function setLimits(
        uint allowance,
        uint lockupDuration_Days,
        uint _targetedMintsPerday
    ) external override onlyOwner {
        mintAllowance = allowance;
        lockupDuration = lockupDuration_Days;
        targetedMintsPerday = _targetedMintsPerday;
        if (targetedMintsPerday == 0 || targetedMintsPerday >= (1000)) {
            revert InvalidMintTarget(targetedMintsPerday);
        }
    }

    function setTokensInfo(
        address[] memory tokens,
        bool[] memory enabled,
        bool[] memory burnable,
        uint[] memory startingRate
    ) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            _setTokenInfo(tokens[i], enabled[i], burnable[i], startingRate[i]);
        }
        emit TokensWhiteListed(tokens, enabled, block.timestamp);
    }

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint startingRate
    ) external override onlyOwner {
        _setTokenInfo(token, enabled, burnable, startingRate);

        emit TokenWhitelisted(token, enabled, burnable, block.timestamp);
    }

    function _setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint initialGrowth
    ) private {
        whitelist[token] = TokenInfo(
            enabled,
            burnable,
            block.timestamp,
            initialGrowth
        );
    }

    function setCouponContract(
        address newCouponAddress
    ) external override onlyOwner {
        couponContract = ICoupon(newCouponAddress);
    }

    //TODO: new formula
    function currentPrice(
        address token
    ) public view override returns (uint teraCouponPerToken) {
        TokenInfo memory tokenInfo = whitelist[token];
        if (tokenInfo.enabled) {
            teraCouponPerToken =
                (block.timestamp - tokenInfo.lastminted_timestamp) *
                tokenInfo.teraCouponPerTokenPerSecond;
        }
    }

    function issue(
        address inputToken,
        uint amount
    ) external override nonReentrant returns (uint nft) {
        require(
            whitelist[inputToken].enabled,
            "Token not enabled for issuance"
        );
        TokenInfo memory info = whitelist[inputToken];
        uint before = IERC20(inputToken).balanceOf(address(this));
        IERC20(inputToken).transferFrom(msg.sender, address(this), amount);
        amount = IERC20(inputToken).balanceOf(address(this)) - before;

        // Calculate coupons to issue with precision adjustment
        uint coupons = (amount * currentPrice(inputToken)) / 1e12;

        emit CouponsIssued(msg.sender, inputToken, amount, coupons);

        if (coupons > mintAllowance) {
            revert ExcessiveMinting(coupons, mintAllowance);
        }

        // Burn if applicable
        if (info.burnable) {
            try ICoupon(inputToken).burn(amount) {} catch {
                revert("Failed to burn the input token");
            }
        }

        // Mint coupons
        couponContract.mint(coupons, address(stream));
        nft = stream.lock(msg.sender, coupons, lockupDuration);

        uint timeSinceLastMint = block.timestamp - info.lastminted_timestamp;
        uint growth = info.teraCouponPerTokenPerSecond;
        growth =
            (growth * timeSinceLastMint) /
            ((1 days) / targetedMintsPerday);
        //minimum 1 coupon per token per day growth
        growth = growth < 11574074 ? 11574074 : growth;
        info.lastminted_timestamp = block.timestamp;
        info.teraCouponPerTokenPerSecond = growth;

        //nonReentrant modifier makes the position of this line safe
        whitelist[inputToken] = info;
    }
}
