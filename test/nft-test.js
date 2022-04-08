const { expect } = require("chai");
const { ethers } = require("hardhat");
const { ContractFunctionVisibility } = require("hardhat/internal/hardhat-network/stack-traces/model");


describe('MooMooNFT', async () => {
    before(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();

    });
    beforeEach(async () => {
        const GrassToken = await ethers.getContractFactory("GrassToken");
        grassToken = await GrassToken.deploy();
        await grassToken.deployed();

        let MooMooNFT = await ethers.getContractFactory("MooMooNFT");
        mooMooNFT = await MooMooNFT.deploy(grassToken.address);   //dont put let or const
        await mooMooNFT.deployed();

        let MisteryBox = await ethers.getContractFactory("MisteryBox");
        misteryBox = await MisteryBox.deploy(mooMooNFT.address, grassToken.address);
        await misteryBox.deployed();


        let maxUnit256 = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

        await grassToken.connect(owner).approve(mooMooNFT.address, maxUnit256);// approve owner
        await grassToken.connect(owner).approve(misteryBox.address, maxUnit256);

        await grassToken.connect(owner).transfer(addr1.address, 100000);      // chuyển token từ owner sang addr1  
        await grassToken.connect(addr1).approve(mooMooNFT.address, maxUnit256);      // approve addr1
        await grassToken.connect(addr1).approve(misteryBox.address, maxUnit256);

        await grassToken.connect(owner).transfer(addr2.address, 100000);      // chuyển token từ owner sang addr2  
        await grassToken.connect(addr2).approve(mooMooNFT.address, maxUnit256);      // approve addr2
        await grassToken.connect(addr2).approve(misteryBox.address, maxUnit256);


    });


    it("Should mint and breed", async () => {


        console.log("addr1 have", await grassToken.balanceOf(addr1.address));
        console.log("MooMooNFT address:", await mooMooNFT.address);
        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);           // transferFrom add1 -> mooMooNFT

        //TODO: bài toán ở đây là muốn approve addr1 -> owner       


        expect(await mooMooNFT.tokenCounter()).to.equal(1);

        console.log("Allowance:", await grassToken.allowance(addr1.address, mooMooNFT.address));


        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        expect(await mooMooNFT.tokenCounter()).to.equal(2);

        await mooMooNFT.connect(addr1).breed(0, 1);
        expect(await mooMooNFT.tokenCounter()).to.equal(3);

    });
    it("Should not breed because not the owner of moomoo", async () => {

        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await mooMooNFT.connect(owner).mintOrigin(addr2.address);
        //await mooMooNFT.connect(addr1).breed(1, 0);
        await expect(mooMooNFT.connect(addr1).breed(1, 0)).to.be.revertedWith("Not owner of this MooMoo");

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
    it("Should not fight because not the owner", async () => {
        await mooMooNFT.connect(owner).mintOrigin(addr1.address);
        await mooMooNFT.connect(owner).mintOrigin(addr2.address);
        await expect(mooMooNFT.connect(addr1).fight(1, 0)).to.be.revertedWith("Not owner of this MooMoo");
    });

    it.only("Should buy misteryBox", async () => {
        await misteryBox.connect(owner).buyMisteryBox(0);   //bronze
        expect(await misteryBox.balanceOf(owner.address)).to.equal(1);
    });
});


