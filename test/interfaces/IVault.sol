// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library ExitKind {
    uint256 constant EXACT_BPT_IN_FOR_ONE_TOKEN_OUT = 0;
    uint256 constant EXACT_BPT_IN_FOR_TOKENS_OUT = 1;
    uint256 constant BPT_IN_FOR_EXACT_TOKENS_OUT = 2;
}

library JoinKind {
    uint256 constant INIT = 0;
    uint256 constant EXACT_TOKENS_IN_FOR_BPT_OUT = 1;
    uint256 constant TOKEN_IN_FOR_EXACT_BPT_OUT = 2;
}

struct ExitPoolRequest {
    address[] assets;
    uint256[] minAmountsOut;
    bytes userData;
    bool toInternalBalance;
}

struct JoinPoolRequest {
    address[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
}

struct JoinPoolUserData {
    uint256 kind;
    uint256[] amountsIn;
}

interface IVault {
    function exitPool(bytes32 poolId, address sender, address recipient, ExitPoolRequest calldata request) external;

    function joinPool(bytes32 poolId, address sender, address recipient, JoinPoolRequest calldata request) external;

    function getPoolTokens(bytes32)
        external
        view
        returns (address[] memory tokens, uint256[] memory balances, uint256 lastChangeBlock);
}

interface IBalancerQueries {
    function queryExit(bytes32 poolId, address sender, address recipient, ExitPoolRequest calldata request)
        external
        returns (uint256 bptIn, uint256[] memory amountsOut);

    function queryJoin(bytes32 poolId, address sender, address recipient, JoinPoolRequest calldata request)
        external
        returns (uint256 bptOut, uint256[] calldata amountsIn);
}
