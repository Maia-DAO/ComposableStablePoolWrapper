// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library ExitKind {
    uint256 constant EXACT_BPT_IN_FOR_ONE_TOKEN_OUT = 0;
    uint256 constant EXACT_BPT_IN_FOR_TOKENS_OUT = 1;
    uint256 constant BPT_IN_FOR_EXACT_TOKENS_OUT = 2;
}

interface IVault {

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function exitPool(bytes32 poolId, address sender, address recipient, ExitPoolRequest calldata request) external;
}
