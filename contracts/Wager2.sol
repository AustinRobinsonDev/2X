// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzeppelin-solidity/contracts/access/Ownable.sol";
import "./openzeppelin-solidity/contracts/security/Pausable.sol";

/* Change Request: getRandom() may be subject to manipulation; use ChainLink VRF Oracle */
/* Change Request: Integrate Ownable and Pausable */
/* Change Request: Revisit how Wager.sol handles withrawls */

/// @author jaredborders
/// @title Wager2
contract Wager2 is Pausable, Ownable {

    /* STATE VARIABLES */
    address public wagerer; // Wager creator
    uint constant MIN_WAGER = 0.001 ether; // Minimum stake of wager
    uint public wagerAmount; // Amount staked by wagerer
    uint constant MIN_DURATION = 300; // Duration of wager >= 5 minutes
    uint public wagerExpireTime; // To be determined by Wagerer

    // Store of all wagers 
    address public wagerStoreAddress2;

    /* MODIFIERS */
    modifier validWagerAmount {
        require(msg.value >= MIN_WAGER, "Must wager at least 0.001 ether");
        _;
    }

    modifier validWagerAvailability {
        require(block.timestamp < wagerExpireTime, "Wager has expired");
        _;
    }

    modifier matchesWagerAmount {
        require(msg.value == wagerAmount, "You must wager the same amount");
        _;
    }

    /* CONSTRUCTOR */
    /// Create a new Wager contract
    /// @param _owner - the owner to be recognized by this contract. Not necessarily `msg.sender` nor `tx.origin`
    /// @param _wagerDuration - The duration of the wager `open` period
    constructor(address _owner, uint _wagerDuration) 
        validWagerAmount // Checks if Wagerer staked enough eth 
        payable 
    {
        require(_wagerDuration >= MIN_DURATION, "Duration of wager availability is too short (<5 minutes");

        wagerer = _owner;
        wagerAmount = msg.value;
        wagerExpireTime = _wagerDuration + block.timestamp; // ex. if _wagerDuration = 300 then wagerExpireTime = currentTime + 5 minutes

        // Wager creation should be called from its store.
        wagerStoreAddress2 = msg.sender; 
    }

    /* FUNCTIONS */
    /// Allow participant to withdraw money
    /// @param _challenger - participant who wishes to accept wager proposal
    /// @dev Checks for matching amount of eth and that wager is still active
    function challenge(address _challenger) 
        external
        validWagerAvailability // Checks if wager is still available
        matchesWagerAmount // Checks if challenger staked same amount of eth
        payable
    {
        wagerAmount += uint(msg.value);
        findWinner(_challenger);
    }

    /// Determine who wins
    /// @param _challenger - participant who accepted wager proposal
    /// @dev findWinner will pay one of the participants randomly
    function findWinner(address _challenger) 
        internal
    {
        getRandom() == 0 ? 
            payable(wagerer).transfer(wagerAmount) : 
            payable(_challenger).transfer(wagerAmount);
    }

    /// Generate a random value
    /// @return 0 or 1, "randomly"
    function getRandom() 
        internal 
        view
        returns(uint) 
    {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.number,block.difficulty))) % 2;
    }

}