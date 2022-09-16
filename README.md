# Boilerplate ERC721

These are boilerplate contracts for an ERC721 token. Many common boilerplate contracts available leave out a variety of key features that can be utilized by creators to improve the minting experience.
The aim of this repository is to build out diverse, robust tooling for NFT contracts to allow better creative collaboration between artists and developers.

## How Do Current Boilerplates Work?

The most forked NFT repository is probably [Hash Lips](https://github.com/HashLips/hashlips_nft_contract). In this repo, you will find a basic setup for NFTs.
**It contains:**
- Revealed/Unrevealed URI variables
    - This allows for you to hide the metadata by revealing at a later date. A shortcoming here is that there is no built-in way to hide metadata of unminted tokens if you want to see the art upon reveal
- Minting in sequential tokenID order
    - The mint method covers all of the usual errors that may occur with require statements
    - If owner of contract, you can mint for free with the implemented method
- Setters for:
    - Cost
        - Cost is automatically FTM. The contract is not built to handle any other currency than the native currency of the blockchain being deployed on
    - Maximum mints per transaction
    - Revealed/Unrevealed URI
    - baseURI Extension (.json, .txt, etc.)
    - Pause/Unpause minting
- Withdraw function to remove crypto from the contract to the contract owner's wallet

## How Does This Boilerplate Improve The Current Tooling?

As seen above, the Hash Lips contracts do a great job of getting the base contract ready for deployment. The one issue is that, for unexperienced devs or artists trying to deploy an NFT contract, there is an apparent lack of customizability. This repository, via the readme and documentation, thorough test scripts, and enchanced contracts, aims to hand developers and artists alike the tools needed to build out a custom minting experience for their community from the smart contract side of the equation.

**Enhancements to Hash Lips**
- Revealed/Unrevealed URI has been merged into just the initial URI
    - In most cases, even when doing a reveal (i.e. not showing the art upon mint), the extra URI is generally redundant. We can save lighten up the contract a bit by just using the one URI and removing the extra function setter
- Minting has been heavily updated
    - Minting can be done with any currency at any price set by the contract owner
    - Price and currency can be re-set at any point
    - Minting function comes with custom errors for enhanced error handling on the frontend
        - Rather than a failed transaction error, we can pass back data from the mint and more accurately identify the problem
    - Discounts have been added into the mint function (If no discounts, either comment out the line in the mint, or leave, as it should return no discount by default unless discounts are set)
    - Minting is done in a random order
        - No need to use an API or go out of your way to hide the token metadata.
- Setters for:
    - Currency and Price
    - NFT Collection Discounts
    - Team Addresses and Percentage Shares
- Withdraw function is enhanced to split the proceeds among the team based on the set team addresses and shares mapped to each address
- Implements ERC2981 to allow for royalties to be built into the contract
    - Some marketplaces will override this setting anyway, but its nice to have it set to make sure the artist gets royalties in case the marketplace doesn't handle the royalties themselves

## How Can I Try It Out Myself?

In order to test, simply run the hardhat test task. Inside the "test" folder, you will find All of the forge tests. These test both the base and full implementation of modules, as well as the factory contracts. To run the tests, simply run the command below with the proper test contract name as the match-path argument.

`forge test --via-ir --fork-url https://rpc.ftm.tools/ --match-contract ChooseATest --gas-report -vvv`

This will give you a gas report for the functions run, as well as give a stack trace for any failing tests. For more info on CLI flags in Foundry, refer to the Foundry Book here: https://book.getfoundry.sh/

A deployment script is available in the script/ folder. This deployment script is set up to deploy the Full Module version of the boilerplate. This can be run via the command below:

`source .env`

This allows you to use variables in your script from the .env file in your directory. Then we run:

`forge script script/Deploy.s.sol --via-ir --rpc-url $FTM_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $FTMSCAN_API_KEY -vvvv`