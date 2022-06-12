const main = async () => {
  console.log(
    "Welcome to the staging deployer! We're going to deploy to the Mumbai testnet"
  );
  const domainContractFactory = await hre.ethers.getContractFactory("Domains");
  const domainContract = await domainContractFactory.deploy("bit");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

module.exports.default = runMain;

module.exports.tags = ["all", "staging"];
