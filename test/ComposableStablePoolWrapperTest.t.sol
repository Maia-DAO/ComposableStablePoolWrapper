// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {IComposableStablePool, ComposableStablePoolWrapper, ERC20} from "src/ComposableStablePoolWrapper.sol";

import {ExitKind, IVault} from "./interfaces/IVault.sol";


contract ComposableStablePoolWrapperTest_3Crypto is Test {
    // Balancer: Vault
    address vaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(vaultAddress);

    // Balancer auraBAL Stable Pool (B-auraBAL-STABLE)
    bytes32 poolId = 0x79c58f70905f734641735bc61e45c19dd9ad60bc0000000000000000000004e7;
    address bptAddress = 0x79c58f70905F734641735BC61e45c19dD9Ad60bC;
    ERC20 bptToken = ERC20(bptAddress);
    IComposableStablePool bpt = IComposableStablePool(bptAddress);

    // DAI Token
    address token0Address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    MockERC20 token0 = MockERC20(token0Address);

    // USDC Token
    address token1Address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    MockERC20 token1 = MockERC20(token1Address);

    // USDT Token
    address token2Address = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    MockERC20 token2 = MockERC20(token1Address);

    // gauge address, has a lot of BPT
    address whale = 0xaDAcbA4Cae9471C26D613F7A94014549a647783C;

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    ComposableStablePoolWrapper stablePoolWrapper;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        stablePoolWrapper = new ComposableStablePoolWrapper(1, bptToken, "Mock Token Vault", "vwTKN");
    }

    function test_fork_exitPool() public {
        vm.startPrank(whale);
        uint256 balance = bptToken.balanceOf(whale) / 10;
        uint256 preview = stablePoolWrapper.convertToShares(balance);

        bptToken.approve(vaultAddress, balance);

        address[] memory assets = new address[](4);
        assets[0] = token0Address;
        assets[1] = bptAddress;
        assets[2] = token1Address;
        assets[3] = token2Address;

        uint256[] memory minAmountsOut = new uint256[](4);

        vault.exitPool(
            poolId,
            whale,
            address(this),
            IVault.ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode([ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, balance, 0]),
                toInternalBalance: false
            })
        );

        uint256 token0Balance = token0.balanceOf(address(this));
        uint256 token1Balance = token1.balanceOf(address(this));
        uint256 token2Balance = token2.balanceOf(address(this));
        uint256 tokenBalance = token0Balance + token1Balance + token2Balance;

        assertApproxEqAbs(tokenBalance, preview, balance / 1e4);
    }
}

contract ComposableStablePoolWrapperTest_AuraBal is Test {
    // Balancer: Vault
    address vaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(vaultAddress);

    // Balancer auraBAL Stable Pool (B-auraBAL-STABLE)
    bytes32 poolId = 0x3dd0843a028c86e0b760b1a76929d1c5ef93a2dd000200000000000000000249;
    address bptAddress = 0x3dd0843A028C86e0b760b1A76929d1C5Ef93a2dd;
    ERC20 bptToken = ERC20(bptAddress);
    IComposableStablePool bpt = IComposableStablePool(bptAddress);

    // Balancer: B-80BAL-20WETH Token
    address token0Address = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
    MockERC20 token0 = MockERC20(token0Address);
    // Aura: auraBAL Token
    address token1Address = 0x616e8BfA43F920657B3497DBf40D6b1A02D4608d;
    MockERC20 token1 = MockERC20(token1Address);
    // auraBal minter
    address token1Minter = 0xeAd792B55340Aa20181A80d6a16db6A0ECd1b827;

    // gauge address, has a lot of BPT
    address whale = 0x0312AA8D0BA4a1969Fddb382235870bF55f7f242;

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    ComposableStablePoolWrapper stablePoolWrapper;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        stablePoolWrapper = new ComposableStablePoolWrapper(1, bptToken, "Mock Token Vault", "vwTKN");
    }

    function test_fork_exitPool() public {
        vm.startPrank(whale);
        uint256 balance = bptToken.balanceOf(whale);
        uint256 preview = stablePoolWrapper.convertToShares(balance);

        bptToken.approve(vaultAddress, balance);

        address[] memory assets = new address[](2);
        assets[0] = token0Address;
        assets[1] = token1Address;

        uint256[] memory minAmountsOut = new uint256[](2);

        vault.exitPool(
            poolId,
            whale,
            address(this),
            IVault.ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                userData: abi.encode([ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, balance]),
                toInternalBalance: false
            })
        );

        uint256 token0Balance = token0.balanceOf(address(this));
        uint256 token1Balance = token1.balanceOf(address(this));
        uint256 tokenBalance = token0Balance + token1Balance;

        assertApproxEqAbs(tokenBalance, preview, balance / 1e3);
    }
}
