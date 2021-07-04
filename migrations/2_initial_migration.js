var SafeBrosToken = artifacts.require("./SafeBrosToken.sol");

module.exports = async function(deployer) {
  deployer.deploy(SafeBrosToken, 999999999);
  // await result.deployed();
};