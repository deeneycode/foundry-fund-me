// SPDX-Licence-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil
// 2. Keep track of contract address across different chains
//  Sepolia ETH/USD
//  Mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregate.sol";

contract HelperConfig is Script{
    // If we are on a local anvil, we deploy mocks
    // otherwise, grab the existing address from the live network

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

     constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = createAnvilEthConfig();
        }
     }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
            return sepoliaConfig;
    }
        

    function createAnvilEthConfig() public returns (NetworkConfig memory) {
        // price feed address
        //1. Deploy the mocks
        //2. Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
        DECIMALS,
        INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;

    }
}