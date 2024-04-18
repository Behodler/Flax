// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./ICoupon.sol"; // Assuming this path is correct as per your project structure

contract Issuer is Ownable {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint teraCouponPerToken;
    }

    struct IssuanceData {
        uint runningAmount;
        uint lastIssuedAt;
    }

    mapping(address => TokenInfo) public whitelist;
    mapping(address => IssuanceData) public issuancePerTokenPerDay;
    uint public MaxIssuancePerDay;
    ICoupon public couponContract;

    // Events
    event TokenWhitelisted(
        address token,
        bool enabled,
        bool burnable,
        uint teraCouponPerToken
    );
    event CouponsIssued(
        address indexed user,
        address indexed token,
        uint amount,
        uint coupons,
        uint runningAmount
    );

    constructor(address couponAddress) Ownable(msg.sender) {
        couponContract = ICoupon(couponAddress);
    }

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint teraCouponPerToken
    ) public onlyOwner {
        whitelist[token] = TokenInfo(enabled, burnable, teraCouponPerToken);
        emit TokenWhitelisted(token, enabled, burnable, teraCouponPerToken);
    }

    function setMaxIssuancePerDay(uint _maxIssuancePerDay) public onlyOwner {
        MaxIssuancePerDay = _maxIssuancePerDay;
    }

    function setCouponContract(address newCouponAddress) public onlyOwner {
        couponContract = ICoupon(newCouponAddress);
    }

    function issue(address inputToken, uint amount) public {
        require(
            whitelist[inputToken].enabled,
            "Token not enabled for issuance"
        );
        TokenInfo memory info = whitelist[inputToken];

        // Calculate coupons to issue with precision adjustment
        uint coupons = (amount * info.teraCouponPerToken) / 1e12;

        // Check and update issuance limits
        IssuanceData storage data = issuancePerTokenPerDay[inputToken];
        uint currentTime = block.timestamp;
        emit CouponsIssued(
            msg.sender,
            inputToken,
            amount,
            coupons,
            data.runningAmount
        );
        if (currentTime - data.lastIssuedAt < 24 hours) {
            require(
                data.runningAmount + coupons <= MaxIssuancePerDay,
                "Max issuance limit exceeded for today"
            );
            data.runningAmount += coupons;
        } else {
            data.lastIssuedAt = currentTime;
            data.runningAmount = coupons;
        }

        // Transfer tokens to this contract
        IERC20(inputToken).transferFrom(msg.sender, address(this), amount);

        // Burn if applicable
        if (info.burnable) {
            try ICoupon(inputToken).burn(amount) {} catch {
                revert("Failed to burn the input token");
            }
        }

        // Mint coupons
        couponContract.mint(coupons, msg.sender);
        // emit CouponsIssued(msg.sender, inputToken, amount, coupons);
    }
}
