// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@oz_flax/contracts/access/Ownable.sol";
import "./ICoupon.sol";
import "./Errors.sol";
import "@oz_flax/contracts/utils/ReentrancyGuard.sol";
import "./IIssuer.sol";
import "./HedgeyAdapter.sol";
import {TokenLockupPlans} from "@hedgey/lockup/TokenLockupPlans.sol";

// lockTime = offset + deposit/threshold_size * days_multiple;
struct LockupConfig {
    uint threshold_size; // in ether units
    uint days_multiple; // number of extra days of locking
    uint offset; //base number of lockup days
}

contract Issuer is IIssuer, Ownable, ReentrancyGuard {
    mapping(address => TokenInfo) public whitelist;
    ICoupon public couponContract;
    HedgeyAdapter stream;
    LockupConfig public lockupConfig;
    uint targetedMintsPerWeek;

    constructor(
        address couponAddress,
        address streamAddress
    ) Ownable(msg.sender) {
        couponContract = ICoupon(couponAddress);
        stream = HedgeyAdapter(streamAddress);
    }

    function setLimits(
        uint threshold_size,
        uint days_multiple,
        uint offset,
        uint _targetedMintsPerWeek
    ) external override onlyOwner {
        if (
            threshold_size > 20000 ||
            days_multiple > 180 ||
            offset > 4 * (365)
        ) {
            revert InvalidLockConfig(threshold_size, days_multiple, offset);
        }

        lockupConfig = LockupConfig({
            days_multiple: days_multiple,
            threshold_size: threshold_size,
            offset: offset
        });
        targetedMintsPerWeek = _targetedMintsPerWeek;
        if (_targetedMintsPerWeek == 0 || _targetedMintsPerWeek >= (1000)) {
            revert InvalidMintTarget(_targetedMintsPerWeek);
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
        uint amount,
        address recipient
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

        emit CouponsIssued(recipient, inputToken, amount, coupons);

        // Burn if applicable
        if (info.burnable) {
            try ICoupon(inputToken).burn(amount) {} catch {
                revert("Failed to burn the input token");
            }
        }

        // Mint coupons
        couponContract.mint(coupons, address(stream));
        // lockTime = offset + deposit/threshold_size * days_multiple; 
        uint lockupDuration = lockupConfig.offset +
            (coupons / (lockupConfig.threshold_size * (1 ether))) *
            lockupConfig.days_multiple;
        nft = stream.lock(recipient, coupons, lockupDuration);

        uint timeSinceLastMint = block.timestamp - info.lastminted_timestamp;
        uint growth = info.teraCouponPerTokenPerSecond;
        growth =
            (growth * timeSinceLastMint) /
            ((7 days) / targetedMintsPerWeek);
        //minimum 1 coupon per token per day growth
        growth = growth < 11574074 ? 11574074 : growth;
        info.lastminted_timestamp = block.timestamp;
        info.teraCouponPerTokenPerSecond = growth;

        //nonReentrant modifier makes the position of this line safe
        whitelist[inputToken] = info;
    }
}
