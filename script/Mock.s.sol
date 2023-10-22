// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script, console2} from "forge-std/Script.sol";
// import "../src/EngageEarn.sol";
// import "../src/SavingsDai.sol";
// import "../src/DAI.sol";
// import "../src/MockPot.sol";
// import "../src/MockDaiJoin.sol";

// contract MockScript is Script {
//     function setUp() public {}

//     function run() public {
//         uint privateKey = vm.envUint("ANVIL_PRIVATE_KEY");
//         vm.startBroadcast(privateKey);

//         MockPot pot = new MockPot();

//         Dai dai = new Dai();

//         MockDaiJoin daiJoin = new MockDaiJoin(address(dai));

//         SavingsDai sDai = new SavingsDai(address(daiJoin), address(pot));
//         EngageEarn earn = new EngageEarn(address(dai), address(sDai));

//         // mint
//         address p = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
//         address a = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
//         address b = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
//         // require(p == address(this), "ooooohooooo");
//         dai.printMoney(p, 100000000000000000000000);
//         earn.registerOrg();
//         dai.approve(address(earn), 10000000000000);
//         earn.depositDAIFunds(100000);

//         // uint redeemAmount = sDai.maxRedeem(address(earn)) - 10;
//         uint shares = earn.convertAssetsToShares(10000);
//         earn.createCampaignPool(shares);

//         uint cID = earn.campaignId() - 1;
//         require(
//             earn.Id2Org(earn.campaignOwner(cID)) == p,
//             "campaign not created"
//         );

//         // insert participants
//         earn.insertParticipants(cID, a, b);

//         earn.rewardCampaignParticipants(cID);

//         // check if the balances of the participants increased
//         uint totalPrize = earn.campaignPrizePool(cID);
//         require(
//             dai.balanceOf(a) + dai.balanceOf(b) == totalPrize,
//             "rewards not distributed properly"
//         );

//         vm.stopBroadcast();
//     }
// }

// // DAI: 0x7516223e25eF9B7a47680767899f9587cC9B92B4
// // sDAI = 0xb6Cc799182888a303e3945e24eF9BEe53CDde6B3
