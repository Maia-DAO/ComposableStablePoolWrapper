// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {MockERC20, ERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {ComposableStablePoolWrapper} from "src/ComposableStablePoolWrapper.sol";

import {IComposableStablePool} from "../interfaces/IComposableStablePool.sol";

interface IPoolInfo {
    function getTokens() external view returns (MockERC20[] memory);

    function tokens(uint256) external view returns (MockERC20);

    function stablePoolWrapper() external view returns (ComposableStablePoolWrapper);

    function poolId() external view returns (bytes32);
    function bptAddress() external view returns (address);
    function bptToken() external view returns (ERC20);
    function bpt() external view returns (IComposableStablePool);

    function token0Address() external view returns (address);
    function token0() external view returns (MockERC20);

    function token1Address() external view returns (address);
    function token1() external view returns (MockERC20);

    function token2Address() external view returns (address);
    function token2() external view returns (MockERC20);

    function token3Address() external view returns (address);
    function token3() external view returns (MockERC20);

    function token4Address() external view returns (address);
    function token4() external view returns (MockERC20);

    function whale() external view returns (address);
}
