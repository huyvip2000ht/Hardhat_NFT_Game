const { expect } = require("chai");
const { ethers } = require("hardhat");
const { networkConfig, 
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS, } = require("../helper-hardhat-config")



const chainId = network.config.chainId

let subscriptionId = process.env.VRF_SUBSCRIPTION_ID
let vrfCoordinatorAddress = networkConfig[chainId]["vrfCoordinator"]
let linkTokenAddress = networkConfig[chainId]["linkToken"]
const keyHash = networkConfig[chainId]["keyHash"]
const args = [subscriptionId, vrfCoordinatorAddress, linkTokenAddress, keyHash]   // cần 4 biến này để đủ biến trong constructor



describe('MooMooNFT', async () => {
    before(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();

    });
    beforeEach(async () => {

        let RandomNumberConsumerV2 = await ethers.getContractFactory("RandomNumberConsumerV2");
        randomNumberConsumerV2 = await RandomNumberConsumerV2.deploy(subscriptionId, vrfCoordinatorAddress, linkTokenAddress, keyHash);   //dont put let or const
        await randomNumberConsumerV2.deployed();
    });

    // it("Should get random number", async () => {
    //     await randomNumberConsumerV2.requestRandomWords();
    //     await sleep(5 * 60 * 1000);
    //     console.log(await randomNumberConsumerV2.s_randomWords);
        
    // });

});


