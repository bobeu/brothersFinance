// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;


import './SafeMath.sol';
import './Ownable.sol';
import './Context.sol';
import './BroToken.sol';

interface BUSD {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address user) external returns(uint256);
}

contract PeerBrothers is Ownable {

    using SafeMath for uint256;
    
    event Deposit(address indexed brother, uint amount);
    
    event Received(address indexed brother, uint amount);

    IBEP20 public broToken;
    
    uint public groupCount;
    
    bool private pauseGroupActivity;
    
    address public immutable busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    uint public peerBrotherCount;

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

    mapping(address => mapping(uint8 => address)) public soulBrothers;
    
    mapping(address => PeerInfo) private peerInfo;
    
    mapping(address => BrotherInfo) private broInfo;
    
    mapping(address => uint) public position;
    
    mapping(address => bool) public isABigBrother;
    
    
    modifier isABrother(address _bro) {
        require(broInfo[_bro].isBroListed, 'Not a bro');
        _;
    }
    
    modifier isBinded(address _admin, uint8 _position, address target) {
        require(soulBrothers[_admin][_position] == target, 'No ties');
        _;
    }

    constructor(IBEP20 _broToken){ //, address _baseToken
        broToken = _broToken;
        // busd = _baseToken;
    }
    
    receive () external payable {
        if(msg.value < 1e17 wei) revert();
    }
    
    function pause() public onlyOwner returns(bool) {
        pauseGroupActivity = false;
        return true;
    }
    
    function unpause() public onlyOwner returns(bool) {
        pauseGroupActivity = true;
        return true;
    }
    
    function _deductFst(address msgSender, uint unitAmount) internal returns(bool) {
        require(broToken.balanceOf(msgSender) >= 1000, 'At least 1000 BRO is required');
        uint fstdepo = unitAmount.mul(10).div(100);
        broToken.transfer(address(this), fstdepo);
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
        address admin, 
        uint8 _position, 
        uint _deposit
        ) 
        external 
        isABrother(_msgSender()) 
        isBinded(admin, _position, _msgSender()) 
        returns(bool) 
        {
        uint groupSize = peerInfo[admin].groupSize;
        uint totalUSDPool = peerInfo[admin].unit.mul(groupSize);
        
        if(peerInfo[admin].totalPoolToDate == totalUSDPool) {
            revert('Pool completed');
        } else if(peerInfo[admin].totalPoolToDate < totalUSDPool){
            uint unitPay = peerInfo[admin].unit;
            require(_deductFst(_msgSender(), unitPay), 'Error');
            require(_deposit == peerInfo[admin].unit, 'Invalid deposit');
            require(soulBrothers[admin][_position] == _msgSender(), 'Fake bro');
            require(broInfo[_msgSender()].debt == 0, 'Outstanding debt noticed');
            uint curentPrice = getCurrentPrice();
            uint mustHave = totalUSDPool.div(curentPrice).mul(1e18);
            require(broToken.balanceOf(_msgSender()) >= mustHave, 'Not enough Bro Balance');
            broToken.transfer(address(this), mustHave);
            require(_safeTransferBUSD(_msgSender(), address(this), _deposit), 'Bad Brother');
            
            peerInfo[admin].totalPoolToDate += _deposit;
            
            emit Deposit(_msgSender(), _deposit);
            
            return true;
        } else {
            revert('Deposit completed');
        }
        
    }
    
    function recieve(address admin, uint8 _position) public isABrother(_msgSender()) isBinded(admin, _position, _msgSender()) returns(bool) {
        uint8 rotator = peerInfo[admin].rotator;
        address next = soulBrothers[admin][rotator];
        require(_msgSender() == next, 'Not your turn');
        
        uint groupSize = peerInfo[admin].groupSize;
        uint poolToDate = peerInfo[admin].totalPoolToDate;
        require(poolToDate > 0, 'Nothing to withdraw');
        uint totalUSDPool = peerInfo[admin].unit.mul(groupSize);
        if(poolToDate == totalUSDPool) {
            require(!broInfo[next].isPaid, 'Already received');
            uint _rate = peerInfo[admin].agreedRate;
            broInfo[next].payDay = block.timestamp.add(peerInfo[admin].maxDuration);
            
            require(broInfo[_msgSender()].isCreditor, 'Not eligible');
            require(_safeTransferBUSD(address(this), next, poolToDate), 'Something went wrong.');
            broInfo[next].debt = poolToDate.add(poolToDate.mul(_rate).div(100));
            broInfo[_msgSender()].isCreditor = false;
            peerInfo[admin].rotator ++;
            
            peerInfo[admin].totalPoolToDate -= poolToDate;
            broInfo[next].isPaid = true;
            
            emit Deposit(next, poolToDate);
            
            return true;
        } else {
            return false;
        }
        
        
    }

    function payBack(address _admin, uint8 _position, uint _owings) external isABrother(_msgSender()) isBinded(_admin, _position, _msgSender()) returns(bool) {
        uint outstandingDebt = broInfo[_msgSender()].debt;
        uint penalty = peerInfo[_admin].penaltyFee;
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
        } else{
            return false;
        }
        
    }

    function extend(uint8 _targetPosition, uint extenda) external returns(bool) {
        require(isABigBrother[_msgSender()], 'Unauthorized user');
        require(extenda <= 14, 'Max extension time exceeded');
        address targ = soulBrothers[_msgSender()][_targetPosition];
        broInfo[targ].payDay += (extenda.mul(1 days));
        return true;
    }
    
    function currentGetTotalPool(address grpAdminAddress) public view returns(uint256) {
        return peerInfo[grpAdminAddress].totalPoolToDate;
    }
    
    function adjustPenalty(uint _newPenaltyFee) public returns(bool) {
        require(isABigBrother[_msgSender()], 'Not Authorized');
        require(block.timestamp <= peerInfo[_msgSender()].permitTime, 'Grace period expires');
        peerInfo[_msgSender()].penaltyFee = _newPenaltyFee;
        return true;
    }
    
    
    
    
}
