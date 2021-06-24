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
        uint actualPoolSize;
        uint use_days;
        uint interest;
        uint lastPayDate;
        uint8 peerSize;
        uint penaltyFee;
        uint permitTime;
        uint expectedPool;
        uint expectedRepaymentAmt;
        bool locked;
        uint frequency;
        mapping(address => uint8) position;
        mapping(uint8 => BrotherInfo) members;
        mapping(address => mapping(uint8 => address)) soulBrothers;
    }
    
    struct BrotherInfo {
        address addr;
        uint debt;
        bool isCreditor;
        uint lastPayDay;
        uint expectedPayDate;
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

    
    mapping(address => PeerInfo) public peerInfo;
    
    mapping(address => bool) private exist;
        
    mapping(address => bool) public isAPeerBrother;

    mapping(uint8 => AirdropInfo) public airdrops;
    
    mapping(address => address) public adminMemberMap;

    mapping(address => bool) public isAdmin;
    
    
    modifier isTied(address admin) {
        if(admin != address(0) && _msgSender() != address(0) && adminMemberMap[admin] == _msgSender()) {
            uint8 pos = peerInfo[admin].position[_msgSender()];
            require(pos > 0, 'No peer detected');
            require(exist[_msgSender()], 'User not found');
            require(peerInfo[admin].soulBrothers[admin][pos] == _msgSender(), 'Not recognized');
        } else {
            revert('Not your turn');
        }
        _;
    }


    modifier onlyRole {
        require(isAdmin[_msgSender()], 'Not Authorized');
        _;
    }
    
    modifier isNotExisting(address k) {
        require(!exist[k], 'PeerBrotheers: Multiple registration');
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
        uint _useInDays,
        uint _penaltyFeeInBUSD,
        uint8 peerSize
        ) public isNotExisting(_msgSender()) returns(bool) {
            address k = _msgSender();
            PeerInfo storage _new = peerInfo[k];
            require(groupStatus, 'Not available at this time');
            require(_deductFst(address(this), _unitAmount), 'Something went wrong');
            require(_useInDays <= 7, 'But why? Consider rest');
            require(!peerInfo[k].locked, 'Current round not ended');
            // require(_safeTransferBUSD(_msgSender(), address(this), _unitAmount), 'Bad Brother');

            if(_safeTransferBUSD(k, address(this), _unitAmount)) {
                uint it = _unitAmount.mul(peerSize).mul(_interestRate).div(100);
                _new.unit = _unitAmount;
                _new.use_days = _useInDays;
                _new.actualPoolSize = _unitAmount;
                _new.interest = it;
                _new.use_days = _useInDays;
                _new.peerSize = peerSize - 1;
                _new.frequency = 0;
                _new.penaltyFee = _penaltyFeeInBUSD;
                _new.permitTime = block.timestamp.add(1 days); //Admin can change data within this time window
                _new.expectedPool = _unitAmount.mul(peerSize);
                _new.expectedRepaymentAmt = _unitAmount.mul(peerSize).add(it);
                uint8 esc = peerSize;
                for(uint8 i=0; i<peerSize; i++) {
                    _new.members[esc] = BrotherInfo({
                        addr: address(0),
                        debt: 0,
                        isCreditor: false,
                        lastPayDay: 0,
                        expectedPayDate: 0,
                        isPaid: false,
                        credit: 0
                    });
                        _new.soulBrothers[k][esc] = address(0);
                    esc -= 1;
                    // if(esc == 0) break;
                    }
                isAPeerBrother[k] = true;
                peerGroupCount = peerGroupCount.add(1);
                peerInfo[k].members[peerSize].addr = k;
                peerInfo[k].members[peerSize].isCreditor = true;
                peerInfo[k].members[peerSize].credit = _unitAmount;
                peerInfo[k].position[k] = peerSize;
                peerInfo[k].soulBrothers[k][peerSize] = k;
                exist[k] = true;
                adminMemberMap[k] = k;
            } else {
                revert('Failed');
                }
            return true;
    }
    
    function changeData(
        uint _unitAmount, 
        uint8 _interestRate,
        uint _useInDays,
        uint _penaltyFeeInBUSD,
        uint8 peerSize
        ) public returns(bool) {
        address m = _msgSender();
        uint pT = peerInfo[m].permitTime;
        uint prvUnit = peerInfo[m].unit;
        require(isAPeerBrother[m], 'No Authorization detected');
        require(pT > 0, 'Grace period exhausted');
        if(block.timestamp < pT) {
            delete peerInfo[m];
            exist[m] = false;
            peerGroupCount -= 1;
            setUpAPeer(_unitAmount, _interestRate, _useInDays, _penaltyFeeInBUSD, peerSize);
            peerInfo[m].permitTime = 0;
        } else {
            revert('Peer Admin: Grace period elapsed');
        }
    }
    
    function getMemberInfo(address adminAddr, uint8 memberId) public view returns(address, uint, bool, uint, bool, uint) {
        address p = adminAddr;
        uint8 m = memberId;
        return (
            peerInfo[p].members[m].addr,
            peerInfo[p].members[m].debt,
            peerInfo[p].members[m].isCreditor,
            peerInfo[p].members[m].lastPayDay,
            peerInfo[p].members[m].isPaid,
            peerInfo[p].members[m].credit
            );
    }

    function joinYourPeer(address adminAddr) public isNotExisting(_msgSender()) returns(uint) {
        address p = _msgSender();
        address a = adminAddr;
        require(!peerInfo[a].locked, 'Current round not ended');
        require(peerInfo[a].peerSize > 0, 'No vacant position for this peer');
        uint remittance = peerInfo[a].unit;
        uint8 ap = peerInfo[a].peerSize;
        require(peerInfo[a].members[ap].addr != p && peerInfo[a].members[ap].addr == address(0) && p != a, 'Multiple registration: denied');
        uint totalUSDPool = peerInfo[a].actualPoolSize;
        uint expectedPoolBal = peerInfo[a].expectedPool;
        if((totalUSDPool.add(remittance) <= expectedPoolBal)){
            require(_deductFst(address(this), remittance), 'Error');
            require(_safeTransferBUSD(p, address(this), remittance), 'Not completed');
            peerInfo[a].members[ap].addr = p;
            peerInfo[a].members[ap].credit = remittance;
            peerInfo[a].actualPoolSize += remittance;
            exist[p] = true;
            peerInfo[a].soulBrothers[a][ap] = p;
            peerInfo[a].position[p] = ap;
            adminMemberMap[a] = p;
            
            peerInfo[a].peerSize -= 1;
            emit Deposit(p, remittance);
            return ap;
        } else {
            revert('Pool amount is reached');
        }
    }
    
    function getCurrentPrice() internal pure returns(uint256) {
        return 2;
    }
    
    function dispute() public returns(bool) {
        
    }
    
    function getFinance(address adminAddr) public isTied(adminAddr) returns(bool) {
        address g = adminAddr;
        address m = _msgSender();

        uint poolToDate = peerInfo[g].actualPoolSize;
        uint8 pos = peerInfo[g].position[m];
        uint rate = peerInfo[g].interest;
        uint use_P = peerInfo[g].use_days.mul(1 days);
        uint debt = peerInfo[g].expectedRepaymentAmt;
        require(poolToDate >= peerInfo[g].expectedPool, 'Peer finance not ready');
        require(peerInfo[g].members[pos].addr == m && !peerInfo[g].members[pos].isPaid, 'Already received');
        require(peerInfo[g].members[pos].isCreditor, 'Not eligible');        
        require(_safeTransferBUSD(address(this), m, poolToDate), 'Transaction could not be completed');
        peerInfo[g].members[pos].expectedPayDate = block.timestamp.add(use_P);
        peerInfo[g].members[pos].debt = debt;
        peerInfo[g].members[pos].isCreditor = false;
        peerInfo[g].peerSize += 1;
        
        peerInfo[g].actualPoolSize -= poolToDate;
        peerInfo[g].members[pos].isPaid = true;
        address next = peerInfo[g].soulBrothers[g][pos + 1];
        adminMemberMap[g] = next;
        
        emit Deposit(m, poolToDate);
     
        return true;
    }

    function payBack(address _adminAddr, uint amount) external isTied(_adminAddr) returns(bool) {
        address a = _adminAddr;
        uint8 pos = peerInfo[a].position[_msgSender()];
        uint out_Debt = peerInfo[a].members[pos].debt;
        uint pen = peerInfo[a].penaltyFee;
        uint gS = peerInfo[a].peerSize;
        
        require(!peerInfo[a].members[pos].isCreditor && out_Debt > 0, 'No previous debt Or payback too low');
        if(block.timestamp > peerInfo[a].members[pos].expectedPayDate){
            out_Debt += pen;
        } else {
            out_Debt = out_Debt;
        }
        if(amount < out_Debt && _safeTransferBUSD(_msgSender(), address(this), amount)) {
            peerInfo[a].members[pos].debt -= amount;
        } else if(amount >= out_Debt && _safeTransferBUSD(_msgSender(), address(this), amount)) {
            peerInfo[a].members[pos].debt = 0;
            peerInfo[a].members[pos].isCreditor = true;
        }
        if(gS == 0) {
            peerInfo[a].staged ++;
            peerInfo[a].locked = true;
            // exist[a] = true;
        }
        return true;
        
    }

    function extend(uint8 _targetPosition, uint extenda) public returns(bool) {
        require(isAPeerBrother[_msgSender()], 'Unauthorized ADMIN');
        require(extenda <= 14, 'Max extension time exceeded');
        peerInfo[_msgSender()].members[_targetPosition].payDay += (extenda.mul(1 days));
        return true;
    }
    
    function getCurrentTotalPool(address bigBrotherAddress) public view returns(uint256) {
        return peerInfo[bigBrotherAddress].actualPoolSize;
    }
    
    function adjustPenalty(uint _newPenaltyFee) public returns(bool) {
        
        require(block.timestamp <= peerInfo[_msgSender()].permitTime, 'Grace period expires');
        peerInfo[_msgSender()].penaltyFee = _newPenaltyFee;

        emit PenaltyChanged(_msgSender(), _newPenaltyFee);
        return true;
    }
    
    function changeRate(uint8 newRate) public returns(bool) {
        address ms = _msgSender();
        require(isAPeerBrother[ms], 'Not Authorized ADMIN');
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
