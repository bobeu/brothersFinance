// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

import './SafeBrosToken.sol';
import './lib/Periphery.sol';


interface BUSD {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address user) external returns(uint256);
}


contract PeerBrothers is Ownable, Periphery{

    using SafeMath for uint256;
    
    event Deposit(address indexed brother, uint amount);
    
    event Received(address indexed brother, uint amount);

    event PenaltyChanged(address bigBro, uint newRate);
    
    SafeBrosToken _token;
    
    // BUSD stable_t;
    
    address public immutable busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    uint public peerGroupCount;
    
    bool private groupStatus;

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
        mapping(address => mapping(address => uint8)) ids;
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
    
        
    mapping(address => PeerInfo) public peerInfo;
    
    // mapping(address => bool) private exist;
        
    // mapping(address => bool) public isAPeerBrother;
    
    // mapping(address => uint) private peerLedger;
    
    // mapping(address => bool) public isAdmin;
        
    
    modifier isTied(address adm) {
        require(adm != address(0), 'Admin: Zero address disallowed');
        uint8 expected_pos = peerInfo[adm].iterator;
        require(expected_pos > 0, 'No peer detected');
        require(_msgSender() == peerInfo[adm].adminIndexed[adm][expected_pos].addr, 'Wrong caller');
        require(exist[_msgSender()], 'User not found');
        _;
    }

    constructor(SafeBrosToken _sToken) {
        isAdmin[_msgSender()] = true;
        _token = _sToken;
    }
    

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
    
    function rewardPeerMembers(address admin, uint amt) public onlyRole returns(bool) {
        uint ln = peerInfo[admin].paid.length;
        require(ln > 0, 'Empty list');
        // uint8 gSz = peerInfo[admin].peerSize;
        for(uint i=0; i<ln; i++) {
            _token.transfer(peerInfo[admin].paid[i], amt);
        }
        return true;
    }
    
    
    function getGroupActivityStatus() public view onlyRole returns(bool) {
        return groupStatus;
    } 
    
    function changePeerActivityStatus(bool state) public onlyOwner returns(bool) {
        if(!state){
            require(groupStatus, 'Already inactive');
            groupStatus = false;
        } else if(state){
            require(!groupStatus, 'Already active');
            groupStatus = true;
        }
        return true;
        
    }
    
    function _deductFst(address recipient, uint value) internal returns(bool) {
        uint actualBalance = _token.balanceOf(_msgSender());
        require(actualBalance >= value, 'Insufficient balance');
        _token.transfer(recipient, value);
        return true;
    }
    
    function _safeTransferBUSD(address sender, address recipient, uint _amount) internal pure returns(bool) {
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
                address each = g.adminIndexed[s][n].addr;
                exist[each] = false;
                upline[each] = address(0);
                delete g.adminIndexed[s][n];
                delete g.ids[s][each];
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
            g.ids[s][s] = 1;
            isAPeerBrother[s] = true;
            peerGroupCount = peerGroupCount.add(1);
            exist[s] = true;
            upline[s] = _msgSender();
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

    function createPeerGroup(uint _unitAmount, uint8 interestInPercent, uint8 num_days, uint penalty, uint8 g_Size) public isNotExisting(_msgSender()) returns(bool) {
        
        _createPeerGroup(_unitAmount, interestInPercent, num_days, penalty, g_Size, 0);
        return true;
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
            g.ids[a][p] = ap;
            exist[p] = true;
            upline[a] = p;
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
    
    function resolve(address peerAdmin, uint8 pz, uint gn, uint8 iter, address newAddr, address _disputed) public onlyRole returns(bool) {
        address a = peerAdmin;
        require(peerInfo[a].disputed[_disputed] > 0, 'No prior report for this account');
        PeerInfo storage g = peerInfo[a];
        uint8 d_pos = g.disputed[a];
        if(pz > 0) { g.peerSize = pz; }
        if(gn > 0) { g.groupNum = gn; }
        if(iter >= 0) { g.iterator = iter; }
        if(newAddr != address(0)) { g.adminIndexed[a][d_pos].addr = newAddr; }
        return true;
    }
    
    function getLastposition(address adm) public view isExist returns(uint8) {
        return peerInfo[adm].iterator;
    }
    
    function getLastPayDate(address admin) public view isExist returns(uint256) {
        return peerInfo[admin].timings[admin].lastPayDate;
    }
    
    function getFinance(address adminAddr) public isTied(adminAddr) returns(bool) {
        address g = adminAddr;
        address m = _msgSender();
        PeerInfo storage p = peerInfo[g];
        uint next_p = p.iterator;
        address next = p.adminIndexed[g][next_p].addr;
        if(p.adminIndexed[g][next_p - 1].addr == address(0)) { p.adminIndexed[g][next_p - 1].addr = address(this); }
        uint poolToDate = p.payments[g].actualPoolSize;
        uint use_P = p.timings[g].use_days.mul(1 days);
        uint i = p.payments[g].interest; //                    Note at fixing interest calculation at current time based on current pool
        uint value = p.tokenValue.add(p.balancer);
        
        require(poolToDate >= p.payments[g].expectedPool, 'Pool not complete');
        require(next == m && !p.adminIndexed[g][next_p].isPaid, 'Already received');
        require(p.adminIndexed[g][next_p].isCreditor, 'Not eligible');
        require(_deductFst(address(this), value), 'Failed');
        require(_safeTransferBUSD(address(this), m, poolToDate), 'Transaction could not be completed');
        p.adminIndexed[g][next_p].expectedPayDate = block.timestamp.add(use_P);
        p.adminIndexed[g][next_p].expectedRepaymentAmt = poolToDate.add(i);
        uint debt = p.adminIndexed[g][next_p].expectedRepaymentAmt;
        p.adminIndexed[g][next_p].debt = debt;
        p.adminIndexed[g][next_p].isCreditor = false;
        
        peerLedger[m] = value;

        p.payments[g].actualPoolSize -= poolToDate;
        // p.timings[g].lastPayDate
        p.adminIndexed[g][next_p].isPaid = true;
        peerInfo[g].iterator -= 1;
        
        emit Deposit(m, poolToDate);
     
        return true;
    }
 
    function getPaymentInfo(address adminAddr) public view isExist returns(uint, uint, uint, uint, uint, uint, bool) {
        address a = adminAddr;
        PeerInfo storage g = peerInfo[a];
        return (
            g.payments[a].unit,
            g.payments[a].actualPoolSize,
            g.payments[a].interest,
            g.payments[a].penaltyFee,
            g.payments[a].expectedPool,
            g.payments[a].accruedDiv,
            g.payments[a].dispute
            );
    }
    
    function getYourPositionId(address admin) public view isExist returns(uint8) {
        return peerInfo[admin].ids[admin][_msgSender()];
    }
    
    function getTotalPaidMembers(address admin) public view onlyRole returns(uint256) {
        return peerInfo[admin].paid.length;
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
    
    function _liquidate(address adm) internal {
        address p = _msgSender();
        PeerInfo storage g = peerInfo[adm];
        uint8 pos = g.iterator;
        address c_beneficiary = g.adminIndexed[adm][pos + 1].addr;
        peerLedger[c_beneficiary] = 0;
        exist[_msgSender()] = false;
        upline[p] = address(0); 
        g.adminIndexed[adm][pos + 1].addr = address(0);
    }

    function payBack(address _adminAddr, uint amount) external isExist returns(bool) {
        address a = _adminAddr;
        PeerInfo storage g = peerInfo[a];
        uint8 pos = g.ids[a][_msgSender()];
        require(pos == (g.iterator + 1), 'You have no obligation to fulfil');
        uint out_Debt = g.adminIndexed[a][pos].debt;
        uint pen = g.payments[a].penaltyFee;
        uint e_pday = g.adminIndexed[a][pos].expectedPayDate;
 
        require(!g.adminIndexed[a][pos].isCreditor && out_Debt > 0, 'No previous debt Or payback too low');
        if(block.timestamp > e_pday && block.timestamp < e_pday.add(1 days)){
            out_Debt += pen;
        } else if(block.timestamp > e_pday && block.timestamp >= e_pday.add(1 days)) {
            g.payments[a].dispute = true;
            g.disputed[a] = pos;
            _liquidate(a);
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
                _check(a);
            }
        }
        
        return true;
        
    }
    
    function getCurrentTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
    
    function getCurrentBlockNumber() external view returns(uint256) {
        return block.number;
    }
    
    function getDebtBalance(address admin) public view isExist returns(uint256) {
        uint8 pos = peerInfo[admin].ids[admin][_msgSender()];
        return peerInfo[admin].adminIndexed[admin][pos].debt;
    }
    
    function _check(address adm) internal {
        PeerInfo storage p = peerInfo[adm];
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
    
}
