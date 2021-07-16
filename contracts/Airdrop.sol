// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/Ownable.sol";
import "lib/SafeMath.sol";

import './SafeBEP20.sol';
import "lib/Slice.sol";

contract Airdrop is Ownable, Slice{

    using SafeMath for uint256;

    SafeBEP20 token;

    uint8 public airdropCount;

    uint256 public totalClaimants;

    uint public totalSignUpCount;

    event NewHunter(address indexed _NewHunter);

    struct AirdropInfo {
        uint256 poolBalance;
        bool active;
        uint activeTime;
        uint256 totalClaimed;
        uint256 unitClaim;
        mapping(address => Infos) users;
        mapping(address => Claim) _claimant;
    }

    struct Infos {
        string twiiter;
        string telegramUsername;
        string reddit;
        string othersLinks;
        uint256 id;
        Status _status;
    }

    struct Claim {
        Status _status;
        uint256 id;
    }

    mapping(uint8 => AirdropInfo) public airdrops;
    

    constructor (SafeBEP20 _token) {
        token = _token;
    }

    function createDrop(uint8 activeTimeInDays, uint256 _totalPool, uint _unitClaim) public PRIVATE returns(bool) {
        require(airdropCount < 2**8, 'BRO: Cap exceeded');
        require(activeTimeInDays >= 0, 'Unsigned integer expected');
        require(_totalPool < token.balanceOf(address(this)), 'pool out of range');
        airdropCount ++;
        AirdropInfo storage _new = airdrops[airdropCount];
        _new.active = false;
        _new.activeTime = block.timestamp.add(1 days * activeTimeInDays);
        _new.poolBalance = _totalPool;
        _new.unitClaim = _unitClaim;

        return true;
    }

    function signUpForAidrop(
        string memory twitterLink, 
        string memory tgUsername, 
        string memory reddit,
        string memory additionalLink
        ) public returns(bool) {
            require(airdrops[airdropCount].users[_msgSender()]._status == Status.Zeroed, 'Friend: You already exist');
            totalSignUpCount += 1;
            airdrops[airdropCount].users[_msgSender()] = Infos(twitterLink, tgUsername, reddit, additionalLink, totalSignUpCount, Status.WaitListed);

            emit NewHunter(_msgSender());
            return true;
    }

    // @dev: or approved admin to approve a users.
    function approveForAirdrop(address target, uint8 airdropId) public onlyRole returns(bool) {
        require(airdrops[airdropId].users[_msgSender()]._status == Status.WaitListed, 'User not allowed');
        require(target != _msgSender(), 'Admin: Failed attempt');
        airdrops[airdropId].users[_msgSender()]._status = Status.Approved;

        return true;
    }

    function approveMultiplehunters(address[] memory targets, uint8 airdropId)  public onlyRole returns(bool) {
        for(uint i=0; i<targets.length; i++){
            require(airdrops[airdropId].users[targets[i]]._status == Status.Zeroed, 'User not allowed');
            require(targets[i] != _msgSender(), 'Admin: Failed attempt');
            airdrops[airdropId].users[_msgSender()]._status = Status.Approved;
            }
        return true;
    }

    function checkhunterStatus(uint8 airdropId) public view returns(Status) {
        return airdrops[airdropId].users[_msgSender()]._status;
    }

    function manualactivateOrDeactairdrop(uint8 _airdropId, bool _state)public onlyRole returns(bool){
        
        if(!_state) {
            require(airdrops[_airdropId].active, 'Already deactivated');
            airdrops[_airdropId].active = false;
        } else {
            require(!airdrops[_airdropId].active, 'Already active');
            airdrops[_airdropId].active = true;
        }
        return true;
    }

    function getHunterLinks(address user, uint8 _airdropId) public view onlyRole returns(string memory, string memory, string memory, string memory, uint, Status _status) {
        uint8 ai = _airdropId;
        address u = user;
        AirdropInfo storage a = airdrops[ai];
        return (a.users[u].twiiter, a.users[u].telegramUsername, a.users[u].reddit, a.users[u].othersLinks, a.users[u].id, a.users[u]._status);
    }
    
    function claim(uint8 airdropId) public returns( bool){
        require(airdropId <= airdropCount, 'Such does not exist');
        require(airdrops[airdropId].users[_msgSender()]._status == Status.Approved, 'Friend: Not qualified');
        uint256 activetime = airdrops[airdropId].activeTime;
        if(block.timestamp >= activetime) {
            airdrops[airdropId].active = true;
        }
        require(airdrops[airdropId].active, 'Airdrop is inactive');
        uint claimable = airdrops[airdropId].unitClaim;
        uint airdropBalance = airdrops[airdropId].poolBalance;
        
        if(airdropBalance.sub(claimable) > 0){
            totalClaimants += 1;
            token.transfer_(address(this), _msgSender(), claimable);
            airdrops[airdropId].users[_msgSender()]._status = Status.Claimed;
            airdrops[airdropId].totalClaimed += claimable;
            airdrops[airdropId].poolBalance -= claimable;

            Claim storage _claim = airdrops[airdropId]._claimant[_msgSender()];
            _claim._status =  Status.Claimed;
            _claim.id = totalClaimants;
        } else {
            revert("Airdrop closed");
        }
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
    
    }
