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
        initSupply = 100000;

        await grassToken.connect(owner).approve(mooMooNFT.address, maxUnit256);// approve owner
        await grassToken.connect(owner).approve(misteryBox.address, maxUnit256);

        await grassToken.connect(owner).transfer(addr1.address, initSupply);      // chuyển token từ owner sang addr1  
        await grassToken.connect(addr1).approve(mooMooNFT.address, maxUnit256);      // approve addr1
        await grassToken.connect(addr1).approve(misteryBox.address, maxUnit256);

        await grassToken.connect(owner).transfer(addr2.address, initSupply);      // chuyển token từ owner sang addr2  
        await grassToken.connect(addr2).approve(mooMooNFT.address, maxUnit256);      // approve addr2
        await grassToken.connect(addr2).approve(misteryBox.address, maxUnit256);


    });
    it("Should mint", async () => {

        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        expect(await mooMooNFT.tokenCounter()).to.equal(1);


    });

    it("Should mint and breed", async () => {

        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);

        await mooMooNFT.connect(addr1).breed(0, 1);
        expect(await mooMooNFT.tokenCounter()).to.equal(3);

    });
    it("Should breed with stat from parents", async () => {

        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr1).breed(0, 1);

        let stat0 = await mooMooNFT.getStats(0);    //parent
        let stat1 = await mooMooNFT.getStats(1);    //parent
        let stat2 = await mooMooNFT.getStats(2);    //child

        console.log(stat2);

        expect(stat2.eye == stat0.eye || stat2.eye == stat1.eye).to.be.true;
        expect(stat2.ear == stat0.ear || stat2.ear == stat1.ear).to.be.true;
        expect(stat2.mouth == stat0.mouth || stat2.mouth == stat1.mouth).to.be.true;
        expect(stat2.tail == stat0.tail || stat2.tail == stat1.tail).to.be.true;

        expect(stat2.parent1Id == 0 && stat2.parent2Id == 1).to.be.true;
    });
    it("Should not breed because not the owner of moomoo", async () => {

        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr2).mintOrigin(addr2.address);
        await expect(mooMooNFT.connect(addr1).breed(1, 0)).to.be.revertedWith("MooMooNFT: Not owner of this MooMoo");

    });
    it("Should fight", async () => {
        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr2).mintOrigin(addr2.address);
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
        await mooMooNFT.connect(addr1).mintOrigin(addr1.address);
        await mooMooNFT.connect(addr2).mintOrigin(addr2.address);
        await expect(mooMooNFT.connect(addr1).fight(1, 0)).to.be.revertedWith("MooMooNFT: Not owner of this MooMoo");
    });

    it.only("Should buy misteryBox", async () => {
        let balance = initSupply;

        await misteryBox.connect(addr1).buyMisteryBox(0);   //bronze
        expect(await misteryBox.balanceOf(addr1.address)).to.equal(1);
        expect(await misteryBox.getBoxType(0)).to.equal(0);

        balance = balance - await misteryBox.getBoxPrice(0);
        expect(await grassToken.balanceOf(addr1.address)).to.equal(balance);
        

        await misteryBox.connect(addr1).buyMisteryBox(1);   //silver
        expect(await misteryBox.balanceOf(addr1.address)).to.equal(2);
        expect(await misteryBox.getBoxType(1)).to.equal(1);

        balance = balance - await misteryBox.getBoxPrice(1);
        expect(await grassToken.balanceOf(addr1.address)).to.equal(balance);

        await misteryBox.connect(addr1).buyMisteryBox(2);   //gold
        expect(await misteryBox.balanceOf(addr1.address)).to.equal(3);
        expect(await misteryBox.getBoxType(2)).to.equal(2);

        balance = balance - await misteryBox.getBoxPrice(2);
        expect(await grassToken.balanceOf(addr1.address)).to.equal(balance);
    });
    it.only("Should open misteryBox", async () => {

        await misteryBox.connect(addr1).buyMisteryBox(2);   //bronze

        await misteryBox.connect(addr1).openMisteryBox(0);
        expect(await misteryBox.balanceOf(addr1.address)).to.equal(0);
        expect(await mooMooNFT.balanceOf(addr1.address)).to.equal(1);
        
    });
});


