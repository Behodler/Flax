// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract IIssuer {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint lastminted_timestamp;
        uint teraCouponPerTokenPerSecond;
        bool extraRewardEnabled;
    }

    function currentPrice(address token) public view virtual returns (uint);

    function setLimits(
        uint threshold_size,
        uint days_multiple,
        uint offset,
        uint _targetedMintsPerWeek
    ) external virtual;

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint startingRate,
        bool extraRewardEnabled
    ) external virtual;

    function setTokensInfo(
        address[] memory tokens,
        bool[] memory enabled,
        bool[] memory burnable,
        uint[] memory startingRate,
        bool[] memory extraRewardEnabled
    ) external virtual;

    function setRewardConfig(
        address token,
        uint minFlaxMintThreshold,
        uint rewardSize
    ) public virtual;

    function setCouponContract(address newCouponAddress) external virtual;

    function issue(
        address inputToken,
        uint amount,
        address recipient
    ) external virtual returns (uint nft);

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
