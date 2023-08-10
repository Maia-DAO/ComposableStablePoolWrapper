// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {ComposableStablePoolWrapper} from "src/ComposableStablePoolWrapper.sol";

import {AuraBalInfo} from "./pools/AuraBalInfo.sol";
import {ThreeCryptoInfo} from "./pools/ThreeCryptoInfo.sol";

import {IPoolInfo} from "./interfaces/IPoolInfo.sol";
import "./interfaces/IVault.sol";

import {DecimalConversion} from "./lib/DecimalConversion.sol";

contract MainnetPoolsWrapperTest is Test {
    // Balancer: Vault
    address vaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(vaultAddress);

    address balancerQueriesAddress = 0xE39B5e3B6D74016b2F6A9673D7d7493B6DF549d5;
    IBalancerQueries balancerQueries = IBalancerQueries(balancerQueriesAddress);

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    ComposableStablePoolWrapper stablePoolWrapper;

    AuraBalInfo auraBalInfo;
    ThreeCryptoInfo threeCryptoInfo;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        auraBalInfo = new AuraBalInfo();
        threeCryptoInfo = new ThreeCryptoInfo();
    }

    function _setUpWrapper(IPoolInfo info) private {
        stablePoolWrapper = new ComposableStablePoolWrapper(info.bptToken(), "Mock Token Vault", "vwTKN");
    }

    function _queryExit(IPoolInfo info, bytes memory data) private returns (uint256 tokenBalances) {
        (uint256 balance, address[] memory assets, uint256[] memory minAmountsOut) =
            abi.decode(data, (uint256, address[], uint256[]));

        (, uint256[] memory amountsOut) = balancerQueries.queryExit(
            info.poolId(),
            info.whale(),
            address(this),
            ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode([ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, balance]),
                toInternalBalance: false
            })
        );

        MockERC20[] memory tokens = info.getTokens();

        for (uint256 i = 0; i < amountsOut.length; i++) {
            tokenBalances += DecimalConversion.convertTo18(amountsOut[i], tokens[i].decimals());
        }
    }

    function _exitPool(IPoolInfo info, bytes memory data) private returns (uint256 tokenBalances) {
        (uint256 balance, address[] memory assets, uint256[] memory minAmountsOut) =
            abi.decode(data, (uint256, address[], uint256[]));

        vault.exitPool(
            info.poolId(),
            info.whale(),
            address(this),
            ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode([ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, balance]),
                toInternalBalance: false
            })
        );

        MockERC20[] memory tokens = info.getTokens();

        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBalances += DecimalConversion.convertTo18(tokens[i].balanceOf(address(this)), tokens[i].decimals());
        }
    }

    function _testAction(IPoolInfo info, function(IPoolInfo, bytes memory) returns (uint256) action) private {
        vm.startPrank(info.whale());
        uint256 balance = info.bptToken().balanceOf(info.whale());
        uint256 preview = stablePoolWrapper.convertToShares(balance);

        (address[] memory assets,,) = vault.getPoolTokens(info.poolId());
        uint256[] memory minAmountsOut = new uint256[](assets.length);

        uint256 tokenBalance = action(info, abi.encode(balance, assets, minAmountsOut));

        assertApproxEqAbs(tokenBalance, preview, preview / 1e3);
    }

    /*//////////////////////////////////////////////////////////////
                             AuraBal Pool
    //////////////////////////////////////////////////////////////*/

    function test_fork_auraBal_exitPool() public {
        _setUpWrapper(auraBalInfo);
        _testAction(auraBalInfo, _exitPool);
    }

    function test_fork_auraBal_queryExit() public {
        _setUpWrapper(auraBalInfo);
        _testAction(auraBalInfo, _queryExit);
    }

    /*//////////////////////////////////////////////////////////////
                             3Crypto Pool
    //////////////////////////////////////////////////////////////*/

    function test_fork_threeCrypto_exitPool() public {
        _setUpWrapper(threeCryptoInfo);
        _testAction(threeCryptoInfo, _exitPool);
    }

    function test_fork_threeCrypto_queryExit() public {
        _setUpWrapper(threeCryptoInfo);
        _testAction(threeCryptoInfo, _queryExit);
    }
}
