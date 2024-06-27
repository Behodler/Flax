// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract IIssuer {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint lastminted_timestamp;
    }

    function mintAllowance() external virtual returns (uint);

    function currentPrice(address token) public view virtual returns (uint);

    function setLimits(uint allowance, uint rate) external virtual;

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable
    ) external virtual;

    function setCouponContract(address newCouponAddress) external virtual;

    function issue(address inputToken, uint amount) external virtual;

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
