require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config({path:__dirname+'/.env'});

const { APIKEY, PKEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs:200
          }
        }
      },
    ]
  },
  mocha: {
    timeout: 60000
  },
  defaultNetwork: "ftmtest",
  networks: {
    hardhat: {},
    ftmmain: {
      url: "https://rpcapi-tracing.fantom.network",
      chainId: 250,
      accounts: [`0x${PKEY}`]
    },
    ftmtest: {
      url: "https://xapi.testnet.fantom.network/lachesis",
      chainId: 0xfa2,
      accounts: [`0x${PKEY}`]
    }
  },
  etherscan: {
    apiKey: {
      FantomMain: [{APIKEY}]
    },
    customChains: [
      {
        network: "FantomMain",
        chainId: 250,
        urls: {
          apiURL: "https://api.ftmscan.com/",
          browserURL: "https://ftmscan.com/"
        }
      }
    ]
  }
};
