// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  /* Here we will define all variables that may be needed *|
  |* run all of the different test functions              */

  const testArray = [
    '0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13'
  ];

  const acceptedCurrencies = [
    "0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83",  //WFTM
    "0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6"   //OATH
  ];

  const prices = [
    ethers.utils.parseUnits('1', 'ether'), //WFTM
    ethers.utils.parseUnits('1', 'ether')  //USDC
  ];

  const ConstructorArgs = {
    'name': "CurseCircus",
    'symbol': "CC",
    'initBaseURI': "",
    'lpPair': "0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c",
    'royaltiesAddress': "0x1740Eae421b6540fda3924bE59F549c00AB67575",
    'royaltiesPercentage': 5,
    'maxSupply': 2000,
    'maxMintAmount': 5
  }

  /* From here we will define all functions. These functions will be *|
  |* used to test different cases of the NFT mint                    */

  async function deployNFTContract() {
    try {
      let CircusContract = await hre.ethers.getContractFactory(ConstructorArgs.name);
      let deployedCircusContract = await CircusContract.deploy(
        ConstructorArgs.name,
        ConstructorArgs.symbol,
        ConstructorArgs.initBaseURI,
        ConstructorArgs.lpPair,
        ConstructorArgs.royaltiesAddress,
        ConstructorArgs.royaltiesPercentage,
        ConstructorArgs.maxSupply,
        ConstructorArgs.maxMintAmount
      );
      await deployedCircusContract.deployed();
      console.log("NFT Contract Deployed To: ", deployedCircusContract.address);
      return deployedCircusContract.address;
    } catch(error) {
      console.log("Error Deploying CursedCircus Contract");
      console.log(error);
    }
  }

  async function deployMockLGE() {
    try {
      let MockLGE = await hre.ethers.getContractFactory("MockLGE");
      let deployedMockLGE = await MockLGE.deploy();
      await deployedMockLGE.deployed();
      console.log("MockLGE Deployed To: ", deployedMockLGE.address);
      return deployedMockLGE.address;  
    } catch(error) {
      console.log("Error Deploying MockLGE");
      console.log(error);
    }
  }

  async function setTermsForTesting(vestingSecondsToAdd, AddressLGE) {
    try {
      let MockLGE = await hre.ethers.getContractFactory("MockLGE");
      let deployedMockLGE = await MockLGE.attach(AddressLGE);
      let tx = await deployedMockLGE.setTerms(vestingSecondsToAdd);
      await tx.wait();
      console.log("Changed Vesting Term To: " + vestingSecondsToAdd + " seconds.");
    } catch(error) {
      console.log("Error Setting Terms");
      console.log(error);
    }
  }

  async function addCurrency(AddressCC) {
    try {
      let CircusContract = await hre.ethers.getContractFactory("CursedCircus");
      let deployedCircusContract = await CircusContract.attach(AddressCC);
      let tx = await deployedCircusContract.addCurrency(acceptedCurrencies, prices);
      await tx.wait();
      console.log("Added Currencies: ", acceptedCurrencies);
      console.log("Added Prices: ", prices);
    } catch(error) {
      console.log("Error Adding Currencies");
      console.log(error);
    }
  }

  async function callPausePublic(state, AddressCC) {
    try {
      let CircusContract = await hre.ethers.getContractFactory("CursedCircus");
      let deployedCircusContract = await CircusContract.attach(AddressCC);
      let tx = await deployedCircusContract.pausePublic(state);
      await tx.wait();
      console.log("Successfully Called Pause Public With State: ", state);
    } catch(error) {
      console.log("Error Calling Public Pause");
      console.log(error);
    }
  }

  /* Here is where we will call all of the functions *|
  |* to actually run the test simulation.            */
  //Only need to run this the first time. If tests fail
  //then you may need to just run the attach command and
  //comment out this try/catch
  try {
    AddressCC = await deployNFTContract();
    AddressLGE = await deployMockLGE();
  } catch(error) {
    console.log(error);
  }



  //const connected = await PopContract.attach("0xF7d7169d41242f9F24759Bb55f0d7Ff4de5bc796");
  //const ERC20Contract = await hre.ethers.getContractFactory("ERC20");
  //const erc20Connected = await ERC20Contract.attach("0xFb24bC6E1cE0e9f6ceb633FeF2127c2826d8820E");
  //await erc20Connected.approve("0x6C6BAFDf153Db9eC245f957Bc58794f03D65ac80", ethers.utils.parseUnits('1', 'ether'));*/

  try {
    await connected.addCurrency(acceptedCurrencies, prices, {gasPrice: ethers.utils.parseUnits('2500', 'gwei')});
    console.log("Added Currencies");
  
    /*const status = await connected.pausePublic(false, {gasPrice: ethers.utils.parseUnits('2500', 'gwei')});
    console.log("Unpaused Public");
    await connected.mint(1, {gasLimit: 300000, value: ethers.utils.parseUnits('1', 'ether')});
    console.log("minted");
    await connected.withdraw("0x0000000000000000000000000000000000000000", {gasLimit: 300000});
    console.log("withdrawn");*/
  } catch(error) {
    console.log(error);
  }
  //WFTM
  /*try {
    const tx1 = await connected.mint("0x0000000000000000000000000000000000000000", 1, {gasLimit: 1000000, value: ethers.utils.parseUnits('1', 'ether')});
  } catch(error) {
    console.log(error);
  }*/
  /*try {
    for(i = 0; i < 38; i++) {
      await connected.mint("0xFb24bC6E1cE0e9f6ceb633FeF2127c2826d8820E", 1, {gasLimit: 1000000/*, value: ethers.utils.parseUnits('1', 'ether')*//*});
    }
  } catch(error) {
    console.log(error);
  }*/
    //console.log(tx2);
  
  //await connected.transferOwnership("0x7D13CD3dCC930BE7fBF1358FaC2617105869DbEc");*/
 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});

  /*

  // We require the Hardhat Runtime Environment explicitly here. This is optional
  // but useful for running the script in a standalone fashion through `node <script>`.
  //
  // When running the script with `npx hardhat run <script>` you'll find the Hardhat
  // Runtime Environment's members available in the global scope.
  const { BigNumber } = require("@ethersproject/bignumber");
  const hre = require("hardhat");

  async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    let wei = ethers.utils.parseEther("1000")
    let weiString = wei.toString()
    console.log(weiString)
    const SlurpToken = await hre.ethers.getContractFactory("FKSLURPDEV");
    const slurp = await SlurpToken.deploy("FKSLURPDEV", "SLURP", wei, "0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5");

    await slurp.deployed();

    console.log("Contract deployed to:", slurp.address);
  }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

  */