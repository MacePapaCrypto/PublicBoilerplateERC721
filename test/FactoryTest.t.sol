//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from 'forge-std/Test.sol';
import {TestBoilerplateBase} from "contracts/ImplementBoilerplateBase.sol";
import {TestBoilerplateFull} from "contracts/ImplementBoilerplateFull.sol";
import {BoilerplateFactory} from "contracts/BoilerplateFactory.sol";
import {console} from "forge-std/console.sol";
import {InitializeParams} from "contracts/interfaces/IBoilerplateERC721.sol";

/* Custom Error Section - Use with ethers.js for custom errors */
/*
* @dev Public Mint is Paused
*/
error MintPaused();

/*
* @dev Cannot mint zero NFTs
*/
error AmountLessThanOne();

/*
* @dev Cannot mint more than maxMintAmount
* @param amtMint - Amount the user is attempting to mint
* @param maxMint - Maximum amount allowed to be minted by user per transaction
*/
error AmountOverMax(uint256 amtMint, uint256 maxMint);

/*
* @dev Token not in Auth List
*/
error TokenNotAuthorized();

/*
* @dev Not enough mints left for mint amount
* @param supplyLeft - Number of tokens left to be minted
* @param amtMint    - Number of tokens user is attempting to mint
*/
error NotEnoughMintsLeft(uint256 supplyLeft, uint256 amtMint);

/*
* @dev Not enough ftm sent to mint
* @param totalCost - Cost of the NFTs to be minted
* @param amtFTM    - Amount being sent by the user
*/
error InsufficientFTM(uint256 totalCost, uint256 amtFTM);

contract FactoryTest is Test {

    address mintCurrency = 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75; //USDC
    address wftm = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83; //wFTM
    uint mintPrice = 250000000;
    uint wftmPrice = 1e18;

    TestBoilerplateBase baseBoilerplate;
    TestBoilerplateFull fullBoilerplate;
    BoilerplateFactory contractFactory;

    function setUp() public {
        console.log("Initializing new base contract");
        baseBoilerplate = new TestBoilerplateBase();
        console.log("Initializing new full contract");
        fullBoilerplate = new TestBoilerplateFull();
        console.log("Initializing new factory contract");
        address[2] memory boilerplateAddresses = [address(baseBoilerplate), address(fullBoilerplate)];
        contractFactory = new BoilerplateFactory(boilerplateAddresses);
        /*console.log("Contracts Created, Transferring Ownership to Factory");
        baseBoilerplate.transferOwnership(address(contractFactory));
        fullBoilerplate.transferOwnership(address(contractFactory));*/
        console.log("Ownership Transfered, Init Done");
    }

    function testBaseFactory() public {
        InitializeParams memory forBase = InitializeParams(
            "baseTest",
            "BTEST",
            "",
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            500,
            1000,
            5,
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c,
            100,
            payable(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83),
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13
        );
        console.log("Testing Base Contract Deployment");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Call Create Clone");
        contractFactory.createClone(0, forBase);
        address deployedAddress = contractFactory.getContractsByUser(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, 0);
        address ownerOfClone = TestBoilerplateBase(deployedAddress).owner();
        console.log("Owner of clone is: ", ownerOfClone);
        assert(ownerOfClone == 0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Clone Address: ", deployedAddress);
        console.log("Base Test Done");
    }

        function testFullFactory() public {
        InitializeParams memory forBase = InitializeParams(
            "fullTest",
            "FTEST",
            "",
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            500,
            1000,
            5,
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c,
            100,
            payable(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83),
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13
        );
        console.log("Testing Full Contract Deployment");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Call Create Clone");
        contractFactory.createClone(1, forBase);
        address deployedAddress = contractFactory.getContractsByUser(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, 0);
        address ownerOfClone = TestBoilerplateBase(deployedAddress).owner();
        console.log("Owner of clone is: ", ownerOfClone);
        assert(ownerOfClone == 0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Clone Address: ", deployedAddress);
        console.log("Full Test Done");
    }
}