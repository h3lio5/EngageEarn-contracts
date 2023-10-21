// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {RemotePotData} from "../src/RemotePotData.sol";

contract GoerliScript is Script {
    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        address pot = 0x50672F0a14B40051B65958818a7AcA3D54Bd81Af;
        RemotePotData remote = new RemotePotData(pot);

        vm.stopBroadcast();
    }
}
