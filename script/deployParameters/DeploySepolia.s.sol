// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../DeployStableWrapperFactory.s.sol";

contract DeploySepolia is DeployStableWrapperFactory {
    function setUp() public override {
        params = FactoryParameters({
            vault: 0xBA12222222228d8Ba445958a75a0704d566BF2C8,
            owner: 0xC466af7ff16ef0f1A7fa4E23E095E47a4058D791
        });
    }
}
