// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import {ERC20, ERC4626, IERC4626} from "@ERC4626/ERC4626.sol";

import {IComposableStablePool} from "./interfaces/IComposableStablePool.sol";

import {VaultReentrancyLib} from "./lib/VaultReentrancyLib.sol";

import {ComposableStablePoolWrapperFactory} from "./factories/ComposableStablePoolWrapperFactory.sol";

/// @title Wrapper for Balancer's Compostable Stable Pools.
/// @notice This contract keeps fees by keeping excess supply gotten from invariant increases (due to fees).
///         Keeping the ratio of LP to invariant (and asset amounts when the liquidity balance is the same) constant.
/// @author Maia DAO (https://github.com/Maia-DAO)
contract PoolWrapper is ERC4626 {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for address;
    using VaultReentrancyLib for address;

    /*///////////////////////////////////////////////////////////////
                            WRAPPER STATE
    ///////////////////////////////////////////////////////////////*/

    /// @notice The address of the Balancer's vault.
    address public immutable vault;

    /// @notice The address of the factory that created this wrapper.
    address public immutable factory;

    /**
     * @param _asset the underlying asset of this wrapper, which is the BPT/LP token of the pool.
     */
    constructor(ERC20 _asset)
        ERC4626(_asset, string.concat("Wrapped ", _asset.name()), string.concat("W", _asset.symbol()))
    {
        factory = msg.sender;
        vault = IComposableStablePool(address(asset)).getVault();
    }

    /*///////////////////////////////////////////////////////////////
                              ADMIN LOGIC
    ///////////////////////////////////////////////////////////////*/

    /**
     * @notice Collects all fees accumulated in the wrapper and transfers them to the factory owner.
     * @param _receiver The address to receive the fees.
     */
    function collectFees(address _receiver) external {
        if (factory != msg.sender) revert Unauthorized();

        // Calculate fees to collect (previewMint already ensures we are not in the vault context)
        // previewMint gets the amount of assets that would be withdrawn if we were to withdraw all shares, but it
        // rounds up for safety, so we may have a small amount of assets left over
        uint256 fees = totalAssets() - previewMint(totalSupply);

        // Transfer fees to receiver
        address(asset).safeTransfer(_receiver, fees);

        emit CollectFees(_receiver, fees);
    }

    /*//////////////////////////////////////////////////////////////
                       ERC4626 ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice The total amount of assets held by this wrapper, including fees.
     */
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public view override returns (uint256) {
        vault.ensureNotInVaultContext();

        // Multiply by rate to get shares, rounding down
        return assets.mulWad(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        vault.ensureNotInVaultContext();

        // Divide by rate to get assets, rounding down
        return shares.divWad(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) public view override returns (uint256) {
        vault.ensureNotInVaultContext();

        // Divide by rate to get assets, rounding up
        return shares.divWadUp(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        vault.ensureNotInVaultContext();

        // Multiply by rate to get shares, rounding up
        return assets.mulWadUp(IComposableStablePool(address(asset)).getRate());
    }

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    ///////////////////////////////////////////////////////////////*/

    event CollectFees(address indexed receiver, uint256 indexed fees);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Throws if called by any account other than the factory.
    error Unauthorized();
}

contract ComposableStablePoolWrapper is PoolWrapper {
    constructor() PoolWrapper(ComposableStablePoolWrapperFactory(msg.sender).asset()) {}
}
