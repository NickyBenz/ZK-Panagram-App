//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/verifier.sol";


contract TestPanagram is Test{

    HonkVerifier verifier; 
    Panagram panagram;
    address winner = address(11);
    uint256 minDuration = 10800;
    address runnerup = address(12);
    uint256 NUM_ARGS = 5;
    uint256 FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 ANSWER = bytes32(uint256(keccak256("triangles")) % FIELD_MODULUS);

    function setUp() public {

        verifier = new HonkVerifier();

        
        panagram = new Panagram(verifier);
        panagram.startRound(ANSWER);


    }


        //Test someone recieves NFT 1 if they guess second
    function _getProof(bytes32 guess, bytes32 answer) public returns (bytes memory _proof){
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js_scripts/generate_proofs.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(answer);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof,(bytes));
        console.logBytes(_proof);
    }
   

    //Test someone recieves NFT 0 if they guess first
    function testCorrectGuessPasses() public  {
        vm.startPrank(winner);
        bytes memory proof = _getProof(ANSWER, ANSWER);
        panagram.makeGuess(proof);
        assertEq(panagram.balanceOf(winner, 0), 1);
        assertEq(panagram.balanceOf(winner,1),0 );

        vm.prank(winner);
        panagram.makeGuess(proof);
        vm.expectRevert();
    }


 

}