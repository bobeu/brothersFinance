var SafeBrosToken = artifacts.require("./SafeBrosToken.sol");

module.exports = async function(deployer) {
  deployer.deploy(SafeBrosToken, 299999999);
  // await result.deployed();
};