// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";

import {AuraBalInfo} from "./pools/AuraBalInfo.sol";
import {ThreeCryptoInfo} from "./pools/ThreeCryptoInfo.sol";

import {IPoolInfo} from "./interfaces/IPoolInfo.sol";

import {MainnetPoolsWrapperLibTest} from "./lib/MainnetPoolsWrapperLibTest.t.sol";

contract MainnetPoolsWrapperLibTest_AuraBal is MainnetPoolsWrapperLibTest {
    function _setUpWrapper() internal override returns (IPoolInfo poolInfo) {
        poolInfo = new AuraBalInfo();
    }
}

contract MainnetPoolsWrapperLibTest_ThreeCrypto is MainnetPoolsWrapperLibTest {
    function _setUpWrapper() internal override returns (IPoolInfo poolInfo) {
        poolInfo = new ThreeCryptoInfo();
    }
}
