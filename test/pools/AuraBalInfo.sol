// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "../interfaces/IPoolInfo.sol";

contract AuraBalInfo is IPoolInfo {
    MockERC20[] public override tokens;

    ComposableStablePoolWrapper public override stablePoolWrapper;

    // Balancer auraBAL Stable Pool (B-auraBAL-STABLE)
    bytes32 public constant override poolId = 0x3dd0843a028c86e0b760b1a76929d1c5ef93a2dd000200000000000000000249;
    address public constant override bptAddress = 0x3dd0843A028C86e0b760b1A76929d1C5Ef93a2dd;
    ERC20 public constant override bptToken = ERC20(bptAddress);
    IComposableStablePool public constant override bpt = IComposableStablePool(bptAddress);

    // Balancer: B-80BAL-20WETH Token
    address public constant override token0Address = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
    MockERC20 public constant override token0 = MockERC20(token0Address);
    // Aura: auraBAL Token
    address public constant override token1Address = 0x616e8BfA43F920657B3497DBf40D6b1A02D4608d;
    MockERC20 public constant override token1 = MockERC20(token1Address);

    // Tokens set to 0 address if not used
    address public constant override token2Address = address(0);
    MockERC20 public constant override token2 = MockERC20(token2Address);
    address public constant override token3Address = address(0);
    MockERC20 public constant override token3 = MockERC20(token3Address);
    address public constant override token4Address = address(0);
    MockERC20 public constant override token4 = MockERC20(token4Address);

    // gauge address, has a lot of BPT
    address public constant override whale = 0x0312AA8D0BA4a1969Fddb382235870bF55f7f242;

    ERC20 public asset;

    constructor() {
        tokens.push(token0);
        tokens.push(token1);

        asset = bptToken;
    }

    function create() public {
        stablePoolWrapper = new ComposableStablePoolWrapper();
    }

    function getTokens() public view override returns (MockERC20[] memory) {
        return tokens;
    }
}
