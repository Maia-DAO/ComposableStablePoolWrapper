// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IComposableStablePoolFactory {
    /**
     * @dev Deploys a new `ComposableStablePool`.
     */
    function create(
        string memory name,
        string memory symbol,
        address[] memory tokens,
        uint256 amplificationParameter,
        address[] memory rateProviders,
        uint256[] memory tokenRateCacheDurations,
        bool[] memory exemptFromYieldProtocolFeeFlags,
        uint256 swapFeePercentage,
        address owner,
        bytes32 salt
    ) external returns (address);
}
