// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IAsset {
// solhint-disable-previous-line no-empty-blocks
}

interface IVault {
    /**
     * @dev A call that has NonReentrant modifier in the Vault.
     */
    function manageUserBalance(UserBalanceOp[] memory ops) external payable;

    struct UserBalanceOp {
        UserBalanceOpKind kind;
        IAsset asset;
        uint256 amount;
        address sender;
        address payable recipient;
    }

    enum UserBalanceOpKind {
        DEPOSIT_INTERNAL,
        WITHDRAW_INTERNAL,
        TRANSFER_INTERNAL,
        TRANSFER_EXTERNAL
    }

    /**
     * @dev Returns a Pool's contract address and specialization setting.
     */
    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);

    // There are three specialization settings for Pools, which allow for cheaper swaps at the cost of reduced
    // functionality:
    //
    //  - General: no specialization, suited for all Pools. IGeneralPool is used for swap request callbacks, passing the
    // balance of all tokens in the Pool. These Pools have the largest swap costs (because of the extra storage reads),
    // which increases with the number of registered tokens.
    //
    //  - Minimal Swap Info: IMinimalSwapInfoPool is used instead of IGeneralPool, which saves gas by only passing the
    // balance of the two tokens involved in the swap. This is suitable for some pricing algorithms, like the weighted
    // constant product one popularized by Balancer V1. Swap costs are smaller compared to general Pools, and are
    // independent of the number of registered tokens.
    //
    //  - Two Token: only allows two tokens to be registered. This achieves the lowest possible swap gas cost. Like
    // minimal swap info Pools, these are called via IMinimalSwapInfoPool.
    enum PoolSpecialization {
        GENERAL,
        MINIMAL_SWAP_INFO,
        TWO_TOKEN
    }
}
