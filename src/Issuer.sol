// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./ICoupon.sol"; // Assuming this path is correct as per your project structure
import "./Errors.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
contract Issuer is Ownable, ReentrancyGuard {
    struct TokenInfo {
        bool enabled;
        bool burnable;
        uint teraCouponPerToken;
    }

    mapping(address => TokenInfo) public whitelist;
    uint public mintAllowance; //works just like spender allowance.
    mapping(address => bool) public allowanceIncreasers; // whitelisted to increase mintAllowance

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
        uint coupons
    );

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
    ) public onlyOwner {
        allowanceIncreasers[increaser] = _whitelist;
    }

    function increaseAllowance(uint amount) public onlyIncreaser {
        mintAllowance += amount;
    }

    //If we list poolTogether tokens and Issuer wins, we want to burn the EYE prize
    function burnBurnable(address tokenAddress) public {
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
    ) public onlyOwner {
        whitelist[token] = TokenInfo(enabled, burnable, teraCouponPerToken);
        emit TokenWhitelisted(token, enabled, burnable, teraCouponPerToken);
    }

    function setCouponContract(address newCouponAddress) public onlyOwner {
        couponContract = ICoupon(newCouponAddress);
    }

    function issue(address inputToken, uint amount) public nonReentrant {
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
        // emit CouponsIssued(msg.sender, inputToken, amount, coupons);
    }
}
