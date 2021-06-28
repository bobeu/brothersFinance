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
    function mint(address destination, uint256 amount) internal returns (bool) {
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
        uint8 peerSize;
        uint groupNum;
        uint8 iterator;
        uint tokenValue;
        uint balancer;
        address[] paid;
        mapping(address => mapping(uint => BrotherInfo)) adminIndexed;
        mapping(address => Date) timings;
        mapping(address => Payment) payments;
        mapping(address => uint8) disputed;
    }
    
    struct Date {
        uint use_days;
        uint lastPayDate;
        uint permitTime;
    }
    
    struct Payment {
        uint unit;
        uint actualPoolSize;
        uint interest;
        uint penaltyFee;
        uint expectedPool;
        uint accruedDiv;
        bool dispute;
    }

    struct BrotherInfo {
        address addr;
        uint debt;
        bool isCreditor;
        uint lastPayBackDay;
        uint expectedPayDate;
        uint expectedRepaymentAmt;
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
    
    // address[] public onCompletion;
    
    mapping(address => PeerInfo) public peerInfo;
    
    mapping(address => bool) private exist;
        
    mapping(address => bool) public isAPeerBrother;

    mapping(uint8 => AirdropInfo) public airdrops;
    
    mapping(address => uint) private peerLedger;
    
    // mapping(uint => address[]) soulBrothers;
    
    // mapping(address => mapping(uint => BrotherInfo)) private members;

    mapping(address => bool) public isAdmin;
    
    // mapping(uint => address) private peerAdmins;
    
    
    modifier isTied(address adm) {
        require(adm != address(0), 'Admin: Zero address disallowed');
        PeerInfo storage g = peerInfo[adm];
        uint8 expected_pos = g.iterator;
        require(expected_pos > 0, 'No peer detected');
        require(_msgSender() == g.adminIndexed[adm][expected_pos].addr, 'Wrong caller');
        if(g.adminIndexed[adm][expected_pos].addr == _msgSender()) {
            require(exist[_msgSender()], 'User not found');
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
        require(!exist[k], 'PeerBrotheers: Multiple registration not allowed');
        _;
    }
    
    modifier isExist {
        require(exist[_msgSender()], 'Not recognized');
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
    
    // function getUsersFigure() public view onlyRole returns(uint) {
    //     return onCompletion.length;
    // }

    function setRole(address _newRole, bool any) public onlyOwner returns(bool) {
        if(any){
            require(!isAdmin[_newRole], 'Already an admin');
            isAdmin[_newRole] = true;
            return true;
        } else if(!any) {
            require(isAdmin[_newRole], 'Not already an admin');
            isAdmin[_newRole] = false;
        }
        return true;
        
    }
    
    // function getPeerAdmin(uint _index) public view onlyRole returns(address) {
    //     return peerAdmins[_index];
    // }
    
    // function rewardPeerMembers(uint _index, uint amt) public onlyRole returns(bool) {
    //     address adm = getPeerAdmin(_index);
    //     uint8 gSz = peerInfo[adm].peerSize;
    //     for(uint8 i=0; i<gSz; i++) {
    //         address p = peerInfo[adm].members[gSz].addr;
    //         transfer(p, amt);
    //     }
    //     return true;
    // }
    
    
    function getGroupActivityStatus() public view onlyRole returns(bool) {
        return groupStatus;
    } 
    
    function changePeerActivityStatus(bool state) public onlyOwner returns(string memory) {
        if(!state){
            require(groupStatus, 'Already inactive');
            groupStatus = false;
            return 'Activity is restricted';
        } else if(state){
            require(!groupStatus, 'Already active');
            groupStatus = true;
            return 'Activity has been allowed';
        }
        
    }
    
    function _deductFst(address recipient, uint value) internal returns(bool) {
        uint actualBalance = balanceOf(_msgSender());
        require(actualBalance >= value, 'Insufficient balance');
        transfer(recipient, value);
        return true;
    }
    
    function _safeTransferBUSD(address sender, address recipient, uint _amount) internal view returns(bool) {
        // uint previousBalance = busd.balanceOf(sender);
        // busd.transfer(recipient, _amount);
        // require(busd.balanceOf(sender).add(_amount) == previousBalance, 'Something went wrong');
        return true;
        
    }
   
    function resetData(
        uint _unitAmount, 
        uint8 _interestInPercent,
        uint8 _useInDays,
        uint _penaltyFeeInBUSD,
        uint8 peerSize
        ) public isExist returns(bool) {
            address s = _msgSender();
            PeerInfo storage g = peerInfo[s];
            require(isAPeerBrother[s], 'No Authorization detected');
            uint pT = g.timings[s].permitTime;
            uint gN = g.groupNum;
            require(block.timestamp <= pT && pT > 0, 'Peer Admin: Grace period exhausted');
            isAPeerBrother[s] = false;
            peerGroupCount -= 1;
            
            uint8 old_size = g.peerSize;
            uint n = old_size;
            for(uint8 i=0; i<n; i++) {
                exist[g.adminIndexed[s][n].addr] = false;
                delete g.adminIndexed[s][n];
                n -= 1;
            }
            delete g.timings[s];
            delete g.payments[s];
            delete peerInfo[s];
            _createPeerGroup(_unitAmount, _interestInPercent, _useInDays, _penaltyFeeInBUSD, peerSize, gN);
            
            peerInfo[s].timings[s].permitTime = 0;
            return true;
            
    }

    // Any of the Peer brothers agreed as bigBrother initialises a finance group
    function _createPeerGroup(uint _unitAmount, uint8 ratePercent, uint8 num_days, uint penalty, uint8 g_Size, uint allGrpCount) internal returns(uint, uint8) {
        address s = _msgSender();
        uint u = _unitAmount;
        uint8 r = ratePercent;
        require(groupStatus, 'Not available at this time');
        require(g_Size > 1 && g_Size < 2**8, 'Max member limit exceeded or size less than 2');
        require(num_days > 0 && num_days <= 7, 'But why? Consider rest');
        // (uint tkv, uint balancer) = _deductFst(address(this), u);
        uint p = getCurrentPrice();
        uint token_value = u.mul(g_Size).div(p);
        uint balancer = token_value.mul(10).div(100);
        PeerInfo storage g = peerInfo[s];
        if(_safeTransferBUSD(s, address(this), u)) {
            uint it = u.mul(r).div(100);
            g.iterator += 1;
            g.peerSize = g_Size;
            g.tokenValue = token_value;
            g.balancer = balancer;
            g.timings[s] = Date(num_days, 0, block.timestamp.add(1 days));
            g.payments[s] = Payment(u, u, it, penalty, u.mul(g_Size), 0, false);
            uint8 esc = g_Size;
            for(uint8 i=0; i<g_Size; i++) {
                g.adminIndexed[s][esc] = BrotherInfo(address(0), 0, false, 0, 0, 0, false, 0);
                esc -= 1;
            }
            g.adminIndexed[s][1].addr = s;
            g.adminIndexed[s][1].isCreditor = true;
            g.adminIndexed[s][1].credit = u;
            isAPeerBrother[s] = true;
            peerGroupCount = peerGroupCount.add(1);
            exist[s] = true;
            if(allGrpCount == 0) {
                g.groupNum = peerGroupCount;
            } else {
                g.groupNum = allGrpCount;
            }
            
        } else {
            revert('Request failed');
        }
        return (g.groupNum, 1);
    }

    function createPeerGroup(uint _unitAmount, uint8 interestInPercent, uint8 num_days, uint penalty, uint8 g_Size) public isNotExisting(_msgSender()) returns(uint, uint8) {
        
        _createPeerGroup(_unitAmount, interestInPercent, num_days, penalty, g_Size, 0);
        
    }

    function getMemberInfo(address adminAddr, uint8 memberId) public view isExist returns(address, uint, bool, uint, bool, uint, uint, uint) {
        address p = adminAddr;
        uint8 m = memberId;
        return (
            peerInfo[p].adminIndexed[p][m].addr,
            peerInfo[p].adminIndexed[p][m].debt,
            peerInfo[p].adminIndexed[p][m].isCreditor,
            peerInfo[p].adminIndexed[p][m].lastPayBackDay,
            peerInfo[p].adminIndexed[p][m].isPaid,
            peerInfo[p].adminIndexed[p][m].credit,
            peerInfo[p].adminIndexed[p][m].expectedRepaymentAmt,
            peerInfo[p].adminIndexed[p][m].expectedPayDate
            );
    }
    
 
    function joinYourPeer(address adminAddr) public isNotExisting(_msgSender()) returns(uint8) {
        address p = _msgSender();
        address a = adminAddr;
        PeerInfo storage g = peerInfo[a];
        uint8 iter = g.iterator;
        require(iter >= 1, 'Peer not exist');
        uint8 ap = iter + 1;
        require(ap <= g.peerSize, 'No vacant index for this peer');
        uint remittance = g.payments[a].unit;
        require(g.adminIndexed[a][ap].addr == address(0), 'Denied: Multiple registration');
        uint totalUSDPool = g.payments[a].actualPoolSize;
        uint expectedPoolBal = g.payments[a].expectedPool;
        if((totalUSDPool.add(remittance) <= expectedPoolBal)){
            // (uint t, uint b) = _deductFst(address(this), remittance);
            require(_safeTransferBUSD(p, address(this), remittance), 'Not completed');
            g.adminIndexed[a][ap].addr = p; 
            g.adminIndexed[a][ap].isCreditor = true;
            g.adminIndexed[a][ap].credit = remittance;
            g.payments[a].actualPoolSize += remittance;
            exist[p] = true;
            // soulBrothers[adm][pos] = m;
            peerInfo[a].iterator ++;

            emit Deposit(p, remittance);
            return ap;
        } else {
            revert('Pool amount is reached');
        }
    }
    
    function getCurrentPrice() internal pure returns(uint256) {
        return 2;
    }
    
    function dispute(address peerAdmin, uint8 pz, uint gn, uint8 iter, address newAddr) public onlyRole returns(bool) {
        address a = peerAdmin;
        PeerInfo storage g = peerInfo[a];
        uint8 d_pos = g.disputed[a];
        g.peerSize = pz;
        g.groupNum = gn;
        g.iterator = iter;
        g.adminIndexed[a][d_pos].addr = newAddr;
        return true;
    }
    
    function getFinance(address adminAddr) public isExist isTied(adminAddr) returns(bool) {
        address g = adminAddr;
        address m = _msgSender();
        PeerInfo storage p = peerInfo[g];
        uint next_p = p.iterator;
        address next = p.adminIndexed[g][next_p].addr;
        if(p.adminIndexed[g][next_p - 1].addr == address(0)) { p.adminIndexed[g][next_p - 1].addr = address(this); }
        uint poolToDate = p.payments[m].actualPoolSize;
        uint use_P = p.timings[m].use_days.mul(1 days);
        uint i = p.payments[g].interest;
        uint value = p.tokenValue.add(p.balancer);
        uint debt = p.adminIndexed[g][next_p].expectedRepaymentAmt = poolToDate.add(i);
        
        require(poolToDate >= p.payments[m].expectedPool, 'Pool not complete');
        require(next == m && !p.adminIndexed[g][next_p].isPaid, 'Already received');
        require(p.adminIndexed[g][next_p].isCreditor, 'Not eligible');
        require(_deductFst(address(this), value), 'Failed');
        require(_safeTransferBUSD(address(this), m, poolToDate), 'Transaction could not be completed');
        p.adminIndexed[g][next_p].expectedPayDate = block.timestamp.add(use_P);
        p.adminIndexed[g][next_p].debt = debt;
        p.adminIndexed[g][next_p].isCreditor = false;
        p.adminIndexed[g][next_p].expectedRepaymentAmt = poolToDate.add(i);
        peerLedger[m] = value;

        p.payments[g].actualPoolSize -= poolToDate;
        p.adminIndexed[g][next_p].isPaid = true;
        peerInfo[g].iterator -= 1;
        
        emit Deposit(m, poolToDate);
     
        return true;
    }
 
    function getPaymentInfo(address adminAddr) public view isExist returns(uint, uint, uint, uint, uint, uint) {
        address a = adminAddr;
        PeerInfo storage g = peerInfo[a];
        return (
            g.payments[a].unit,
            g.payments[a].actualPoolSize,
            g.payments[a].interest,
            g.payments[a].penaltyFee,
            g.payments[a].expectedPool,
            g.payments[a].accruedDiv
            );
    }

    function getDateInfo(address adminAddr) public view isExist returns(uint, uint, uint) {
        address a = adminAddr;
        PeerInfo storage g = peerInfo[a];
        return ( 
            g.timings[a].use_days,
            g.timings[a].lastPayDate,
            g.timings[a].permitTime
        );
    }
    
    function _liquidate(PeerInfo storage g, address adm) internal {
        g = peerInfo[adm];
        uint8 pos = g.iterator;
        address c_beneficiary = g.adminIndexed[adm][pos + 1].addr;
        peerLedger[c_beneficiary] = 0;
        exist[_msgSender()] = false;
        g.adminIndexed[adm][pos + 1].addr = address(0);
    }

    function payBack(address _adminAddr, uint amount, uint8 pos) external isExist returns(bool) {
        address a = _adminAddr;
        PeerInfo storage g = peerInfo[a];
        uint out_Debt = g.adminIndexed[a][pos].debt;
        uint pen = g.payments[a].penaltyFee;
        uint e_pday = g.adminIndexed[a][pos].expectedPayDate;
 
        require(!g.adminIndexed[a][pos].isCreditor && out_Debt > 0, 'No previous debt Or payback too low');
        if(block.timestamp > e_pday && block.timestamp < e_pday.add(1 days)){
            out_Debt += pen;
        } else if(block.timestamp > e_pday && block.timestamp >= e_pday.add(1 days)) {
            g.payments[a].dispute = true;
            g.disputed[a] = pos;
            _liquidate(g, a);
        } else {
            out_Debt = out_Debt;
        }
        if(amount < out_Debt && _safeTransferBUSD(_msgSender(), address(this), amount)) {
            g.adminIndexed[a][pos].debt -= amount;
            g.adminIndexed[a][pos].lastPayBackDay = block.timestamp;
            g.payments[a].actualPoolSize += amount;
        } else if(amount >= out_Debt && _safeTransferBUSD(_msgSender(), address(this), amount)) {
            g.adminIndexed[a][pos].debt = 0;
            g.payments[a].actualPoolSize += amount;
            g.adminIndexed[a][pos].isCreditor = true;
            g.timings[a].lastPayDate = block.timestamp;
            g.paid.push(_msgSender());
            uint aps = g.payments[a].actualPoolSize;
            uint ep = g.payments[a].expectedPool;
            if(aps >= ep) {
                uint div = aps.sub(ep);
                g.payments[a].accruedDiv.add(div);
                g.paid.push(_msgSender());
            }
            _check(g, a);
        }
        
        return true;
        
    }
    
    function _check(PeerInfo storage p, address adm) internal {
        p = peerInfo[adm];
        uint8 gZ = p.peerSize;
        uint aps = p.payments[adm].actualPoolSize;
        uint tkv = p.tokenValue;
        uint blr = p.balancer;
        require(aps > 0, 'Pool value empty');
        if(p.paid.length == p.peerSize) {
            uint unit_pay = aps.div(gZ);
            for(uint i=0; i<p.paid.length; i++){
                address each = p.paid[i];
                require(peerLedger[p.paid[i]] >= tkv.add(blr), 'Anomally detected');
                require(_safeTransferBUSD(address(this), each, unit_pay), 'Txn Could not be completed');
            }
            p.payments[adm].actualPoolSize = 0;
        }
    }

    // function extend(uint8 _targetindex, uint extenda) public isExist returns(bool) {
    //     require(isAPeerBrother[_msgSender()], 'Unauthorized ADMIN');
    //     require(extenda <= 14, 'Max extension time exceeded');
    //     peerInfo[_msgSender()].members[_targetindex].lastPayDay += (extenda.mul(1 days));
    //     return true;
    // }
    
    // function getCurrentTotalPool(address adminAddr) public view isExist returns(uint256) {
    //     return peerInfo[adminAddr].actualPoolSize;
    // }
    
    // function getRepaymentAmt(address adminAddr) public view isExist returns(uint) {
    //     return peerInfo[adminAddr].expectedRepaymentAmt;
    // }
    
    // function getDebtBalance(address adminAddr, uint8 _userIndex) public view isExist returns(uint) {
    //     return peerInfo[adminAddr].members[_userIndex].debt;
    // }
    
    // function getlastUnitPayDate(address adminAddr, uint8 _userIndex) public view isExist returns(uint) {
    //     return peerInfo[adminAddr].members[_userIndex].lastPayDay;
    // }
    
    // function getlastUnitPayDate(address adminAddr, uint8 _userIndex) public view isExist returns(uint) {
    //     return peerInfo[adminAddr].members[_userIndex].lastPayDay;
    // }
    
    // function adjustPenalty(uint _newPenaltyFee) public returns(bool) {
        
    //     require(block.timestamp <= peerInfo[_msgSender()].permitTime, 'Grace period expires');
    //     peerInfo[_msgSender()].penaltyFee = _newPenaltyFee;

    //     emit PenaltyChanged(_msgSender(), _newPenaltyFee);
    //     return true;
    // }
    
    // function checkInterestAmount(address adminAddr) public view isExist returns(uint) {
    //     return peerInfo[adminAddr].interest;
    // }

    // function checkPenaltyFee(address adminAddr) public view isExist returns(uint256) {
    //     return peerInfo[adminAddr].penaltyFee;
    // }
    
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
