// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "solady/auth/Ownable.sol";

import {ERC20} from "@ERC4626/ERC4626.sol";

import {IVault} from "../interfaces/IVault.sol";

import {ComposableStablePoolWrapper} from "../ComposableStablePoolWrapper.sol";

/// @title Composable Stable Pool Wrapper Factory
/// @author Maia DAO (https://github.com/Maia-DAO)
contract ComposableStablePoolWrapperFactory is Ownable {
    /*///////////////////////////////////////////////////////////////
                             FACTORY STATE
    ///////////////////////////////////////////////////////////////*/

    /// @notice The address of the vault.
    IVault public immutable vault;

    /// @notice Array of all ComposableStablePoolWrapper contracts created by this factory.
    ComposableStablePoolWrapper[] public composableStablePoolWrappers;

    /// @notice Mapping of ComposableStablePoolWrapper address to their index in `composableStablePoolWrappers`.
    mapping(ComposableStablePoolWrapper composableStablePoolWrapper => uint256 composableStablePoolWrapperId) public
        composableStablePoolWrappersIds;

    /*///////////////////////////////////////////////////////////////
                                GETTERS
    ///////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the array of ComposableStablePoolWrapper contracts created by this factory.
     * @return Array of ComposableStablePoolWrapper contracts.
     */
    function getComposableStablePoolWrappers() external view returns (ComposableStablePoolWrapper[] memory) {
        return composableStablePoolWrappers;
    }

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    ///////////////////////////////////////////////////////////////*/

    /**
     * @notice Construct a new ComposableStablePoolWrapperFactory contract.
     * @param _vault The address of the Balancer's vault.
     * @param _owner The address of the owner.
     */
    constructor(IVault _vault, address _owner) {
        _initializeOwner(_owner);

        vault = _vault;
        composableStablePoolWrappers.push(ComposableStablePoolWrapper(address(0)));
    }

    /// @notice Function being overridden to prevent mistakenly renouncing ownership.
    function renounceOwnership() public payable override {
        revert RenounceOwnershipNotAllowed();
    }

    /*///////////////////////////////////////////////////////////////
                              FEES LOGIC
    ///////////////////////////////////////////////////////////////*/

    /**
     * @notice Collects all fees accumulated in the wrapper and transfers them to the receiver.
     * @param _composableStablePoolWrapper The address of the ComposableStablePoolWrapper contract.
     * @param _receiver The address of the receiver.
     */
    function collectFees(ComposableStablePoolWrapper _composableStablePoolWrapper, address _receiver)
        external
        onlyOwner
    {
        if (_receiver == address(0)) revert InvalidReceiver();
        if (_receiver == address(this)) revert InvalidReceiver();

        _composableStablePoolWrapper.collectFees(_receiver);
    }

    /*///////////////////////////////////////////////////////////////
                              CREATE LOGIC
    ///////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new ComposableStablePoolWrapper contract.
     * @dev This creation can work for any balancer pool, but should only be used for stable pools. We do not check for
     *      this to allow for future pools to be wrapped.
     * @param _poolId The pool ID of the pool to wrap.
     * NOTE: Do NOT use Stable Pools with ERC777 tokens due to needing to rely on the Balancer's `getRate()` function.
     */
    function createComposableStablePoolWrapper(bytes32 _poolId) external {
        // This will revert if the poolId is not valid.
        (address poolAddress,) = vault.getPool(_poolId);

        ERC20 asset = ERC20(poolAddress);

        ComposableStablePoolWrapper composableStablePoolWrapper = new ComposableStablePoolWrapper{
            salt: bytes32(bytes20(address(asset)))
        }(asset, string.concat("Wrapped ", asset.name()), string.concat("W", asset.symbol()));

        composableStablePoolWrappersIds[composableStablePoolWrapper] = composableStablePoolWrappers.length;
        composableStablePoolWrappers.push(composableStablePoolWrapper);

        emit NewComposableStablePoolWrapper(address(composableStablePoolWrapper), _poolId);
    }

    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new ComposableStablePoolWrapper contract is created.
    event NewComposableStablePoolWrapper(address indexed composableStablePoolWrapper, bytes32 indexed poolId);

    /*///////////////////////////////////////////////////////////////
                                 ERRORS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Error when trying to collect fees to an invalid receiver.
    error InvalidReceiver();

    /// @notice Error emitted when the owner tries to renounce ownership.
    error RenounceOwnershipNotAllowed();
}
