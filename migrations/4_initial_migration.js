const Airdrop = artifacts.require("./Airdrop.sol");

module.exports = function (deployer) {
    deployer.deploy(Airdrop, '0x4AEE5696b30a200f9693DDc05BEAa8FBEC1485Df');
};