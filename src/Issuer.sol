// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@oz_flax/contracts/access/Ownable.sol";
import "./ICoupon.sol";
import "./Errors.sol";
import "@oz_flax/contracts/utils/ReentrancyGuard.sol";
import "./IIssuer.sol";

contract Issuer is IIssuer, Ownable, ReentrancyGuard {

    mapping(address => TokenInfo) public whitelist;
    uint public mintAllowance; //works just like spender allowance.
    mapping(address => bool) public allowanceIncreasers; // whitelisted to increase mintAllowance

    ICoupon public couponContract;

    constructor(address couponAddress) Ownable(msg.sender) {
        couponContract = ICoupon(couponAddress);
    }

    modifier onlyIncreaser() {
        if (!allowanceIncreasers[msg.sender]) {
            revert OnlyWhitelistedIncreasers(msg.sender);
        }
        _;
    }

    function whitelistAllowanceIncreasers(
        address increaser,
        bool _whitelist
    ) external onlyOwner {
        allowanceIncreasers[increaser] = _whitelist;
    }

    function increaseAllowance(uint amount) external onlyIncreaser {
        mintAllowance += amount;
    }

    //If we list poolTogether tokens and Issuer wins, we want to burn the EYE prize
    function burnBurnable(address tokenAddress) external {
        require(
            whitelist[tokenAddress].enabled && whitelist[tokenAddress].burnable,
            "Only burnable tokens"
        );
        uint balance = ICoupon(tokenAddress).balanceOf(address(this));
        try ICoupon(tokenAddress).burn(balance) {} catch {
            revert("Failed to burn the input token");
        }
    }

    function setTokenInfo(
        address token,
        bool enabled,
        bool burnable,
        uint teraCouponPerToken
    ) external onlyOwner {
        whitelist[token] = TokenInfo(enabled, burnable, teraCouponPerToken);
        emit TokenWhitelisted(token, enabled, burnable, teraCouponPerToken);
    }

    function setCouponContract(address newCouponAddress) external onlyOwner {
        couponContract = ICoupon(newCouponAddress);
    }

    function issue(address inputToken, uint amount) external nonReentrant {
        require(
            whitelist[inputToken].enabled,
            "Token not enabled for issuance"
        );
        TokenInfo memory info = whitelist[inputToken];
        uint before = IERC20(inputToken).balanceOf(address(this));
        IERC20(inputToken).transferFrom(msg.sender, address(this), amount);
        amount = IERC20(inputToken).balanceOf(address(this)) - before;
        // Calculate coupons to issue with precision adjustment
        uint coupons = (amount * info.teraCouponPerToken) / 1e12;

        emit CouponsIssued(msg.sender, inputToken, amount, coupons);

        if (coupons > mintAllowance) {
            revert ExcessiveMinting(coupons, mintAllowance);
        }
        mintAllowance -= coupons;
        // Transfer tokens to this contract

        // Burn if applicable
        if (info.burnable) {
            try ICoupon(inputToken).burn(amount) {} catch {
                revert("Failed to burn the input token");
            }
        }

        // Mint coupons
        couponContract.mint(coupons, msg.sender);
    }
}
