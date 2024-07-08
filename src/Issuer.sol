// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@oz_flax/contracts/access/Ownable.sol";
import "./ICoupon.sol";
import "./Errors.sol";
import "@oz_flax/contracts/utils/ReentrancyGuard.sol";
import "./IIssuer.sol";
import "./HedgeyAdapter.sol";
import {TokenLockupPlans} from "@hedgey/lockup/TokenLockupPlans.sol";


contract Issuer is IIssuer, Ownable, ReentrancyGuard {
    mapping(address => TokenInfo) public whitelist;
    uint public override mintAllowance; //max mint allowance per tx
    ICoupon public couponContract;
    uint public teraCouponPerTokenPerSecond; // growth rate of Flax price in terms of token.
    HedgeyAdapter stream;
    uint public lockupDuration;

    constructor(address couponAddress, address streamAddress) Ownable(msg.sender) {
        couponContract = ICoupon(couponAddress);
        stream = HedgeyAdapter(streamAddress);
    }

    function setLimits(
        uint allowance,
        uint rate,
        uint lockupDuration_Days
    ) external override onlyOwner {
        mintAllowance = allowance;
        teraCouponPerTokenPerSecond = rate;
        lockupDuration = lockupDuration_Days;
    }

    function setTokensInfo(
        address[] memory tokens,
        bool[] memory enabled,
        bool[] memory burnable
    ) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            _setTokenInfo(tokens[i], enabled[i], burnable[i]);
        }
        emit TokensWhiteListed(tokens, enabled, block.timestamp);
    }

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable
    ) external override onlyOwner {
        _setTokenInfo(token, enabled, burnable);

        emit TokenWhitelisted(token, enabled, burnable, block.timestamp);
    }

    function _setTokenInfo(address token, bool enabled, bool burnable) private {
        whitelist[token] = TokenInfo(enabled, burnable, block.timestamp);
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
                teraCouponPerTokenPerSecond;
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

        //nonReentrant modifier makes the position of this line safe
        whitelist[inputToken].lastminted_timestamp = block.timestamp;
    }
}
