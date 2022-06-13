const main = async () => {
  console.log(
    "Welcome to the local deployer! We're going to deploy to the local testnet"
  );
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const domainContractFactory = await hre.ethers.getContractFactory("Domains");
  const domainContract = await domainContractFactory.deploy("bit"); // like this all our domains will have the .ninja top-level domain
  await domainContract.deployed();
  console.log("Contract deployed to:", domainContract.address);
  console.log("Contract deployed by:", owner.address);

  // We're passing in a second variable - value. This is the moneyyyyyyyyyy
  let txn = await domainContract.register("chubbycat", {
    value: hre.ethers.utils.parseEther("0.1"),
  });
  let txn2 = await domainContract.register("happycat", {
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await txn.wait();
  await txn2.wait();

  const address = await domainContract.getAddress("chubbycat");
  const address2 = await domainContract.getAddress("happycat");
  console.log("Owner of domain chubbycat:", address);
  console.log("Owner of domain happycat:", address2);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

  const domain = await domainContract.getDomain();
  console.log("Domain:", domain);

  let allNames = await domainContract.getDomains();
  console.log("All names of owner:", allNames);

  await domainContract.setDomain("sadcat", "happycat");
  allNames = await domainContract.getDomains();
  console.log("All names after setDomain:", allNames);

  // // Quick! Grab the funds from the contract! (as superCoder)
  // try {
  //   txn = await domainContract.connect(randomPerson).withdraw();
  //   await txn.wait();
  // } catch (error) {
  //   console.log("Could not rob contract");
  // }

  // // Let's look in their wallet so we can compare later
  // let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
  // console.log(
  //   "Balance of owner before withdrawal:",
  //   hre.ethers.utils.formatEther(ownerBalance)
  // );

  // // Oops, looks like the owner is saving their money!
  // txn = await domainContract.connect(owner).withdraw();
  // await txn.wait();

  // // Fetch balance of contract & owner
  // const contractBalance = await hre.ethers.provider.getBalance(
  //   domainContract.address
  // );
  // ownerBalance = await hre.ethers.provider.getBalance(owner.address);

  // console.log(
  //   "Contract balance after withdrawal:",
  //   hre.ethers.utils.formatEther(contractBalance)
  // );
  // console.log(
  //   "Balance of owner after withdrawal:",
  //   hre.ethers.utils.formatEther(ownerBalance)
  // );
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

module.exports.tags = ["all", "local"];
