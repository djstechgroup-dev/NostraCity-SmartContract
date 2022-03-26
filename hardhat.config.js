require("@nomiclabs/hardhat-waffle");
require('hardhat-contract-sizer');
let secret = require('./secrets.json');

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
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: false,
      runs: 10
    }
  },
  networks: {
    localhost: {
      url: secret.url,
      gasPrice: 20000000000,
      accounts: [secret.key]
    },
    hardhat: {
      gasPrice: 50000000000
    },
    mainnet: {
      url: secret.url,
      gasPrice: 20000000000,
      accounts: [secret.key]
    },
    fuji: {
      url: secret.url,
      gasPrice: 40000000000,
      chainId: 43113,
      accounts: [secret.key]
    }
  }

};
