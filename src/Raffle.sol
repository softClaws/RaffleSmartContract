//SPDX-License-Identifier: MIT

//oder of content of contract
//version
//imports
//errors
//interface/library/contracts
//type declaration
//state varaibles
//events
//modifiers
//functions

pragma solidity ^0.8.19; // version
/**
@title A Raffle contract
@author Abdulkadir Bala Usman (X: @Abdullkhadiir)
@notice This contract is for creating a sample of web3 Raffle
@dev Implements Chainlink VRFv2.5
 */

contract Raffle {
    //Errors
    error Raffle__error();

    //state variables
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    //Events
    event RaffleEntered(address indexed player); //listening to when there's a change in storage value
    //in this case player joining the raffle

    //constructor
    //receive(if exist)
    //fallback(if exists)
    //external functins
    //public functions
    //internal functions
    //private functions
    //view & pure function
    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }
    receive() external payable {
        //incase user mistakenly call a function that doesn't exist with data
        enterRaffle();
    }
    fallback() external payable {
        //incase user mistakenly call a function that doesn't exist without data
        enterRaffle();
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__error();
        }

        s_players.push(payable(msg.sender));

        //emit event when a new palyer entered the raffle
        emit RaffleEntered(msg.sender);
    }
    function pickAWinner() public {
        //check if enough time has passed
        if (block.timestamp - s_lastTimeStamp > i_interval) {
            revert Raffle__error();
        }

        // Get random number from chainlink
    }

    //getter functions are view functions

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getSpecificPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }
}
