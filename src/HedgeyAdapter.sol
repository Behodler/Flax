// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@oz_flax/contracts/token/ERC20/IERC20.sol";
import {TokenLockupPlans} from "@hedgey/lockup/TokenLockupPlans.sol";

contract HedgeyAdapter {
    IERC20 _flax;
    TokenLockupPlans public tokenLockupPlan;

    constructor(address flax, address hedgey) {
        _flax = IERC20(flax);
        tokenLockupPlan = TokenLockupPlans(hedgey);
    }

    function lock(
        address recipient,
        uint amount,
        uint durationInDays
    ) external returns (uint nft) {
        //No need for helper libs because this assumes flax
        uint durationInSeconds = durationInDays * 24 * 60 * 60;
        //linear streaming per second
        uint rate = amount / durationInSeconds;
        _flax.approve(address(tokenLockupPlan), amount);
        return tokenLockupPlan.createPlan(
            recipient,
            address(_flax),
            amount,
            block.timestamp + 60,
            0,
            rate,
            1
        );
    }
}
