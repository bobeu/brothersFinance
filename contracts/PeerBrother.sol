// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

import './BroToken.sol';
                   // ====>INTERFACE BINANCE USD<===========================================================

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
    constructor() ERC20("BrothersToken", "BROT"){
    
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
        super._transfer(_msgSender(), recipient, amount);

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

    function _suspendAccount(address _target) internal virtual returns(bool) {
        if(!suspension[_target]) revert('Account not suspended before now');
        suspension[_target] = true;
        emit MuteAccount(_target);
        return suspension[_target];
    }

    function _unsuspendAccount(address _target) internal virtual returns(bool) {
        if(suspension[_target]) revert('Account is suspended before now.');
        suspension[_target] = true;
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
    
    uint public groupCount;
    
    bool private familyAct;
    
    address public immutable busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    uint public peerBrotherCount;

    uint8 public airdropCount;

    uint256 public totalClaimants;

    uint public totalSignUpCount;
    
    bool pauseGroupActivity;


    Status status;

    // AirdropInfo public currentInstance = airdrops[airdropCount];

    struct PeerInfo {
        uint unit;
        uint totalPoolToDate;
        uint maxDuration;
        uint8 agreedRate;
        uint8 staged;
        uint groupSize;
        uint8 rotator;
        uint penaltyFee;
        uint permitTime;
    }
    
    struct BrotherInfo {
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
    
    mapping(address => PeerInfo) private peerInfo;
    
    mapping(address => BrotherInfo) private broInfo;
    
    mapping(address => uint) public position;
    
    mapping(address => bool) public isABigBrother;

    mapping(uint8 => AirdropInfo) public airdrops;

    // mapping(address => Friends) private hunters;

    mapping(address => bool) private isAdmin;
    
    
    modifier isABrother(address _bro) {
        require(broInfo[_bro].isBroListed, 'Not a bro');
        _;
    }
    
    modifier isBinded(address _bigBrotherAddress, uint8 _position, address target) {
        require(soulBrothers[_bigBrotherAddress][_position] == target, 'No ties');
        _;
    }

    modifier onlyRole {
        require(isAdmin[_msgSender()], 'Not Authorized');
        _;
    }

    constructor(uint mintAmount, address newAdmin) {
        mint(address(this), mintAmount);
        isAdmin[_msgSender()] = true;
    }
    
    //    =====>MAIN<=====

    receive () external payable {
        if(msg.value < 1e17 wei) revert();
    }

    function setRole(address _newRole, bool state) public onlyOwner returns(bool) {
        if(state){
            isAdmin[_msgSender()] = true;
            return true;
        } else if(!state) {
            isAdmin[_msgSender()] = false;
        }
        return true;
        
    }
    
    function changeFamilyActStatus(bool state) public onlyOwner returns(string memory) {
        if(state){
            familyAct = false;
            return 'Activity is restricted';
        } else if(!state){
            familyAct = true;
            return 'Activity has been allowed';
        }
        
    }
    
    function _deductFst(address msgSender, uint unitAmount) internal returns(bool) {
        uint actualBalance = balanceOf(msgSender);
        require(actualBalance >= 1000, 'Insufficient balance');
        uint fstdepo = unitAmount.mul(10).div(100);
        transfer(address(this), fstdepo);
        return true;
    }
    
    function _safeTransferBUSD(address sender, address recipient, uint _amount) internal returns(bool) {
        uint previousBalance = BUSD(busd).balanceOf(sender);
        BUSD(busd).transfer(recipient, _amount);
        require(BUSD(busd).balanceOf(sender).add(_amount) == previousBalance, 'Something went wrong');
        return true;
        
    }

    function setTies(
        address[] memory _brothers, 
        uint _unitAmount, 
        uint8 _interestRate, 
        uint _maxDurationInDays,
        uint _penaltyFeeInBUSD
        ) external returns(bool) {
            require(pauseGroupActivity, 'Not available at this time');
            require(_deductFst(_msgSender(), _unitAmount), 'Error');
            require(_brothers.length <= 10, '10 Brothers Max');
            require(_maxDurationInDays.mul(1 days) <= 7 days, 'But why? Consider rest');
            require(peerInfo[_msgSender()].staged == 0 || position[_msgSender()] == 0, 'Multiple registration');
            require(_safeTransferBUSD(_msgSender(), address(this), _unitAmount), 'Bad Brother');
            uint i = 0;
            uint num_Bro = _brothers.length;
            uint8 _identifier = 0;
            while (i < num_Bro) {
                i += 1;
                _identifier ++;
                BrotherInfo storage bro = broInfo[_brothers[i]];
                bro.isBroListed = true;
                bro.debt += 0;
                bro.isCreditor = true;
                bro.payDay = 0;
                bro.isPaid = false;
                soulBrothers[_msgSender()][_identifier] = _brothers[i];
                position[_brothers[i]] = _identifier;
            }
            peerInfo[_msgSender()] = PeerInfo({
                unit: _unitAmount,
                totalPoolToDate: _unitAmount,
                agreedRate: _interestRate,
                maxDuration: _maxDurationInDays.mul(1 days),
                staged: 1,
                groupSize: _brothers.length,
                rotator: 1,
                penaltyFee: _penaltyFeeInBUSD,
                permitTime: block.timestamp.add(1 days)
                
            });
        isABigBrother[_msgSender()] = true;
        peerBrotherCount ++;
        groupCount ++;
        return true;
    }
    
    function getCurrentPrice() internal pure returns(uint256) {
        return 2;
    }

    function deposit(
        address bigBrotherAddress, 
        uint8 _position, 
        uint _deposit
        ) 
        external 
        isABrother(_msgSender()) 
        isBinded(bigBrotherAddress, _position, _msgSender()) 
        returns(bool) 
        {
        uint groupSize = peerInfo[bigBrotherAddress].groupSize;
        uint totalUSDPool = peerInfo[bigBrotherAddress].unit.mul(groupSize);
        
        if(peerInfo[bigBrotherAddress].totalPoolToDate == totalUSDPool) {
            revert('Pool completed');
        } else if(peerInfo[bigBrotherAddress].totalPoolToDate < totalUSDPool){
            uint unitPay = peerInfo[bigBrotherAddress].unit;
            require(_deductFst(_msgSender(), unitPay), 'Error');
            require(_deposit == peerInfo[bigBrotherAddress].unit, 'Invalid deposit');
            require(soulBrothers[bigBrotherAddress][_position] == _msgSender(), 'Fake bro');
            require(broInfo[_msgSender()].debt == 0, 'Outstanding debt noticed');
            uint curentPrice = getCurrentPrice();
            uint mustHave = totalUSDPool.div(curentPrice).mul(1e18);
            require(balanceOf(_msgSender()) >= mustHave, 'Not enough Bro Balance');
            transfer(address(this), mustHave);
            require(_safeTransferBUSD(_msgSender(), address(this), _deposit), 'Bad Brother');
            
            peerInfo[bigBrotherAddress].totalPoolToDate += _deposit;
            
            emit Deposit(_msgSender(), _deposit);
            
            return true;
            } else {
                revert('Deposit completed');
                }
        
    }
    
    function getFinance(address bigBrotherAddress, uint8 _position) public isABrother(_msgSender()) isBinded(bigBrotherAddress, _position, _msgSender()) returns(bool) {
        uint8 rotator = peerInfo[bigBrotherAddress].rotator;
        address next = soulBrothers[bigBrotherAddress][rotator];
        require(_msgSender() == next, 'Not your turn');
        
        uint groupSize = peerInfo[bigBrotherAddress].groupSize;
        uint poolToDate = peerInfo[bigBrotherAddress].totalPoolToDate;
        require(poolToDate > 0, 'Nothing to withdraw');
        uint totalUSDPool = peerInfo[bigBrotherAddress].unit.mul(groupSize);
        if(poolToDate == totalUSDPool) {
            require(!broInfo[next].isPaid, 'Already received');
            uint _rate = peerInfo[bigBrotherAddress].agreedRate;
            broInfo[next].payDay = block.timestamp.add(peerInfo[bigBrotherAddress].maxDuration);
            
            require(broInfo[_msgSender()].isCreditor, 'Not eligible');
            require(_safeTransferBUSD(address(this), next, poolToDate), 'Something went wrong.');
            broInfo[next].debt = poolToDate.add(poolToDate.mul(_rate).div(100));
            broInfo[_msgSender()].isCreditor = false;
            peerInfo[bigBrotherAddress].rotator ++;
            
            peerInfo[bigBrotherAddress].totalPoolToDate -= poolToDate;
            broInfo[next].isPaid = true;
            
            emit Deposit(next, poolToDate);
            
            return true;
            } else {
                return false;
                }

    }

    function payBack(address _bigBrotherAddress, uint8 _position, uint _owings) external isABrother(_msgSender()) isBinded(_bigBrotherAddress, _position, _msgSender()) returns(bool) {
        uint outstandingDebt = broInfo[_msgSender()].debt;
        uint penalty = peerInfo[_bigBrotherAddress].penaltyFee;
        require(!broInfo[_msgSender()].isCreditor && outstandingDebt > 0 && _owings == outstandingDebt, 'No previous debt Or payback too low');
        if(block.timestamp > broInfo[_msgSender()].payDay){
            outstandingDebt += penalty;
            } else {
                outstandingDebt = outstandingDebt;
        }
        if(_safeTransferBUSD(_msgSender(), address(this), outstandingDebt)) {
            broInfo[_msgSender()].debt -= outstandingDebt;
            broInfo[_msgSender()].isCreditor = true;
            return true;
            } else {
                return false;
                }
        
    }

    function extend(uint8 _targetPosition, uint extenda) public returns(bool) {
        require(isABigBrother[_msgSender()], 'Unauthorized user');
        require(extenda <= 14, 'Max extension time exceeded');
        address targ = soulBrothers[_msgSender()][_targetPosition];
        broInfo[targ].payDay += (extenda.mul(1 days));
        return true;
    }
    
    function getCurrentTotalPool(address bigBrotherAddress) public view returns(uint256) {
        return peerInfo[bigBrotherAddress].totalPoolToDate;
    }
    
    function adjustPenalty(uint _newPenaltyFee) public returns(bool) {
        require(isABigBrother[_msgSender()], 'Not Authorized');
        require(block.timestamp <= peerInfo[_msgSender()].permitTime, 'Grace period expires');
        peerInfo[_msgSender()].penaltyFee = _newPenaltyFee;

        emit PenaltyChanged(_msgSender(), _newPenaltyFee);
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

    function checkhunterStatus(uint8 airdropId) public returns(Status) {
        return airdrops[airdropId].users[_msgSender()]._status;
    }

    // function getClaimantClaimedPosition() public onlyRole returns(uint) {
    //      return hunters[target].id;
    // }

    function manualactivateOrDeactairdrop(uint8 _airdropId, bool _state)public returns(bool){
        
        if(_state) {
            airdrops[_airdropId].active = true;
            } else if(!_state) {
                airdrops[_airdropId].active = false;
            }
        return true;
    }

    function getHunterLinks(address user, uint8 _airdropId) public returns(string memory, string memory, string memory, string memory) {
        (
            string memory twtLink, 
            string memory tgLink, 
            string memory reddit, 
            string memory adtLink
            ) = abi.decode(
                string,
                string,
                string,
                airdrops[_airdropId].users[user].info
                );
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
        uint totalClaimedToDate = airdrops[airdropId].totalClaimed;
        uint airdropBalance = airdrops[airdropId].poolBalance;
        
        if(airdropBalance.sub(claimable) > 0){
            totalClaimants += 1;
            _transfer(address(this), _msgSender(), claimable);
            airdrops[airdropId].users[_msgSender()]._status = Status.Claimed;
            airdrops[airdropId].totalClaimed += claimable;
            airdrops[airdropId].poolBalance -= claimable;

            Claim storage _claim = airdrops[airdropId]._claimant[_msgSender];
            _claim._status =  Status.Claimed;
            _claim.id = totalClaimants;
        } else {
            revert("Airdrop closed");
        }
        return true;
    }
    
}
