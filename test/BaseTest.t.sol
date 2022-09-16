//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from 'forge-std/Test.sol';
import {TestBoilerplateBase} from "contracts/ImplementBoilerplateBase.sol";
import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

contract BaseTest is Test {

    address[] public teamAddresses = [
        0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
        0x7FA982AE8F9667B8D58ab09779029f228289B669,
        0x890B6A3E4E08e0aE889768EA2B7A1EA7d1ed6501 
    ];

    uint[] public teamShares = [
        1000,
        2500,
        6500
    ];

    address mintCurrency = 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75; //USDC
    address wftm = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83; //wFTM
    uint mintPrice = 250000000;
    uint wftmPrice = 1e18;

    TestBoilerplateBase bitest;

    function setUp() public {
        console.log("Initializing new contract");
        /*bitest = new TestBoilerplateBase(
            "BNFTTEST",                                          //name
            "BTEST",                                             //symbol
            '',                                                  //initBaseURI
            0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B,          //royaltyAddress
            500,                                                 //royaltyPercentage
            50,                                                  //maxSupply
            5,                                                   //maxMintAmount
            0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B,          //treasury
            0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c,          //lpPair
            1e18,                                                //price
            payable(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83)  //WETH
        );*/
        console.log("Init done");
        unpauseMint();
    }

    function unpauseMint() public {
        console.log("Unpausing mint");
        bitest.pausePublic(false);
        assert(bitest.publicPaused() == false);
        console.log("Done unpausing mint");
    }

    function testMintEnoughBalanceFTM() payable public {
        
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        uint premintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Premint Balance: ", premintBalance);
        bitest.mint{value: wftmPrice}(wftm, 1, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 1);
        uint postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        assert(premintBalance-postmintBalance == wftmPrice);
        vm.stopPrank();

    }

    function testMintNotEnoughBalanceFTM() public {
        
        vm.startPrank(0x04b71631FF3bdC3e2aDCD7318eb65C6e694f3667);
        uint premintBalance = address(0x04b71631FF3bdC3e2aDCD7318eb65C6e694f3667).balance;
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert();
        bitest.mint{value: wftmPrice}(wftm, 1, address(0));
        uint postmintBalance = address(0x04b71631FF3bdC3e2aDCD7318eb65C6e694f3667).balance;
        console.log("Postmint Balance", postmintBalance);
        vm.stopPrank();
    }

    /*function testMintEverythingAndMintOverSupply() public {
        console.log("Minting the entire collection");
        bitest.addCurrency(mintCurrency, 1);
        assertEq(bitest.acceptedCurrencies(mintCurrency), 1);
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        IERC20(mintCurrency).approve(address(bitest), mintPrice*10000);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        uint max = bitest.maxSupply();
        for(uint i = 1; i <= max; i++) {
            bitest.mint(mintCurrency, 1, address(0));
        }
        assert(bitest.totalSupply() == 50);
        console.log("Done Minting Collection, Starting Mint Over Supply");
        vm.expectRevert(
            abi.encodeWithSelector(NotEnoughMintsLeft.selector, 0, 1)
        );
        bitest.mint(mintCurrency, 1, address(0));
        console.log("Done Minting Over Supply");
        vm.stopPrank();
    }*/

    function testWithdraw() public {
        console.log("Testing Withdraw");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        //Mint one so money is in contract
        uint premintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Premint Balance: ", premintBalance);
        bitest.mint{value: wftmPrice}(wftm, 1, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 1);
        uint postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        assert(premintBalance-postmintBalance == wftmPrice);
        vm.stopPrank();

        //Withdraw money from contract
        uint prewithdrawBalance = IERC20(wftm).balanceOf(0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B);
        console.log("Prewithdraw Balance: ", prewithdrawBalance);
        uint wftmBal = IERC20(wftm).balanceOf(address(bitest));
        console.log("Amount in Contract: ", wftmBal);
        bitest.withdraw(wftm);
        uint postwithdrawBalance = IERC20(wftm).balanceOf(0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B);
        console.log("Postwithdraw Balance: ", postwithdrawBalance);
        wftmBal = IERC20(wftm).balanceOf(address(bitest));
        console.log("Amount in Contract: ", wftmBal);
        console.log("Done Testing Withdraw");

    }

    function testWrongToken() public {
        
        console.log("Test Wrong Token");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        IERC20(0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6).approve(address(bitest), mintPrice);
        assert(IERC20(0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        //console.log(address(bitest));
        uint premintBalance = IERC20(0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(TokenNotAuthorized.selector);
        bitest.mint(0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6, 1, address(0));
        //assert(premintBalance-postmintBalance == 250);
        //assert(bitest.balanceOf(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5) == 0);
        //assert(bitest.whitelistedAddresses(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5) == 0);
        uint postmintBalance = IERC20(0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Postmint Balance", postmintBalance);
        console.log("Test Wrong Token Done");
        vm.stopPrank();
    }

    function testMintDuringPause() public {
        console.log("Mint During Pause");
        bitest.pausePublic(true);
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        uint premintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(MintPaused.selector);
        bitest.mint{value: wftmPrice}(wftm, 1, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 0);
        uint postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        assert(premintBalance-postmintBalance == 0);
        console.log("Mint During Pause Done");
        vm.stopPrank();
    }

    function testMintLessThanOneAndMoreThanAllowed() public {
        console.log("Mint Less Than One");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        uint premintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(
            abi.encodeWithSelector(AmountLessThanOne.selector)
        );
        bitest.mint{value: wftmPrice}(wftm, 0, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 0);
        uint postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        assert(premintBalance-postmintBalance == 0);
        console.log("Mint Less Than One Done");

        console.log("Mint More Than Allowed");
        vm.expectRevert(
            abi.encodeWithSelector(AmountOverMax.selector, 7, 5)
        );
        bitest.mint{value: wftmPrice}(wftm, 7, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 0);
        postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        assert(premintBalance-postmintBalance == 0);
        console.log("Mint More Than Allowed Done");
    }


}