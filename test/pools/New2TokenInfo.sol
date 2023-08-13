// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IComposableStablePoolFactory} from "../interfaces/IComposableStablePoolFactory.sol";

import "../interfaces/IPoolInfo.sol";

contract New2TokenInfo is IPoolInfo {
    MockERC20[] public override tokens;

    ComposableStablePoolWrapper public immutable override stablePoolWrapper;

    // Balancer auraBAL Stable Pool (B-auraBAL-STABLE)
    bytes32 public immutable override poolId;
    address public immutable override bptAddress;
    ERC20 public immutable override bptToken;
    IComposableStablePool public immutable override bpt;

    // Balancer: B-80BAL-20WETH Token
    address public immutable override token0Address;
    MockERC20 public immutable override token0;
    // Aura: auraBAL Token
    address public immutable override token1Address;
    MockERC20 public immutable override token1;

    // Tokens set to 0 address if not used
    address public constant override token2Address = address(0);
    MockERC20 public constant override token2 = MockERC20(token2Address);
    address public constant override token3Address = address(0);
    MockERC20 public constant override token3 = MockERC20(token3Address);
    address public constant override token4Address = address(0);
    MockERC20 public constant override token4 = MockERC20(token4Address);

    // gauge address, has a lot of BPT
    address public immutable override whale;

    constructor(IComposableStablePoolFactory factory) {
        whale = msg.sender;

        MockERC20[] memory _tokens = new MockERC20[](2);
        _tokens[0] = new MockERC20("Mock Token 0", "TKN0", 18);
        _tokens[1] = new MockERC20("Mock Token 1", "TKN1", 18);

        tokens = sort_array_addresses(_tokens);

        address[] memory tokensToInit = new address[](2);
        tokensToInit[0] = address(tokens[0]);
        tokensToInit[1] = address(tokens[1]);

        token0 = tokens[0];
        token0Address = tokensToInit[0];
        token1 = tokens[1];
        token1Address = tokensToInit[1];

        address[] memory rateProviders = new address[](2);
        uint256[] memory tokenRateCacheDurations = new uint256[](2);
        bool[] memory exemptFromYieldProtocolFeeFlags = new bool[](2);

        bptAddress = factory.create(
            "Mock Token Vault",
            "vwTKN",
            tokensToInit,
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

    function getTokens() public view override returns (MockERC20[] memory) {
        return tokens;
    }

    function sort_array_addresses(MockERC20[] memory _tokens) internal pure returns (MockERC20[] memory) {
        if (_tokens.length == 0) {
            return _tokens;
        }

        for (uint256 i = 0; i < _tokens.length - 1; i++) {
            for (uint256 j = 0; j < _tokens.length - i - 1; j++) {
                if (_tokens[j] > _tokens[j + 1]) {
                    MockERC20 temp = _tokens[j];
                    _tokens[j] = _tokens[j + 1];
                    _tokens[j + 1] = temp;
                }
            }
        }

        return _tokens;
    }
}
