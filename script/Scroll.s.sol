// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/EngageEarn.sol";
import "../src/SavingsDai.sol";
import "../src/DAI.sol";

contract ScrollScript is Script {
    function setUp() public {}

    address potAddress = 0x50672F0a14B40051B65958818a7AcA3D54Bd81Af;
    address daiJoinAddress = 0x6a60b7070befb2bfc964F646efDF70388320f4E0;

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        Dai dai = new Dai();
        SavingsDai sDai = new SavingsDai(daiJoinAddress, potAddress);
        EngageEarn earn = new EngageEarn(address(dai), address(sDai));
        vm.stopBroadcast();
    }
}

// DAI: 0x7516223e25eF9B7a47680767899f9587cC9B92B4
// sDAI = 0xb6Cc799182888a303e3945e24eF9BEe53CDde6B3
// forge script script/Scroll.s.sol:ScrollScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv

// Dai@0x659fE13691572e733e166BeA76084DAe82f14C19
// SavingsDai@0xdC8566a30ccb349020bc5662f17551101175Db55
// EngageEarn@0xeFc586F1065De93612F909c44F4C9e88ae54520a
