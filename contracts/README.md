# ZK Panagram 


## Rules 
- Each 'answer' is a round
- Owner is only person that can start a new round 
- Each round has a minimum duration
- There needs to be a "winner" of a previous round to start a new round 

## Smart Contract (ERC1155): 
### Architecture: 

- Token ID 0 is minted to winners, Token ID 1 is minted to runners up 
- Mint ID 0 if the user is first to get a correct guess 
- Mint ID 1 for all runners up 

### Methods: 

- startRound():  Method that allows the owner to start a round  (External)
- guess(): Method that allows the user to send an initial guess (External)
- _verify(): Calls the verifier smart contract to determine if the guess is correct or not (Internal)
- _mint(): Method that mints the user an NFT (Internal)
-endRound(): Owner can terminate the round after a specified duration has passed (External)

