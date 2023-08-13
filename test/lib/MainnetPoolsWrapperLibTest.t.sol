// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {IPoolInfo} from "../interfaces/IPoolInfo.sol";
import "../interfaces/IVault.sol";

import {DecimalConversion} from "./DecimalConversion.sol";

abstract contract MainnetPoolsWrapperLibTest is Test {
    /*///////////////////////////////////////////////////////////////
                            MAINNET STATE
    ///////////////////////////////////////////////////////////////*/

    // Balancer: Vault
    address vaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(vaultAddress);

    address balancerQueriesAddress = 0xE39B5e3B6D74016b2F6A9673D7d7493B6DF549d5;
    IBalancerQueries balancerQueries = IBalancerQueries(balancerQueriesAddress);

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    IPoolInfo poolInfo;

    /*///////////////////////////////////////////////////////////////
                                 SET UP
    ///////////////////////////////////////////////////////////////*/

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        poolInfo = _setUpWrapper();
    }

    function _setUpWrapper() internal virtual returns (IPoolInfo poolInfo);

    /*///////////////////////////////////////////////////////////////
                              PREP ASSERTS
    ///////////////////////////////////////////////////////////////*/

    function _prepAssertExit(IPoolInfo info) internal returns (bytes memory) {
        vm.startPrank(info.whale());
        uint256 balance = info.bptToken().balanceOf(info.whale());
        uint256 preview = info.stablePoolWrapper().convertToShares(balance);

        return abi.encode(preview);
    }

    function _prepAssertInit(IPoolInfo info) internal returns (bytes memory) {
        MockERC20[] memory tokens = info.getTokens();

        uint256 amount = 1_000_000 ether;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i].mint(address(this), amount);
            tokens[i].approve(address(vault), amount);
        }

        uint256 preview = amount * tokens.length;

        return abi.encode(preview);
    }

    /*///////////////////////////////////////////////////////////////
                                ASSERTS
    ///////////////////////////////////////////////////////////////*/

    function _assertTwoBalances(IPoolInfo, bytes memory prepAssertData, bytes memory actionData) internal {
        uint256 preview = abi.decode(prepAssertData, (uint256));
        uint256 tokenBalance = abi.decode(actionData, (uint256));

        console2.log("preview", preview);
        console2.log("tokenBalance", tokenBalance);

        assertApproxEqAbs(tokenBalance, preview, preview / 1e3);
    }

    /*///////////////////////////////////////////////////////////////
                              PREP ACTIONS
    ///////////////////////////////////////////////////////////////*/

    function _prepExit(IPoolInfo info, bytes4 selector) internal view returns (bytes memory) {
        address whale = info.whale();
        bytes32 poolId = info.poolId();

        uint256 balance = info.bptToken().balanceOf(whale);
        (address[] memory assets,,) = vault.getPoolTokens(poolId);
        uint256[] memory minAmountsOut = new uint256[](assets.length);

        return abi.encodeWithSelector(
            selector,
            poolId,
            whale,
            address(this),
            ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode([ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, balance]),
                toInternalBalance: false
            })
        );
    }

    function _prepInit(IPoolInfo info, bytes4 selector) internal view returns (bytes memory) {
        bytes32 poolId = info.poolId();

        (address[] memory assets,,) = vault.getPoolTokens(poolId);
        uint256[] memory maxAmountsIn = new uint256[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            maxAmountsIn[i] = MockERC20(assets[i]).balanceOf(address(this));
        }

        return abi.encodeWithSelector(
            selector,
            poolId,
            address(this),
            address(this),
            JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                userData: abi.encode(JoinPoolUserData({kind: JoinKind.INIT, amountsIn: maxAmountsIn})),
                fromInternalBalance: false
            })
        );
    }

    /*///////////////////////////////////////////////////////////////
                                ACTIONS
    ///////////////////////////////////////////////////////////////*/

    function _executeAction(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = target.call(data);
        if (!success) revert(string(returnData));

        return returnData;
    }

    function _queryExit(IPoolInfo info) internal returns (bytes memory) {
        bytes memory returnData =
            _executeAction(balancerQueriesAddress, _prepExit(info, IBalancerQueries.queryExit.selector));

        (, uint256[] memory amountsOut) = abi.decode(returnData, (uint256, uint256[]));

        MockERC20[] memory tokens = info.getTokens();

        uint256 tokenBalances;

        for (uint256 i = 0; i < amountsOut.length; i++) {
            tokenBalances += DecimalConversion.convertTo18(amountsOut[i], tokens[i].decimals());
        }

        return abi.encode(tokenBalances);
    }

    function _exitPool(IPoolInfo info) internal returns (bytes memory) {
        _executeAction(vaultAddress, _prepExit(info, IVault.exitPool.selector));

        MockERC20[] memory tokens = info.getTokens();

        uint256 tokenBalances;

        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBalances += DecimalConversion.convertTo18(tokens[i].balanceOf(address(this)), tokens[i].decimals());
        }

        return abi.encode(tokenBalances);
    }

    function _queryInit(IPoolInfo info) internal returns (bytes memory) {
        _executeAction(vaultAddress, _prepInit(info, IBalancerQueries.queryJoin.selector));

        return abi.encode(info.bptToken().balanceOf(address(this)));
    }

    function _initPool(IPoolInfo info) internal returns (bytes memory) {
        _executeAction(vaultAddress, _prepInit(info, IVault.joinPool.selector));

        return abi.encode(info.bptToken().balanceOf(address(this)));
    }

    function _testSingleAction(
        IPoolInfo info,
        function(IPoolInfo) returns (bytes memory) prepAssertAction,
        function(IPoolInfo) returns (bytes memory) action,
        function(IPoolInfo, bytes memory, bytes memory) assertAction
    ) internal {
        bytes memory prepAssertData = prepAssertAction(info);

        bytes memory actionData = action(info);

        assertAction(info, prepAssertData, actionData);
    }

    /*//////////////////////////////////////////////////////////////
                            ACTION BUNDLES
    //////////////////////////////////////////////////////////////*/

    function _testExit_single(IPoolInfo info, function(IPoolInfo) returns (bytes memory) action) internal {
        _testSingleAction(info, _prepAssertExit, action, _assertTwoBalances);
    }

    function _testJoin_single(IPoolInfo info, function(IPoolInfo) returns (bytes memory) action) internal {
        _testSingleAction(info, _prepAssertInit, action, _assertTwoBalances);
    }

    /*//////////////////////////////////////////////////////////////
                             TEST POOL
    //////////////////////////////////////////////////////////////*/

    function test_fork_exitPool() public virtual {
        _testExit_single(poolInfo, _exitPool);
    }

    function test_fork_queryExit() public virtual {
        _testExit_single(poolInfo, _queryExit);
    }

    function test_fork_initPool() public virtual {
        _testJoin_single(poolInfo, _initPool);
    }

    function test_fork_queryInit() public virtual {
        _testJoin_single(poolInfo, _queryInit);
    }

    function test_fork_convertToShares() public virtual {
        assertEq(poolInfo.bpt().getRate(), poolInfo.stablePoolWrapper().convertToShares(1e18));
    }

    function test_fork_convertToAssets() public virtual {
        assertEq(1e18 * 1e18 / poolInfo.bpt().getRate(), poolInfo.stablePoolWrapper().convertToAssets(1e18));
    }

    function test_fork_previewMint() public virtual {
        uint256 expected = 1e18 * 1e18 / poolInfo.bpt().getRate();
        assertEq(
            poolInfo.bpt().getRate() % 1e18 == 0 ? expected : expected + 1,
            poolInfo.stablePoolWrapper().previewMint(1e18)
        );
    }

    function test_fork_previewWithdraw() public virtual {
        assertEq(poolInfo.bpt().getRate(), poolInfo.stablePoolWrapper().previewWithdraw(1e18));
    }
}
