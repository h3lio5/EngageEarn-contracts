// This is called on the source chain before calling the gateway to execute a remote contract.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IAxelarGasService {
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;
}
