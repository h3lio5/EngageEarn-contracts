// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract MockDaiJoin {
    address public dai;

    constructor(address _dai) {
        dai = _dai;
    }
}
