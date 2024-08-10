// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ComposableStablePoolWrapper} from "src/ComposableStablePoolWrapper.sol";

library ComputeAddress {
    function getInitCodeHash() internal pure returns (bytes32 initCodeHash) {
        initCodeHash = keccak256(abi.encodePacked(type(ComposableStablePoolWrapper).creationCode));
    }

    function computeAddress(address factory, address asset) internal pure returns (address wrapperAddress) {
        wrapperAddress = address(
            uint160(
                uint256(keccak256(abi.encodePacked(bytes1(0xff), factory, bytes32(bytes20(asset)), getInitCodeHash())))
            )
        );
    }
}
