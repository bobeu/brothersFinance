// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";

contract Periphery is Context {

    enum Status { Zeroed, WaitListed, Approved, Claimed }

    Status status;
    
    mapping(address => bool) public exist;
        
    mapping(address => bool) public isAPeerBrother;
    
    mapping(address => uint) public peerLedger;
    
    mapping(address => bool) public isAdmin;


    modifier onlyRole {
        require(isAdmin[_msgSender()], 'Not Authorized');
        _;
    }
    
    modifier isNotExisting(address k) {
        require(!exist[k], 'PeerBrotheers: Multiple registration not allowed');
        _;
    }
    
    modifier isExist {
        require(exist[_msgSender()], 'Not recognized');
        _;
    }
}