// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "../interfaces/IPoolInfo.sol";

abstract contract BasePoolInfo is IPoolInfo {
    MockERC20[] public override tokens;

    ComposableStablePoolWrapper public override stablePoolWrapper;

    function getTokens() public view override returns (MockERC20[] memory) {
        return tokens;
    }

    function INIT() external pure override returns (uint256) {
        return uint256(JoinKind.INIT);
    }

    function EXACT_BPT_IN_FOR_ALL_TOKENS_OUT() external pure virtual override returns (uint256) {
        return uint256(ExitKind.EXACT_BPT_IN_FOR_ALL_TOKENS_OUT);
    }
}
