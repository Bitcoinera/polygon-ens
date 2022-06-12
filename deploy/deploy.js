const main = async () => {
  console.log(
    "Welcome to the staging deployer! We're going to deploy to the Mumbai testnet"
  );
  const domainContractFactory = await hre.ethers.getContractFactory("Domains");
  const domainContract = await domainContractFactory.deploy("bit");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  let txn = await domainContract.register("chubbycat", {
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await txn.wait();
  console.log("Minted domain chubbycat.bit");

  const address = await domainContract.getAddress("chubbycat");
  console.log("Owner of domain chubbycat:", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

  const domain = await domainContract.getDomain();
  console.log("Domain:", domain);

  const domainDetails = await domainContract.getDomainDetails();
  console.log("Domain details:", domainDetails);
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
