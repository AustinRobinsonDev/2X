require('dotenv').config();
require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

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
  solidity: "0.8.3",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337 // SOLVES ISSUE WITH METAMASK
    },
    ropsten: {
      url: `${process.env.INFURA_ROPSTEN_NETWORK}`,
      accounts: [`${process.env.PRIVATE_KEY}`] // Create a .env file in the root directory. Add your PRIVATE_KEY
    },
    kovan: {
      url: `${process.env.INFURA_KOVAN_NETWORK}`,
      accounts: [`${process.env.PRIVATE_KEY}`] // Create a .env file in the root directory. Add your PRIVATE_KEY
    },
  }
};

