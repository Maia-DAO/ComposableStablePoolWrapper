// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {ERC4626, IERC4626} from "@ERC4626/ERC4626.sol";

import {IComposableStablePool} from "./interfaces/IComposableStablePool.sol";

/// @title Ulysses Pool - Single Sided Stableswap LP
/// @author Maia DAO (https://github.com/Maia-DAO)
contract ComposableStablePoolWrapper is ERC4626 {
    using FixedPointMathLib for uint256;

    /// @notice ID of this ComposableStablePoolWrapper
    uint256 public immutable id;

    /**
     * @param _id the wrapper ID
     * @param _asset the underlying asset
     * @param _name the name of the LP
     * @param _symbol the symbol of the LP
     */
    constructor(uint256 _id, ERC20 _asset, string memory _name, string memory _symbol)
        ERC4626(_asset, _name, _symbol)
    {
        require(_id != 0);
        id = _id;
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public view override returns (uint256) {
        // Multiply by rate to get shares, rounding down
        return assets.mulWad(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        // Divide by rate to get assets, rounding down
        return shares.divWad(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) public view override returns (uint256) {
        // Divide by rate to get assets, rounding up
        return shares.divWadUp(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        // Multiply by rate to get shares, rounding up
        return assets.mulWadUp(IComposableStablePool(address(asset)).getRate());
    }

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }
}
