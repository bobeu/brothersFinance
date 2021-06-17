
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import './BroToken.sol';

contract Airdrop {

    event Airdropped(uint _addresses);

    SafeBROsToken private token;

    constructor (SafeBROsToken _token) {
        token = _token;
    }
}