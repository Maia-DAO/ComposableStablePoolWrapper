// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {ComposableStablePoolWrapper, ERC20} from "src/ComposableStablePoolWrapper.sol";

import {IComposableStablePoolFactory} from "./interfaces/IComposableStablePoolFactory.sol";
import {IComposableStablePool} from "./interfaces/IComposableStablePool.sol";

import "./interfaces/IVault.sol";

contract ComposableStablePoolWrapperTest is Test {
    // Balancer: Vault
    address vaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(vaultAddress);

    address balancerQueriesAddress = 0xE39B5e3B6D74016b2F6A9673D7d7493B6DF549d5;
    IBalancerQueries balancerQueries = IBalancerQueries(balancerQueriesAddress);

    // ComposableStablePoolFactory
    address factoryAddress = 0xfADa0f4547AB2de89D1304A668C39B3E09Aa7c76;
    IComposableStablePoolFactory factory = IComposableStablePoolFactory(factoryAddress);

    bytes32 poolId;
    address bptAddress;
    ERC20 bptToken;
    IComposableStablePool bpt;

    // Mock Token 1
    address token0Address;
    MockERC20 token0;

    // Mock Token 2
    address token1Address;
    MockERC20 token1;

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    ComposableStablePoolWrapper stablePoolWrapper;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }

    function sort_array_addresses(address[] memory tokens) public pure returns (address[] memory) {
        if (tokens.length == 0) {
            return tokens;
        }

        for (uint256 i = 0; i < tokens.length - 1; i++) {
            for (uint256 j = 0; j < tokens.length - i - 1; j++) {
                if (tokens[j] > tokens[j + 1]) {
                    address temp = tokens[j];
                    tokens[j] = tokens[j + 1];
                    tokens[j + 1] = temp;
                }
            }
        }

        return tokens;
    }

    function test_create_2TokenBPT() public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(new MockERC20("Mock Token 0", "TKN0", 18));
        tokens[1] = address(new MockERC20("Mock Token 1", "TKN1", 18));

        tokens = sort_array_addresses(tokens);

        token0Address = tokens[0];
        token0 = MockERC20(token0Address);
        token1Address = tokens[1];
        token1 = MockERC20(token1Address);

        address[] memory rateProviders = new address[](2);
        uint256[] memory tokenRateCacheDurations = new uint256[](2);
        bool[] memory exemptFromYieldProtocolFeeFlags = new bool[](2);

        bptAddress = factory.create(
            "Mock Token Vault",
            "vwTKN",
            tokens,
            5_000,
            rateProviders,
            tokenRateCacheDurations,
            exemptFromYieldProtocolFeeFlags,
            1e12,
            address(this),
            keccak256(abi.encodePacked(block.timestamp))
        );
        bptToken = ERC20(bptAddress);
        bpt = IComposableStablePool(bptAddress);
        poolId = bpt.getPoolId();

        stablePoolWrapper = new ComposableStablePoolWrapper(bptToken, "Mock Token Vault", "vwTKN");
    }

    function test_fork_convertToShares() public {
        test_fork_joinPool();
        assertEq(bpt.getRate(), stablePoolWrapper.convertToShares(1e18));
    }

    function test_fork_joinPool() public {
        test_create_2TokenBPT();

        uint256 token0Balance = 1_000_000 ether;
        uint256 token1Balance = 1_000_000 ether;
        token0.mint(address(this), token0Balance);
        token1.mint(address(this), token1Balance);
        uint256 tokenBalance = token0Balance + token1Balance;

        token0.approve(address(vault), token0Balance);
        token1.approve(address(vault), token1Balance);

        uint256[] memory maxAmountsIn = new uint256[](3);
        maxAmountsIn[0] = token0Balance;
        maxAmountsIn[1] = token0Balance;
        maxAmountsIn[2] = token1Balance;

        (address[] memory assets,,) = vault.getPoolTokens(poolId);

        vault.joinPool(
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

        uint256 balance = bptToken.balanceOf(address(this));

        assertEq(tokenBalance, stablePoolWrapper.convertToShares(balance));
    }
}
