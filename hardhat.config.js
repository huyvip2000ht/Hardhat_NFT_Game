require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")


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
require('dotenv').config({ path: __dirname + '/.env' })
const { MAINNET_RPC_URL, FORKING_BLOCK_NUMBER, KOVAN_RPC_URL, RINKEBY_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;


module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // If you want to do some forking set `enabled` to true
      forking: {
        url: MAINNET_RPC_URL,
        blockNumber: FORKING_BLOCK_NUMBER,
        enabled: false,
      },
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    kovan: {
      url: KOVAN_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      saveDeployments: true,
      chainId: 42,
    },
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      saveDeployments: true,
      chainId: 4,
    },

  },
  etherscan: {
    apiKey: {
      rinkeby: ETHERSCAN_API_KEY,
      kovan: ETHERSCAN_API_KEY,
    },
  },
  solidity: "0.8.4",
};
