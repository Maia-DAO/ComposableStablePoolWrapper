// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IComposableStablePool {
    /**
     * @dev This function returns the appreciation of BPT relative to the underlying tokens, as an 18 decimal fixed
     * point number. It is simply the ratio of the invariant to the BPT supply.
     *
     * The total supply is initialized to equal the invariant, so this value starts at one. During Pool operation the
     * invariant always grows and shrinks either proportionally to the total supply (in scenarios with no price impact,
     * e.g. proportional joins), or grows faster and shrinks more slowly than it (whenever swap fees are collected or
     * the token rates increase). Therefore, the rate is a monotonically increasing function.
     *
     * WARNING: since this function reads balances directly from the Vault, it is potentially subject to manipulation
     * via reentrancy. However, this can only happen if one of the tokens in the Pool contains some form of callback
     * behavior in the `transferFrom` function (like ERC777 tokens do). These tokens are strictly incompatible with the
     * Vault and Pool design, and are not safe to be used.
     */
    function getRate() external view returns (uint256);

    function getPoolId() external view returns (bytes32);
}
