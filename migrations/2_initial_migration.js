var SafeBEP20 = artifacts.require("./SafeBEP20.sol");

module.exports = async function(deployer) {
  deployer.deploy(SafeBEP20, 999999999);
  // await result.deployed();
};