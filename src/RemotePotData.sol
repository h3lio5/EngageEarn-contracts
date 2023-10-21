// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IAxelarGateway.sol";
import "./IAxelarGasService.sol";

import "openzeppelin-contracts/contracts/utils/Strings.sol";

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
    address axelarGateway = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address axelarGasService = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
    address savingsDaiAddress;
    address owner;

    constructor(address _potAddress) {
        pot = PotLike(_potAddress);
        owner = msg.sender;
    }

    function setSavingsDaiAddress(address _sDAI) external {
        require(msg.sender == owner, "not owner");
        savingsDaiAddress = _sDAI;
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external payable {
        bytes32 payloadHash = keccak256(payload);

        if (
            !IAxelarGateway(axelarGateway).validateContractCall(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash
            )
        ) revert("not approved by gateway");

        (uint flag, address receiver, address owner) = abi.decode(
            payload,
            (uint, address, address)
        );

        bytes memory returnPayload = abi.encodePacked(
            flag,
            receiver,
            owner,
            pot.rho(),
            pot.drip(),
            pot.chi()
        );

        IAxelarGasService(axelarGasService).payNativeGasForContractCall{
            value: msg.value
        }(
            address(this),
            "scroll",
            Strings.toHexString(uint256(uint160(savingsDaiAddress))),
            payload,
            address(this)
        );

        IAxelarGateway(axelarGateway).callContract(
            "scroll",
            Strings.toHexString(uint256(uint160(savingsDaiAddress))),
            returnPayload
        );
    }
}
