// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface PotLike {
    function chi() external view returns (uint256);

    function rho() external view returns (uint256);

    function dsr() external view returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;
}

contract RemotePotData {
    PotLike pot;

    constructor(address _potAddress) {
        pot = PotLike(_potAddress);
    }

    function sendPotData() external returns (uint, uint, uint) {
        return (pot.rho(), pot.drip(), pot.chi());
    }
}
