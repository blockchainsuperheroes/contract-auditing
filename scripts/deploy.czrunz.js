const hre = require("hardhat");

const run = async () => {

  const [addr1] = await hre.ethers.getSigners();
  const CZRUNZ = await ethers.getContractFactory("PEN");
  this.CZRUNZ = await CZRUNZ.connect(addr1).deploy();

  await new Promise(r => setTimeout(r, 60000));

  try {
    await hre.run("verify:verify", {
      address: this.cToken.target,
      contract: `contracts/PEN.sol:PEN`
    });
  } catch (err) {

  }
}
run();