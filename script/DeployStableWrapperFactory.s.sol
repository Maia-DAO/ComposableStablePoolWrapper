// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";

import "../src/factories/ComposableStablePoolWrapperFactory.sol";

struct FactoryParameters {
    address vault;
    address owner;
}

abstract contract DeployStableWrapperFactory is Script {
    FactoryParameters internal params;

    // set values for params and unsupported
    function setUp() public virtual;

    function run() external returns (ComposableStablePoolWrapperFactory factory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        logParams();

        factory = new ComposableStablePoolWrapperFactory(IVault(params.vault), params.owner);
        console2.log("Stable Wrapper Factory Deployed:", address(factory));
        vm.stopBroadcast();
    }

    function logParams() internal view {
        console2.log("vault:", params.vault);
        console2.log("owner:", params.owner);
    }
}
