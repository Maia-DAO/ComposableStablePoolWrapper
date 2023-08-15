// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./BasePoolInfo.sol";

contract ThreeCryptoInfo is BasePoolInfo {
    // Balancer auraBAL Stable Pool (B-auraBAL-STABLE)
    bytes32 public constant override poolId = 0x79c58f70905f734641735bc61e45c19dd9ad60bc0000000000000000000004e7;
    address public constant override bptAddress = 0x79c58f70905F734641735BC61e45c19dD9Ad60bC;
    ERC20 public constant override bptToken = ERC20(bptAddress);
    IComposableStablePool public constant override bpt = IComposableStablePool(bptAddress);

    // DAI Token
    address public constant override token0Address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    MockERC20 public constant override token0 = MockERC20(token0Address);
    // USDC Token
    address public constant override token1Address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    MockERC20 public constant override token1 = MockERC20(token1Address);
    // USDT Token
    address public constant override token2Address = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    MockERC20 public constant override token2 = MockERC20(token2Address);

    // Tokens set to 0 address if not used
    address public constant override token3Address = address(0);
    MockERC20 public constant override token3 = MockERC20(token3Address);
    address public constant override token4Address = address(0);
    MockERC20 public constant override token4 = MockERC20(token4Address);

    // gauge address, has a lot of BPT
    address public constant override whale = 0x5612876e6F6cA370d93873FE28c874e89E741fB9;

    constructor() {
        tokens.push(token0);
        tokens.push(token1);
        tokens.push(token2);

        stablePoolWrapper = new ComposableStablePoolWrapper(bptToken, "Mock Token Vault", "vwTKN");
    }
}
