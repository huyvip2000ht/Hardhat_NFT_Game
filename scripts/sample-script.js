// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { verify } = require("../helper-functions")
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");
  // await greeter.deployed();
  // console.log("Greeter deployed to:", greeter.address);


  const GrassToken = await hre.ethers.getContractFactory("GrassToken");
  const grassToken = await GrassToken.deploy();
  await grassToken.deployed();
  console.log("Grass Contract:" , grassToken.address);

  const MooMooNFT = await hre.ethers.getContractFactory("MooMooNFT");
  const mooMooNFT = await MooMooNFT.deploy(grassToken.address);
  await mooMooNFT.deployed();

  console.log("MooMooNFT:",mooMooNFT.address);



  //verify
  // await mooMooNFT.deployTransaction.wait(6)      // nếu ko có dòng này, thì contract chưa deploy lên mà đã chạy verify rồi!!!
  // await verify(mooMooNFT.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
