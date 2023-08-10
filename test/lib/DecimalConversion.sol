// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

library DecimalConversion {
    function convertTo18(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return amount * (10 ** (18 - decimals));
    }
}
