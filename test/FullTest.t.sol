//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from 'forge-std/Test.sol';
import {TestBoilerplateFull} from "contracts/ImplementBoilerplateFull.sol";
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

contract FullTest is Test {

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
    uint wftmPrice = 10e18;

    TestBoilerplateFull bitest;

    function setUp() public {
        console.log("Initializing new contract");
        /*bitest = new TestBoilerplateFull(
            "BNFTTEST",                                  //name
            "BTEST",                                     //symbol
            '',                                          //initBaseURI
            0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B,  //royaltyAddress
            500,                                         //royaltyPercentage
            50,                                          //maxSupply
            5,                                           //maxMintAmount
            0x618943dcf871C947Eb7D7ecfF48f153ec7dEA49B,  //treasury
            0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c,  //lpPair
            100,                                         //price
            payable(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83)  //WETH
        );*/
        console.log("Init done");
        setContractSettings();
        unpauseMint();
    }

    function setContractSettings() public {
        console.log("Setting team and shares");
        for(uint i = 0; i < 3; i++) {
            bitest.setTeamAndShares(teamAddresses[i], teamShares[i], i);
        }
        assert(bitest.numberOfTeamMembers() == 3);
        console.log("Done setting team and shares");

        console.log("Setting accepted currency");
        bitest.addCurrency(mintCurrency, mintPrice);
        assertEq(bitest.acceptedCurrencies(mintCurrency), mintPrice);
        console.log("Accepted Token Address: ", mintCurrency);
        console.log("Price: ", bitest.acceptedCurrencies(mintCurrency));
        bitest.addCurrency(wftm, wftmPrice);
        assertEq(bitest.acceptedCurrencies(wftm), wftmPrice);
        console.log("Accepted Token Address: ", wftm);
        console.log("Price: ", bitest.acceptedCurrencies(wftm));
        console.log("Done setting accepted currency");
    }

    function unpauseMint() public {
        console.log("Unpausing mint");
        bitest.pausePublic(false);
        assert(bitest.publicPaused() == false);
        console.log("Done unpausing mint");
    }

    function testMintEnoughBalanceUSDC() public {
        
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        IERC20(mintCurrency).approve(address(bitest), mintPrice);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        //console.log(address(bitest));
        uint premintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Premint Balance: ", premintBalance);
        bitest.mint(mintCurrency, 1, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 1);
        uint postmintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        assert(premintBalance-postmintBalance == 250000000);
        console.log("Postmint Balance", postmintBalance);
        vm.stopPrank();

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

    function testMintNotEnoughBalance() public {
        
        vm.startPrank(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5);
        IERC20(mintCurrency).approve(address(bitest), mintPrice);
        assert(IERC20(mintCurrency).allowance(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5, address(bitest)) > 0);
        //console.log(address(bitest));
        uint premintBalance = IERC20(mintCurrency).balanceOf(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5);
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(bytes("WERC10: transfer amount exceeds balance"));
        bitest.mint(mintCurrency, 1, address(0));
        uint postmintBalance = IERC20(mintCurrency).balanceOf(0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5);
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
        assert(bitest.totalSupply() == 500);
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
        IERC20(mintCurrency).approve(address(bitest), mintPrice*10000);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        bitest.mint(mintCurrency, 1, address(0));
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) > 0);
        vm.stopPrank();
        uint prewithdrawBalanceFuneral = IERC20(mintCurrency).balanceOf(0x7FA982AE8F9667B8D58ab09779029f228289B669);
        console.log("Prewithdraw Balance 1: ", prewithdrawBalanceFuneral);
        uint prewithdrawBalanceSurveyor = IERC20(mintCurrency).balanceOf(0x890B6A3E4E08e0aE889768EA2B7A1EA7d1ed6501);
        console.log("Prewithdraw Balance 2: ", prewithdrawBalanceSurveyor);
        uint usdcBal = IERC20(mintCurrency).balanceOf(address(bitest));
        console.log("Amount in Contract: ", usdcBal);
        bitest.withdraw(mintCurrency);
        uint postwithdrawBalanceFuneral = IERC20(mintCurrency).balanceOf(0x7FA982AE8F9667B8D58ab09779029f228289B669);
        console.log("Postwithdraw Balance 1: ", postwithdrawBalanceFuneral);
        uint postwithdrawBalanceSurveyor = IERC20(mintCurrency).balanceOf(0x890B6A3E4E08e0aE889768EA2B7A1EA7d1ed6501);
        console.log("Postwithdraw Balance 2: ", postwithdrawBalanceSurveyor);
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
        IERC20(mintCurrency).approve(address(bitest), mintPrice);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        //console.log(address(bitest));
        uint premintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(MintPaused.selector);
        bitest.mint(mintCurrency, 1, address(0));
        uint postmintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Postmint Balance", postmintBalance);
        assert(postmintBalance - premintBalance == 0);
        console.log("Mint During Pause Done");
        vm.stopPrank();
    }

    function testMintLessThanOneAndMoreThanAllowed() public {
        console.log("Mint Less Than One");
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        IERC20(mintCurrency).approve(address(bitest), mintPrice);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        //console.log(address(bitest));
        uint premintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Premint Balance: ", premintBalance);
        vm.expectRevert(AmountLessThanOne.selector);
        bitest.mint(mintCurrency, 0, address(0));
        uint postmintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Postmint Balance", postmintBalance);
        assert(postmintBalance - premintBalance == 0);
        console.log("Mint Less Than One Done");

        console.log("Mint More Than Allowed");
        vm.expectRevert(
            abi.encodeWithSelector(AmountOverMax.selector, 7, 5)
        );
        bitest.mint(mintCurrency, 7, address(0));
        postmintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        assert(postmintBalance - premintBalance == 0);
        console.log("Mint More Than Allowed Done");
    }

    function testDiscounts() public {
        console.log("Set Discount For Skully");
        address skullys = 0x25ff0d27395A7AAD578569f83E30C82a07b4ee7d;
        uint discount = 5000;
        bitest.setDiscount(skullys, discount);
        vm.startPrank(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        IERC20(mintCurrency).approve(address(bitest), mintPrice);
        assert(IERC20(mintCurrency).allowance(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, address(bitest)) > 0);
        uint premintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Premint Balance: ", premintBalance);
        bitest.mint(mintCurrency, 1, 0x25ff0d27395A7AAD578569f83E30C82a07b4ee7d);
        uint postmintBalance = IERC20(mintCurrency).balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13);
        console.log("Postmint Balance", postmintBalance);
        //assert(postmintBalance - premintBalance == 125000000);
        premintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Premint Balance: ", premintBalance);
        bitest.mint{value: wftmPrice}(wftm, 1, 0x25ff0d27395A7AAD578569f83E30C82a07b4ee7d);
        assert(bitest.balanceOf(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13) == 2);
        postmintBalance = address(0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13).balance;
        console.log("Postmint Balance", postmintBalance);
        //assert(premintBalance-postmintBalance == 5e18);
        console.log("Done Testing Discounts");
    }


}