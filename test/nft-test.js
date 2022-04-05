const { expect } = require("chai");
const { ethers } = require("hardhat");


describe('MooMooNFT', async () => {

    beforeEach(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();
        let MooMooNFT = await ethers.getContractFactory("MooMooNFT");
        mooMooNFT = await MooMooNFT.deploy();   //dont put let or const
        await mooMooNFT.deployed();
    });


    it("Should mint and breed", async () => {
        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await expect(mooMooNFT.tokenCounter()).to.equal(1);
        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await expect(mooMooNFT.tokenCounter()).to.equal(2);
        await mooMooNFT.connect(addr1).breed(0, 1);
        await expect(mooMooNFT.tokenCounter()).to.equal(3);

    });
    it.only("Should not breed because not the owner of moomoo", async () => {

        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await mooMooNFT.connect(owner).mintOrigin(addr2.address);

        await expect(mooMooNFT.connect(addr2).breed(0, 1)).to.be.revertedWith("Not owner of this MooMoo");

    });
    it("Should fight", async () => {
        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await mooMooNFT.connect(owner).mintOrigin(addr2.address);
        let fightTotal = 50;

        for (i = 0; i < fightTotal; i++) {
            await mooMooNFT.connect(addr1).fight(0, 1);
        };
        let stat0 = await mooMooNFT.getStats(0);
        let stat1 = await mooMooNFT.getStats(1);
        console.log(stat0.winCount);
        console.log(stat0.lossCount);
        console.log(stat0.winCount.toNumber() + stat0.lossCount.toNumber());
        expect(stat0.winCount.toNumber() + stat0.lossCount.toNumber()).to.equal(fightTotal);// cast from bignumber
        expect(stat1.winCount.toNumber() + stat1.lossCount.toNumber()).to.equal(fightTotal);// cast from bignumber
        expect(stat0.winCount).to.equal(stat1.lossCount);
        expect(stat0.lossCount).to.equal(stat1.winCount);
    });
    it.only("Should not fight because not the owner", async () => {
        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await mooMooNFT.connect(owner).mintOrigin(addr2.address);
        await expect(mooMooNFT.connect(addr1).fight(1, 0)).to.be.revertedWith("Not owner of this MooMoo");
    });

});


