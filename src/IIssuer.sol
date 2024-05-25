// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIssuer {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint teraCouponPerToken;
    }

    function allowanceIncreasers(address) external returns (bool);
    function mintAllowance() external returns (uint);
    function whitelistAllowanceIncreasers(
        address increaser,
        bool _whitelist
    ) external;

    function increaseAllowance(uint amount) external;
    function burnBurnable(address tokenAddress) external;
    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint teraCouponPerToken
    ) external;

    function setCouponContract(address newCouponAddress) external;
    function issue(address inputToken, uint amount) external;

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
        uint coupons
    );
}
