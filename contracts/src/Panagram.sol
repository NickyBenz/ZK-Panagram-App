//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;


import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./verifier.sol";


contract Panagram is ERC1155, Ownable {
    event VerifierUpdated(IVerifier verifier);
    event NewRoundStarted(bytes32 answer);
    event RoundWon(address winner, uint256 roundNo);
    event RunnerUp(address runnerup, uint256 roundNo);
    uint256 public constant WINNER_ID = 0;
    uint256 public  constant RUNNER_UP_ID = 1; 
    uint256 constant MIN_DURATION=10800; //3 hours 


    error NoActiveRound();
    error RoundAlreadyActive();
    error AlreadyPlayedRound(uint256, address);
    error RoundEnded();
    error RoundNotEnded(uint256 minDuration, uint256 timePassed);
    error NoWinnerYet();
    error IncorrectProof();
    IVerifier s_verifier;

    uint256 public s_currentRoundNo;
    
    struct Round{
        uint256 start_time;
        uint256 n_winners;
        bytes32 answer;
    }

    Round public s_current_round;

    mapping (uint256=> mapping(address => bool)) public s_hasPlayed; 

    constructor(IVerifier _verifier) Ownable(msg.sender) ERC1155("ipfs://QmaWbJ5TE5x8VBmsAByxBJcjjsARY8dvEwwir8hnDqLd48/{id}.json"){
        s_verifier = _verifier;
    }


    //Method to start a new round 

    function startRound(bytes32 _answer) external onlyOwner{
      uint256 timePassed = block.timestamp - s_current_round.start_time;
      //Check if the minimum Duration has passed 
      if(!_roundTimePassed() && s_currentRoundNo !=0){
        revert RoundNotEnded(MIN_DURATION, timePassed);
      }
      //Check if there has been a winner yet
      if (s_current_round.n_winners == 0 && s_currentRoundNo !=0){
        revert NoWinnerYet();
      }

       //Reset the round 
       s_current_round.n_winners = 0;
       s_current_round.answer = _answer;
       s_current_round.start_time = block.timestamp;

       s_currentRoundNo++;



       emit NewRoundStarted(_answer);
    }

  
    function makeGuess(bytes memory proof) external returns(bool){
       //Check whether the first round has been initialized
       if (s_currentRoundNo == 0){
        revert NoActiveRound();
       }
      //Check if user has already guessed
       if( s_hasPlayed[s_currentRoundNo][msg.sender]){
            revert AlreadyPlayedRound(s_currentRoundNo,msg.sender);
       }

     //Check the proof and verify it with the verifer contract
     //revert if incorrect
        bytes32[] memory publicInputs = new bytes32[](1); 
        publicInputs[0] = s_current_round.answer;
        bool isCorrectProof = s_verifier.verify(proof, publicInputs);
        if (!isCorrectProof){
            revert IncorrectProof();
        }
        _mintWinner(msg.sender);
        s_hasPlayed[s_currentRoundNo][msg.sender] = true;
     //if correct, check if they are first and mint the NFT 
        return isCorrectProof;

    }

    //Set a new verifier 
    function setVerifier(IVerifier _verifier) external onlyOwner {
        s_verifier = _verifier;
        emit VerifierUpdated(_verifier);
    }
    //

    function _mintWinner(address player) internal {

        uint256 n_winners = s_current_round.n_winners; 

         if (n_winners == 0){
            _mint(player, WINNER_ID, 0, "");
            emit RoundWon(msg.sender, s_currentRoundNo);
         }else{
            _mint(player, RUNNER_UP_ID, 1, "");
            emit RunnerUp(msg.sender, s_currentRoundNo);
         }
    }


    function _roundTimePassed() internal view returns(bool){
        uint256 time_passed = block.timestamp - s_current_round.start_time;
        return time_passed >= MIN_DURATION;
   
    }

  

}