// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { networkConfig, developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS, } = require("../helper-hardhat-config")
const { verify } = require("../helper-functions")

async function main() {
    //const { deployer } = await getNamedAccounts.ethers
    const chainId = network.config.chainId

    let subscriptionId = process.env.VRF_SUBSCRIPTION_ID
    let vrfCoordinatorAddress = networkConfig[chainId]["vrfCoordinator"]
    let linkTokenAddress = networkConfig[chainId]["linkToken"]
    const keyHash = networkConfig[chainId]["keyHash"]
    const args = [subscriptionId, vrfCoordinatorAddress, linkTokenAddress, keyHash]   // cần 4 biến này để đủ biến trong constructor

    console.log("Deploying...")
    const RandomNumberConsumerV2 = await hre.ethers.getContractFactory("RandomNumberConsumerV2");
    const randomNumberConsumerV2 = await RandomNumberConsumerV2.deploy(subscriptionId, vrfCoordinatorAddress, linkTokenAddress, keyHash);
    await randomNumberConsumerV2.deployTransaction.wait(6)      // nếu ko có dòng này, thì contract chưa deploy lên mà đã chạy verify rồi!!!


    console.log(randomNumberConsumerV2.address);
    console.log("Verifying...")
    await verify(randomNumberConsumerV2.address, args)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
