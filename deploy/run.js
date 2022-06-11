const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const domainContractFactory = await hre.ethers.getContractFactory("Domains");
  const domainContract = await domainContractFactory.deploy();
  await domainContract.deployed();
  console.log("Contract deployed to:", domainContract.address);
  console.log("Contract deployed by:", owner.address);

  const txn = await domainContract.register("doom");
  await txn.wait();

  const domainOwner = await domainContract.getAddress("doom");
  console.log("Owner of domain:", domainOwner);

  console.log("Random person is", randomPerson.address);
  // try to get an error
  let txnError = await domainContract
    .connect(randomPerson)
    .setRecords("Hahaha, this is now my domain!");
  await txnError.wait();
  const domain = await domainContract.connect(owner).getDomain();
  console.log("Domain:", domain);
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
