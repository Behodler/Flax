// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract IIssuer {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint lastminted_timestamp;
        uint teraCouponPerTokenPerSecond;
    }

    function mintAllowance() external virtual returns (uint);

    function currentPrice(address token) public view virtual returns (uint);

    function setLimits(uint allowance, uint lockDuration,uint targetedMintsPerday) external virtual;

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint startingRate
    ) external virtual;

    function setTokensInfo(
address[] memory tokens,
        bool[] memory enabled,
        bool[] memory burnable,
        uint [] memory startingRate
    ) external virtual;

    function setCouponContract(address newCouponAddress) external virtual;

    function issue(address inputToken, uint amount) external virtual returns (uint nft);

    // Events
    event TokenWhitelisted(
        address token,
        bool enabled,
        bool burnable,
        uint teraCouponPerToken
    );
    event TokensWhiteListed(address[] tokens, bool[] burnable, uint timestamp);
    event CouponsIssued(
        address indexed user,
        address indexed token,
        uint amount,
        uint coupons
    );
}
