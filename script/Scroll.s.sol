// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/EngageEarn.sol";
import "../src/SavingsDai.sol";
import "../src/DAI.sol";

contract ScrollScript is Script {
    function setUp() public {}

    address remotePot = 0xCe7f473AC7d90CE3F1835D99C076d13F8777d038;

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        Dai dai = new Dai();
        SavingsDai sDai = new SavingsDai(remotePot);
        EngageEarn earn = new EngageEarn(address(dai), address(sDai));
        vm.stopBroadcast();
    }
}

// DAI: 0x7516223e25eF9B7a47680767899f9587cC9B92B4
// sDAI = 0xb6Cc799182888a303e3945e24eF9BEe53CDde6B3
