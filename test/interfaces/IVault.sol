// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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

struct ExitPoolUserData {
    uint256 kind;
    uint256 balance;
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
