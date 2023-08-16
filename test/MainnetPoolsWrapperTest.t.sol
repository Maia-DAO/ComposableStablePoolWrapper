// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";

import {AuraBalInfo} from "./pools/AuraBalInfo.sol";
import {New2TokenInfo} from "./pools/New2TokenInfo.sol";
import {ThreeCryptoInfo} from "./pools/ThreeCryptoInfo.sol";

import {IPoolInfo} from "./interfaces/IPoolInfo.sol";

import {IComposableStablePoolFactory} from "./interfaces/IComposableStablePoolFactory.sol";
import {MainnetPoolsWrapperLibTest} from "./lib/MainnetPoolsWrapperLibTest.t.sol";

abstract contract OnlyExitTest is MainnetPoolsWrapperLibTest {
    function test_fork_initPool() public pure override {
        console2.log("this will always pass");
    }

    function test_fork_joinPool() public pure override {
        console2.log("this will always pass");
    }

    function test_fork_queryJoin() public pure override {
        console2.log("this will always pass");
    }
}

contract MainnetPoolsWrapperLibTest_AuraBal is OnlyExitTest {
    function _setUpWrapper() internal override returns (IPoolInfo poolInfo) {
        poolInfo = new AuraBalInfo();
    }
}

contract MainnetPoolsWrapperLibTest_ThreeCrypto is OnlyExitTest {
    function _setUpWrapper() internal override returns (IPoolInfo poolInfo) {
        poolInfo = new ThreeCryptoInfo();
    }
}

abstract contract InitFirstTest is MainnetPoolsWrapperLibTest {
    function initThenTest(function() test) internal {
        test_fork_initPool();
        test();
    }

    function test_fork_exitPool() public override {
        initThenTest(super.test_fork_exitPool);
    }

    function test_fork_queryExit() public override {
        initThenTest(super.test_fork_queryExit);
    }

    function test_fork_joinPool() public override {
        initThenTest(super.test_fork_joinPool);
    }

    function test_fork_queryJoin() public override {
        initThenTest(super.test_fork_queryJoin);
    }

    function test_fork_convertToShares() public override {
        initThenTest(super.test_fork_convertToShares);
    }

    function test_fork_convertToAssets() public override {
        initThenTest(super.test_fork_convertToAssets);
    }

    function test_fork_previewMint() public override {
        initThenTest(super.test_fork_previewMint);
    }

    function test_fork_previewWithdraw() public override {
        initThenTest(super.test_fork_previewWithdraw);
    }
}

contract MainnetPoolsWrapperLibTest_New2Token is InitFirstTest {
    // ComposableStablePoolFactory
    address factoryAddress = 0xDB8d758BCb971e482B2C45f7F8a7740283A1bd3A;
    IComposableStablePoolFactory factory = IComposableStablePoolFactory(factoryAddress);

    function _setUpWrapper() internal override returns (IPoolInfo poolInfo) {
        poolInfo = new New2TokenInfo(factory);
    }
}
