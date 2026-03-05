// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {FallbackHandler} from "../src/FallbackHandler.sol";
import {GnosisSafeL2} from "safe-smart-account/contracts/GnosisSafeL2.sol";
import {SafeProxyFactory} from "../src/SafeProxyFactory.sol";
import {ConditionalTokens} from "../src/ConditionalTokens.sol";
import {MultiSend} from "../src/MultiSend.sol";

contract DeployPolymarketContracts is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        FallbackHandler fallbackHandler = new FallbackHandler();
        console2.log("FallbackHandler deployed at", address(fallbackHandler));

        GnosisSafeL2 masterCopy = new GnosisSafeL2();
        console2.log("GnosisSafeL2 (masterCopy) deployed at", address(masterCopy));

        SafeProxyFactory factory = new SafeProxyFactory(address(masterCopy), address(fallbackHandler));
        console2.log("SafeProxyFactory deployed at", address(factory));

        ConditionalTokens conditionalTokens = new ConditionalTokens();
        console2.log("ConditionalTokens deployed at", address(conditionalTokens));

        MultiSend multiSend = new MultiSend();
        console2.log("MultiSend deployed at", address(multiSend));

        vm.stopBroadcast();
    }
}

