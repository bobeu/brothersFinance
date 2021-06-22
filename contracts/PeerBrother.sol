// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

import './BroToken.sol';

interface BUSD {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address user) external returns(uint256);
}

                    // =====>BRO TOKEN IMPLEMENTATION<=======================================================

contract SafeBROsToken is ERC20, Ownable {

    using SafeMath for uint256;

    event MuteAccount(address indexed _target);

    event UnMuteAccount(address indexed _target);

    mapping(address => bool) private suspension;


   
    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(uint supply) ERC20("BroToken", "BROT") public {
        _mint(_msgSender(), (supply * 10**18));
    }

    modifier isNotsuspended(address _any) {
        require(!suspension[_any], 'Restricted');
        _;
    }

    /**
     * @dev See {ERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override isNotsuspended(_msgSender()) returns(bool) {
        _transfer(_msgSender(), recipient, amount.mul(10 ** 18));

        return true;
    }

    /**
     * @dev See {ERC20-allowance}.
     */
    function allowance(address owner, address spender) public override view isNotsuspended(_msgSender()) returns (uint256) {
        return super.allowance(owner, spender);
    }

    /**
     * @dev See {ERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override isNotsuspended(_msgSender()) returns (bool) {
        super.approve(spender, amount);
        return true;
    }

    /**
     * @dev See {ERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override isNotsuspended(_msgSender()) returns (bool) {
        super.transferFrom(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public override isNotsuspended(_msgSender()) returns (bool) {
        super.increaseAllowance(spender, addedValue);

        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public override isNotsuspended(_msgSender()) returns (bool) {
        super.decreaseAllowance(spender, subtractedValue);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(address destination, uint256 amount) public onlyOwner returns (bool) {
        _mint(destination, amount);
        return true;
    }
    
    // receive () external payable {
    //     if(msg.value < 1e21 wei) revert();
    // }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 amount) external isNotsuspended(_msgSender()) returns(bool) {
        _burn(account, amount);

        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    // function _burnFrom(address account, uint256 amount) internal isNotFreezed(account) {
    //     if(_burn(account, amount)) {

    //         _approve(
    //             account,
    //             msg.sender,
    //             _allowances[account][msg.sender].sub(amount, 'ERC20: burn amount exceeds allowance')
    //         );
    //     }
    // }

    function suspendAccount(address _target) public onlyOwner returns(bool) {
        if(suspension[_target]) revert('Account suspended before now');
        suspension[_target] = true;
        emit MuteAccount(_target);
        return suspension[_target];
    }

    function unsuspendAccount(address _target) public onlyOwner returns(bool) {
        if(!suspension[_target]) revert('Account is not suspended before now.');
        suspension[_target] = false;
        emit UnMuteAccount(_target);

        return suspension[_target];
    }

    // function confiscate()


}



                            // ====>CONTRACT MAIN<====================================================


contract PeerBrothers is SafeBROsToken {

    using SafeMath for uint256;

    enum Status { Zeroed, WaitListed, Approved, Claimed }
    
    event Deposit(address indexed brother, uint amount);
    
    event Received(address indexed brother, uint amount);

    event PenaltyChanged(address bigBro, uint newRate);

    event NewHunter(address indexed _NewHunter);
    
    // uint public groupCount;
    
    // bool private familyAct;
    
    BUSD busd;
    
    // address public immutable busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    uint public peerGroupCount;

    uint8 public airdropCount;

    uint256 public totalClaimants;

    uint public totalSignUpCount;
    
    bool private groupStatus;


    Status status;

    // AirdropInfo public currentInstance = airdrops[airdropCount];

    struct PeerInfo {
        uint unit;
        uint totalPoolToDate;
        uint maxDuration;
        uint8 agreedRate;
        uint8 staged;
        uint8 groupSize;
        uint penaltyFee;
        uint permitTime;
        uint expectedPool;
        bool locked;
        uint frequency;
        mapping(address => uint8) position;
        mapping(uint8 => BrotherInfo) members;
    }
    
    struct BrotherInfo {
        address brother;
        bool isBroListed;
        uint debt;
        bool isCreditor;
        uint payDay;
        bool isPaid;
        uint credit;
    }

    struct AirdropInfo {
        uint256 poolBalance;
        bool active;
        uint activeTime;
        uint256 totalClaimed;
        uint256 unitClaim;
        mapping(address => SignUps) users;
        mapping(address => Claim) _claimant;
    }

    struct SignUps {
        bytes info;
        uint256 id;
        Status _status;
    }

    struct Claim {
        Status _status;
        uint256 id;
    }


    mapping(address => mapping(uint8 => address)) public soulBrothers;
    
    mapping(address => PeerInfo) public peerInfo;
    
    mapping(address => bool) private exist;
        
    mapping(address => bool) public isABigBrother;

    mapping(uint8 => AirdropInfo) public airdrops;


    mapping(address => bool) public isAdmin;
    
    
    modifier isABrother(address _bro, address target) {
        uint8 pos = peerInfo[_bro].position[target];
        require(pos > 0, 'No peer detected');
        require(peerInfo[_bro].members[pos].isBroListed, 'Not recognized');
        _;
    }
    
    modifier isBinded(address _adminAddr, address target) {
        uint8 pos = peerInfo[_adminAddr].position[target];
        require(pos > 0, 'No peer detected');
        require(soulBrothers[_adminAddr][pos] == target, 'No ties');
        _;
    }

    modifier onlyRole {
        require(isAdmin[_msgSender()], 'Not Authorized');
        _;
    }
    
    modifier isExist(address k) {
        require(!exist[k], 'Multiple registration');
        _;
    }

    constructor(uint _supply, BUSD _busd) public SafeBROsToken(_supply) {
        isAdmin[_msgSender()] = true;
        busd = _busd;
    }
    
    
    //    =====>MAIN<=====

    receive () external payable {
        if(msg.value < 1e17 wei) revert();
    }

    function setRole(address _newRole, bool any) public onlyOwner returns(bool) {
        if(any){
            isAdmin[_newRole] = true;
            return true;
        } else if(!any) {
            isAdmin[_newRole] = false;
        }
        return true;
        
    }
    
    
    function checkGroupActivityStatus() public view onlyRole returns(bool) {
        return groupStatus;
    } 
    
    function changePeerActivityStatus(bool state) public onlyOwner returns(string memory) {
        if(!state){
            groupStatus = false;
            return 'Activity is restricted';
        } else if(state){
            groupStatus = true;
            return 'Activity has been allowed';
        }
        
    }
    
    function _deductFst(address recipient, uint valueBUSD) internal returns(bool) {
        uint actualBalance = balanceOf(_msgSender());
        uint p = getCurrentPrice();
        uint dep = valueBUSD.mul(p);
        uint fstdepo = dep.add(valueBUSD.mul(10).div(100));
        require(actualBalance >= fstdepo, 'Insufficient balance');
        transfer(recipient, fstdepo);
        return true;
    }
    
    function _safeTransferBUSD(address sender, address recipient, uint _amount) internal view returns(bool) {
        // uint previousBalance = busd.balanceOf(sender);
        // busd.transfer(recipient, _amount);
        // require(busd.balanceOf(sender).add(_amount) == previousBalance, 'Something went wrong');
        return true;
        
    }
    // Any of the Peer brothers agreed as bigBrother initialises a finance group
    
    function setUpAPeer(
        uint _unitAmount, 
        uint8 _interestRate, //Note at fixing=================================
        uint _maxDurationInDays,
        uint _penaltyFeeInBUSD,
        uint8 peerSize
        ) public isExist(_msgSender()) returns(bool) {
            address k = _msgSender();
            PeerInfo storage _new = peerInfo[k];
            require(groupStatus, 'Not available at this time');
            require(_deductFst(address(this), _unitAmount), 'Something went wrong');
            require(_maxDurationInDays.mul(1 days) <= 7 days, 'But why? Consider rest');
            require(!peerInfo[k].locked, 'Current round not ended');
            // require(_safeTransferBUSD(_msgSender(), address(this), _unitAmount), 'Bad Brother');
            uint8 esc = peerSize;

            if(_safeTransferBUSD(k, address(this), _unitAmount)) {
                _new.unit = _unitAmount;
                _new.totalPoolToDate = _unitAmount;
                _new.agreedRate = _interestRate;
                _new.maxDuration = _maxDurationInDays.mul(1 days);
                _new.groupSize = peerSize;
                _new.frequency = 0;
                _new.penaltyFee = _penaltyFeeInBUSD;
                _new.permitTime = block.timestamp.add(1 days);
                _new.expectedPool = _unitAmount.mul(peerSize);

                for(uint i=0; i<esc; i++) {
                    _new.members[esc] = BrotherInfo({
                        brother: address(0),
                        isBroListed: false,
                        debt: 0,
                        isCreditor: false,
                        payDay: 0,
                        isPaid: false,
                        credit: 0
                        });
                    soulBrothers[k][esc] = address(0);

                    esc --;
                    }
            } else {
                revert('Failed');
                }
            isABigBrother[k] = true;
            peerGroupCount ++;
            peerInfo[k].members[peerSize].brother = k;
            peerInfo[k].members[peerSize].isBroListed = true;
            peerInfo[k].members[peerSize].isCreditor = true;
            peerInfo[k].members[peerSize].credit = _unitAmount;
            peerInfo[k].position[k] = peerSize;
            soulBrothers[k][peerSize] = k;
            peerInfo[k].groupSize = peerInfo[k].groupSize - 1;
            return true;
    }
    
    function getMemberInfo(address adminAddr, uint8 memberId) public view returns(address, bool, uint, bool, uint, bool, uint) {
        address p = adminAddr;
        uint8 m = memberId;
        return (
            peerInfo[p].members[m].brother,
            peerInfo[p].members[m].isBroListed,
            peerInfo[p].members[m].debt,
            peerInfo[p].members[m].isCreditor,
            peerInfo[p].members[m].payDay,
            peerInfo[p].members[m].isPaid,
            peerInfo[p].members[m].credit
            );
    }

    function joinYourPeer(address adminAddr) public returns(uint8) {
        address p = _msgSender();
        address a = adminAddr;
        require(!peerInfo[a].locked, 'Current round not ended');
        require(peerInfo[a].groupSize > 0, 'No vacant position for this peer');
        uint remittance = peerInfo[a].unit;
        uint8 ap = peerInfo[p].groupSize;
        require(peerInfo[a].members[ap].brother != p && peerInfo[a].members[ap].brother == address(0), 'Multiple registration: denied');
        uint totalUSDPool = peerInfo[a].totalPoolToDate;
        uint expectedPoolBal = peerInfo[a].expectedPool;
        if((totalUSDPool.add(remittance) <= expectedPoolBal)){
            require(_deductFst(address(this), remittance), 'Error');
            require(_safeTransferBUSD(p, address(this), remittance), 'Not completed');
            peerInfo[a].members[ap].brother = _msgSender();
            soulBrothers[a][ap] = p;
            peerInfo[a].members[ap].credit = remittance;
            peerInfo[a].totalPoolToDate += remittance;
            
            peerInfo[p].groupSize = peerInfo[p].groupSize - 1;
            emit Deposit(p, remittance);
            return ap;
        } else {
            revert('Pool amount is reached');
        }
    }
    
    function getCurrentPrice() internal pure returns(uint256) {
        return 2;
    }
    
    function getFinance(address adminAddr) public isABrother(adminAddr, _msgSender()) isBinded(adminAddr, _msgSender()) returns(bool) {
        uint8 rotator = peerInfo[adminAddr].groupSize += 1;
        address g = adminAddr;
        address next = soulBrothers[adminAddr][rotator];
        require(next == _msgSender() && next != address(0), 'Not your turn');
        
        uint8 nextId = peerInfo[g].groupSize;
        uint poolToDate = peerInfo[g].totalPoolToDate;
        uint8 rate = peerInfo[g].agreedRate;
        require(poolToDate == peerInfo[g].expectedPool, 'Pool withdraw not ready');
        require(!peerInfo[g].members[nextId].isPaid, 'Already received');
        require(peerInfo[g].members[nextId].isCreditor, 'Not eligible');        
        require(_safeTransferBUSD(address(this), next, poolToDate), 'Something went wrong.');
        peerInfo[g].members[nextId].payDay = block.timestamp.add(peerInfo[g].maxDuration);

        peerInfo[g].members[nextId].debt = poolToDate.add(poolToDate.mul(rate).div(100));
        peerInfo[g].members[nextId].isCreditor = false;
        peerInfo[g].groupSize -= 1;
        
        peerInfo[g].totalPoolToDate -= poolToDate;
        peerInfo[g].members[nextId].isPaid = true;
        
        emit Deposit(next, poolToDate);
        
        return true;
    }

    function payBack(address _adminAddr, uint _owings) external isABrother(_adminAddr, _msgSender()) isBinded(_adminAddr, _msgSender()) returns(bool) {
        address a = _adminAddr;
        uint8 pos = peerInfo[a].position[_msgSender()];
        uint out_Debt = peerInfo[a].members[pos].debt;
        uint pen = peerInfo[a].penaltyFee;
        uint8 gS = peerInfo[a].groupSize;
        
        require(!peerInfo[a].members[pos].isCreditor && out_Debt > 0 && _owings == out_Debt, 'No previous debt Or payback too low');
        if(block.timestamp > peerInfo[a].members[pos].payDay){
            out_Debt += pen;
            } else {
                out_Debt = out_Debt;
        }
        bool tf = _safeTransferBUSD(_msgSender(), address(this), out_Debt);
        if(tf) {
            peerInfo[a].members[pos].debt -= out_Debt;
            peerInfo[a].members[pos].isCreditor = true;
        } else { return false; }
        if(gS == 0) {
            peerInfo[a].staged ++;
            peerInfo[a].locked = true;
            exist[a] = true;
        }
        return true;
        
    }

    function extend(uint8 _targetPosition, uint extenda) public returns(bool) {
        require(isABigBrother[_msgSender()], 'Unauthorized ADMIN');
        require(extenda <= 14, 'Max extension time exceeded');
        peerInfo[_msgSender()].members[_targetPosition].payDay += (extenda.mul(1 days));
        return true;
    }
    
    function getCurrentTotalPool(address bigBrotherAddress) public view returns(uint256) {
        return peerInfo[bigBrotherAddress].totalPoolToDate;
    }
    
    function adjustPenalty(uint _newPenaltyFee) public returns(bool) {
        
        require(block.timestamp <= peerInfo[_msgSender()].permitTime, 'Grace period expires');
        peerInfo[_msgSender()].penaltyFee = _newPenaltyFee;

        emit PenaltyChanged(_msgSender(), _newPenaltyFee);
        return true;
    }
    
    function changeRate(uint8 newRate) public returns(bool) {
        address ms = _msgSender();
        require(isABigBrother[ms], 'Not Authorized ADMIN');
        uint fq = peerInfo[ms].frequency;
        if(fq == 0) {
            peerInfo[ms].agreedRate = newRate;
        } else {
            revert('MAX frequency reached');
        }
        return true;
    }

    function checkPenalty(address bigBroAddr) public view returns(uint256) {
        return peerInfo[bigBroAddr].penaltyFee;
    }
    
    // AIRDROPS

    function createDrop(uint8 activeTimeInDays, uint256 _totalPool, uint _unitClaim) public onlyOwner returns(bool) {
        require(airdropCount <= 255, 'BRO: Cap exceeded');
        require(activeTimeInDays > 0, 'Unsigned integer expected');
        require(_totalPool < balanceOf(address(this)), 'pool out of range');
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
            SignUps storage _new = airdrops[airdropCount].users[_msgSender()];
            _new.info = abi.encodePacked(twitterLink, tgUsername, reddit, additionalLink);
            _new.id = totalSignUpCount;
            _new._status = Status.WaitListed;

            emit NewHunter(_msgSender());
            return true;
    }

    // @dev: or approved admin to approve a friend.
    function approveForAirdrop(address target, uint8 airdropId) public onlyRole returns(bool) {
        require(airdrops[airdropId].users[_msgSender()]._status == Status.Zeroed, 'Friend not allowed');
        require(target != _msgSender(), 'Admin: Failed attempt');
        airdrops[airdropId].users[_msgSender()]._status = Status.Approved;

        return true;
    }

    function approveMultiplehunters(address[] memory targets, uint8 airdropId)  public onlyRole returns(bool) {
        for(uint i=0; i<targets.length; i++){
            require(airdrops[airdropId].users[targets[i]]._status == Status.Zeroed, 'Friend not allowed');
            require(targets[i] != _msgSender(), 'Admin: Failed attempt');
            airdrops[airdropId].users[_msgSender()]._status = Status.Approved;
            }
        return true;
    }

    function checkhunterStatus(uint8 airdropId) public view returns(Status) {
        return airdrops[airdropId].users[_msgSender()]._status;
    }

    function getBlockNumber() public view returns(uint) {
         return block.number;
    }

    function manualactivateOrDeactairdrop(uint8 _airdropId, bool _state)public returns(bool){
        
        if(_state) {
            airdrops[_airdropId].active = true;
            } else if(!_state) {
                airdrops[_airdropId].active = false;
            }
        return true;
    }

    function getHunterLinks(address user, uint8 _airdropId) public view returns(string memory, string memory, string memory, string memory) {
        bytes storage data = airdrops[_airdropId].users[user].info;
        (
            string memory twtLink, 
            string memory tgLink, 
            string memory reddit, 
            string memory adtLink
            ) = abi.decode(data, (string, string, string, string));
        return (twtLink, tgLink, reddit, adtLink);
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
            _transfer(address(this), _msgSender(), claimable);
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
    
}
