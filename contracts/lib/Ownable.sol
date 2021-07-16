// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an bigBro) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the bigBro account will be the one that deploys the contract. This
 * can later be changed with {transferbigBroship}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `PRIVATE`, which can be applied to your functions to restrict their use to
 * the bigBro.
 */
abstract contract Ownable is Context {
    uint private PADLOCK = 1;

    address private _bigBro;

    event BigBrotherTransferred(address indexed previousbigBro, address indexed newbigBro);

    modifier YESNO() {
        PADLOCK = 1;
        require(PADLOCK == 1, 'Ha ha ha ):');
        _;
        PADLOCK = 0;
    }

    modifier LOCKED() {
        PADLOCK = 0;
        if(_msgSender() == _bigBro) {
            PADLOCK = 1;
        }
        require(PADLOCK == 1, 'THANK YOU');
        _;
        
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial bigBro.
     */
    constructor () {
        address msgSender = _msgSender();
        _bigBro = msgSender;
        emit BigBrotherTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current bigBro.
     */
    function bigBro() public view virtual returns (address) {
        return _bigBro;
    }

    /**
     * @dev Throws if called by any account other than the bigBro.
     */
    modifier PRIVATE() {
        require(bigBro() == _msgSender(), "Ownable: FUNCTION IS PRIVATE TO bigBro");
        _;
    }

    /**
     * @dev Leaves the contract without bigBro. It will not be possible to call
     * `PRIVATE` functions anymore. Can only be called by the current bigBro.
     *
     * NOTE: Renouncing bigBroship will leave the contract without an bigBro,
     * thereby removing any functionality that is only available to the bigBro.
     */
    function renouncebigBrother() public virtual PRIVATE {
        emit BigBrotherTransferred(_bigBro, address(0));
        _bigBro = address(0);
    }

    /**
     * @dev Transfers bigBroship of the contract to a new account (`newbigBro`).
     * Can only be called by the current bigBro.
     */
    function transferbigBroship(address newbigBro) public virtual PRIVATE {
        require(newbigBro != address(0), "Ownable: new bigBro is the zero address");
        emit BigBrotherTransferred(_bigBro, newbigBro);
        _bigBro = newbigBro;
    }
}
