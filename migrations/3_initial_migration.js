var SafeBrosToken = artifacts.require("./SafeBrosToken.sol");

module.exports = async function(deployer) {
  const result = await deployer.deploy(SafeBrosToken, 299999999, '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56');
  await result.deployed();
};