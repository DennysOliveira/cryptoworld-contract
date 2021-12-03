const hre = require("hardhat");

async function main() {
    const Token = await hre.ethers.getContractFactory("DarkIce");
    const TokenContract = await Token.deploy();

    await TokenContract.deployed();

    console.log("Contract deployed to address: " + TokenContract.address);
    console.log("Deployment Transaction hash:");
    console.log(TokenContract.deployTransaction.hash);
}

main()
    .then(() => { process.exit(0) })
    .catch(err => {
        console.log(err);
        process.exit(1);
    })
