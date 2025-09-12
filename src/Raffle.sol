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

pragma solidity 0.8.19; // version

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
@title A Raffle contract
@author Abdulkadir Bala Usman (X: @Abdullkhadiir)
@notice This contract is for creating a sample of web3 Raffle
@dev Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
    //Errors
    error Raffle__NotEnoughEth();
    error Raffle__ElaspedTime();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 raffleState
    );

    //type declaration
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    //state variables
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORD = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    //Events
    event RaffleEntered(address indexed player); //listening to when there's a change in storage value
    //in this case player joining the raffle

    event WinnerPicked(address indexed winner);

    //constructor
    //receive(if exist)
    //fallback(if exists)
    //external functins
    //public functions
    //internal functions
    //private functions
    //view & pure function
    constructor(
        uint256 entranceFee,
        uint256 interval,
        bytes32 gasPrice,
        uint256 subscriptionId,
        uint32 gasLimit,
        address vrfCoordinator
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasPrice;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = gasLimit;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
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
        if (s_raffleState != RaffleState.OPEN) {
            //ensure new player can only join when raffle is open
            revert Raffle__RaffleNotOpen();
        }
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEth();
        }

        s_players.push(payable(msg.sender));

        //emit event when a new palyer entered the raffle
        emit RaffleEntered(msg.sender);
    }
    /**
    @dev this is the function that the chainlink node will call to see if the
    * lottery is ready to have a winner picked.
    * the following should be true in order for upkeepNeeded to be true:
    * 1. The time interval has passed between raffle
    * 2. The lottery is open
    * 3. The contract has Eth
    * 4. Implicitly, your subscription has Link
    * @param - ignored
    * @return upkeepNeeded - true if its time to restart the lottery
     */

    function checkUpkeep(
        bytes memory /*checkdata */
    ) public view returns (bool upkeepNeeded, bytes memory /**performData */) {
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >=
            i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }
    function performUpkeep(bytes calldata /*performData*/) external {
        //check if enough time has passed
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        // if ((block.timestamp - s_lastTimeStamp) > i_interval) {
        //     revert Raffle__ElaspedTime();
        // }

        s_raffleState = RaffleState.CALCULATING;

        // Get random number from chainlink

        //s_vrfcoordinator is from the inherited contract(VRFConsumerBaseV2Plus)

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORD,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        //this function is called in an external function from the inherited contract
        uint256 indexOfWinner = randomWords[0] % s_players.length; //winner index
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);

        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(s_recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}(""); //paying the recent winner

        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    //getter functions are view functions

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }
    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }
}
