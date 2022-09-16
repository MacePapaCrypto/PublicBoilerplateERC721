const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");
const hre = require('hardhat');
const chai = require('chai');

const {solidity} = require('ethereum-waffle');
chai.use(solidity);
const {expect} = chai;

describe("Deploy and Premint", function () {
    let testContractAddress = "";
    const acceptedCurrencies = [
        "0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83",  //WFTM
        "0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6"   //OATH
    ];

    const prices = [
        hre.ethers.utils.parseUnits('0.001', 'ether'), //WFTM
        hre.ethers.utils.parseUnits('0.001', 'ether')  //OATH
    ];

    const collections = [
        "0x25ff0d27395A7AAD578569f83E30C82a07b4ee7d", //Skully
        "0x5ba5168a88b4f1c41fe71f59ddfa2305e0dbda8c", //PopPussies
        "0xe92752C25111DB288665766aD8aDB624CCf91045", //Bitshadowz
        "0xC369d0c7f27c51176dcb01802D6Bca2b3Eb0b8dC", //BitWitches
        "0xd761dB316b5b9C9C51F7f80127497Bc618e2B422", //Mingoes
        "0xa70aa1f9da387b815Facd5B823F284F15EC73884", //Frogs
        "0x590e13984295df26c68f8c89f32fcf3a9f08177f", //PocketPals
        "0x4f504ab2e7b196a4165ab3db71e75cb2b37070e0", //RiotGoool
        "0x0ef9d39bbbed9c4983ddc4a1e189ee4938d837b3", //Hamsteria
        "0x0ef9d39bbbed9c4983ddc4a1e189ee4938d837b3"  //CosmicHorrors
    ];

    const discounts = [
        66,
        66,
        66,
        66,
        66,
        66,
        66,
        66,
        66,
        50
    ];
    beforeEach(async function () {
        //reset network
          await network.provider.request({
            method: "hardhat_reset",
            params: [{
              forking: {
                jsonRpcUrl: "https://late-wild-fire.fantom.quiknode.pro/",
              }
            }]
          });
          //get signers
          [owner, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
          await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: ["0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13"]
          });
          await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: ["0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5"]
          });
          nonLGEself = await ethers.provider.getSigner("0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5");
          nonLGEselfAddress = await nonLGEself.getAddress();
          self = await ethers.provider.getSigner("0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13");
          selfAddress = await self.getAddress();
          ownerAddress = await owner.getAddress();

          const MockLGEContract = await hre.ethers.getContractFactory("MockLGE");
          const connectedMock = await MockLGEContract.deploy();
          await connectedMock.deployed();
          const mockLGEAddress = connectedMock.address;

          const CCContract = await hre.ethers.getContractFactory("BoilerplateERC721");
          const connected = await CCContract.deploy(
              "CCTEST", //name
              "", //symbol
              "initbasuri", //baseURI
              "0x111731A388743a75CF60CCA7b140C58e41D83635", //treasury address
              "0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c", //lpPair address
              "0x1740Eae421b6540fda3924bE59F549c00AB67575", //royalty Address
              "0x96662f375a9734654cB57BbFeb31Db9dD7784A7F", //elasticLGE address
              "0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", //wftm address
              5, //royalties percentage
              2000, //max supply
              5, //max mint amount
          );
          await connected.deployed();
          deployReceipt = await connected.deployTransaction.wait();
          console.log("Gas used to deploy: ", deployReceipt.gasUsed);
          testContractAddress = connected.address;
          console.log("Deployed to: ", connected.address);


    });
    describe("Deployment", function () {
      it("Premint should be completed", async function () {
        const CCContract = await hre.ethers.getContractFactory("BoilerplateERC721");
        const connected = await CCContract.attach(testContractAddress);
        const OathContract = await hre.ethers.getContractFactory("ERC20");
        const connectedOath = await OathContract.attach("0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6");
        const MingoesContract = await hre.ethers.getContractFactory("PinkFlamingoSocialClub");
        const connectedMingoes = await MingoesContract.attach("0xd761dB316b5b9C9C51F7f80127497Bc618e2B422");
        const BitshadowzContract = await hre.ethers.getContractFactory("contracts/ERC721.sol:ERC721");
        const connectedShadowz = await BitshadowzContract.attach("0xe92752C25111DB288665766aD8aDB624CCf91045");
        
        tx = await connected.addCurrency(acceptedCurrencies, prices, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
        await tx.wait();
        console.log("Added Currencies: " + acceptedCurrencies + " @ Prices: " + prices);
      
        tx = await connected.setDiscountCollections(collections, discounts, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
        await tx.wait();
        console.log("Added collections: " + collections + " @ Discounts: " + discounts); 

        tx = await connected.pausePublic(false, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
        await tx.wait();

        const status = await connected.publicPaused()
        console.log("Unpaused Public with status: ", status);
    
        let userBalance = await ethers.provider.getBalance(nonLGEselfAddress);
        console.log("User Balance: ", await ethers.utils.formatEther(userBalance));
        let discountedValue =  2 * 0.001 * 66 / 100; //This is how it is calculated in solidity
        let discoutnedValueString = discountedValue.toString();
        console.log("Discounted Value: ", discountedValue);
        expect(await connected.collectionsWithDiscount("0xd761dB316b5b9C9C51F7f80127497Bc618e2B422") > 0);
        expect(await connectedMingoes.balanceOf(nonLGEselfAddress) > 0);
        tx = await connected.connect(nonLGEself).mint("0x0000000000000000000000000000000000000000", 2, "0xd761dB316b5b9C9C51F7f80127497Bc618e2B422", {gasLimit: 1000000, value: ethers.utils.parseUnits(discoutnedValueString, 'ether')});
        await tx.wait();
        console.log(await connected.totalSupply());
        //console.log(tx);
        userBalance = await ethers.provider.getBalance(nonLGEselfAddress);
        let expectedFtmBalance = userBalance - discountedValue;
        let expectedFtmBalanceString = expectedFtmBalance.toString();
        console.log("Expected Balance of FTM after Mint: ", expectedFtmBalance);
        //expect(await userBalance).to.equal(expectedFtmBalanceString);
        console.log("User Balance After Mint: ", ethers.utils.formatEther(userBalance));
        
        console.log("Minted with FTM");

        const approvalTx = await connectedOath.connect(self).approve(testContractAddress, ethers.utils.parseUnits('1000', 'ether'));
        approvalTx.wait();
        //console.log(await connectedOath.allowance(selfAddress, testContractAddress));
        expect(await connectedOath.allowance(selfAddress, testContractAddress)).to.equal(ethers.utils.parseUnits('1000', 'ether'));
        console.log("Approved Oath to Mint");

        let oathBalance = await connectedOath.balanceOf(selfAddress);
        console.log("Oath Balance Before Mint: ", ethers.utils.formatEther(oathBalance));
        discountedValue =  2 * 0.001 * 64 / 100; //This is how it is calculated in solidity
        discoutnedValueString = discountedValue.toString();
        console.log("Discounted Price: ", discountedValue);
        expect(await connected.connect(self).collectionsWithDiscount("0xe92752C25111DB288665766aD8aDB624CCf91045") > 0);
        expect(await connectedShadowz.balanceOf(selfAddress));
        tx = await connected.connect(self).mint("0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6", 2, "0xe92752C25111DB288665766aD8aDB624CCf91045");
        await tx.wait();
        console.log(await connected.totalSupply());
        //console.log(tx);
        oathBalance = await connectedOath.balanceOf(selfAddress);
        let expectedOathBalance = oathBalance - discountedValue;
        console.log("Expected Oath Balance After Mint", expectedOathBalance);
        console.log("Oath Balance After Mint: ", ethers.utils.formatEther(oathBalance));
        console.log("Minted with Oath");

        for(i = 5; i < 2000; i++) {
          tx = await connected.mint("0x0000000000000000000000000000000000000000", 1, "0x0000000000000000000000000000000000000000", {gasLimit: 1000000, value: ethers.utils.parseUnits('0.001', 'ether')});
          await tx.wait();
          //console.log("Minted token: is %s, tokens minted", i );
          console.log(await connected.totalSupply());
        }

        tx = await connected.withdraw("0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83");
        await tx.wait();
        console.log("Withdrew all the tokens");
        });
      });

      /*describe("Test LGE Discounts", function () {
        it("Test many terms", async function () {
          const CCContract = await hre.ethers.getContractFactory("CursedCircusTest");
          const connected = await CCContract.attach(testContractAddress);
          const TestLGEContract = await hre.ethers.getContractAt("MockLGE");
          const connectedMockLGE = await TestLGEContract.attach(mockLGEAddress);

          termArray = [0, 86400, 864000, 1296000, 4320000, 8640000, 12960000, 21600000, 31536000, 126144000]

          tx = await connected.addCurrency(acceptedCurrencies, prices, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
          await tx.wait();
          console.log("Added Currencies: " + acceptedCurrencies + " @ Prices: " + prices);
        
          tx = await connected.setDiscountCollections(collections, discounts, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
          await tx.wait();
          console.log("Added collections: " + collections + " @ Discounts: " + discounts); 

          tx = await connected.pausePublic(false, {gasPrice: ethers.utils.parseUnits('6000', 'gwei')});
          await tx.wait();

          const status = await connected.publicPaused()
          console.log("Unpaused Public with status: ", status);

          for(i = 0; i < 10; i++) {
            await connectedMockLGE.setTerms(termArray[i]);
            let discountForMint = (35 + (sqrt(termArray[i])/800));
            console.log(discountForMint);
            if(discountForMint < 35) {
              discountForMint = 35;
            }
            else if(discountForMint > 50) {
              discountForMint = 50;
            }
            let costOfNFT = 1 * discountForMint;
            let costOfNFTString = costOfNFT.toString();
            tx = await connected.mint("0x0000000000000000000000000000000000000000", 1, "0x0000000000000000000000000000000000000000", {gasLimit: 1000000, value: ethers.utils.parseUnits(costOfNFTString, 'ether')});
            await tx.wait();
            tokenId = totalSupply();
            console.log("Minted Token Id: %s at price %s", tokenId, costOfNFTString);
          }
        });
      });*/
});