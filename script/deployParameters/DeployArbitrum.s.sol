// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../DeployStableWrapperFactory.s.sol";

contract DeployArbitrum is DeployStableWrapperFactory {
    function setUp() public override {
        params = FactoryParameters({
            vault: 0xBA12222222228d8Ba445958a75a0704d566BF2C8,
            owner: 0x00000000206ad3e31DffF979Ccef06dE72a9E027
        });
    }
}
