var PeerBrothers = artifacts.require("./PeerBrothers.sol");
// var web3 = artifacts.require("Web3");

// async () => accounts = await web3.eth.getAccounts();
module.exports = function(deployer) {
  deployer.deploy(PeerBrothers, 299999999, '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56');
};

// 299999999, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
// {gas: 9612388, gasLimit: 9612388, from: "0x236CF87220Fef3219104b5fF624d40CB880D6b9B"}



// deploy_ether.js

// // Right click on the script name and hit "Run" to execute
// (async () => {
//   try {
//       console.log('Running deployWithEthers script...')
  
//       const contractName = 'Storage' // Change this for other contract
//       const constructorArgs = []    // Put constructor args (if any) here for your contract

//       // Note that the script needs the ABI which is generated from the compilation artifact.
//       // Make sure contract is compiled and artifacts are generated
//       const artifactsPath = `browser/contracts/artifacts/${contractName}.json` // Change this for different path
  
//       const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
//       // 'web3Provider' is a remix global variable object
//       const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
  
//       let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
  
//       let contract = await factory.deploy(...constructorArgs);
  
//       console.log('Contract Address: ', contract.address);
  
//       // The contract is NOT deployed yet; we must wait until it is mined
//       await contract.deployed()
//       console.log('Deployment successful.')
//   } catch (e) {
//       console.log(e.message)
//   }
// })()


// deploy_web3

// Right click on the script name and hit "Run" to execute
// (async () => {
//   try {
//       console.log('Running deployWithWeb3 script...')
      
//       const contractName = 'PeerBrothers' // Change this for other contract
//       const constructorArgs = [299999999, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56]    // Put constructor args (if any) here for your contract
  
//       // Note that the script needs the ABI which is generated from the compilation artifact.
//       // Make sure contract is compiled and artifacts are generated
//       const artifactsPath = `browser/contracts/artifacts/${contractName}.json` // Change this for different path

//       const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
//       const accounts = await web3.eth.getAccounts()
  
//       let contract = new web3.eth.Contract(metadata.abi)
  
//       contract = contract.deploy({
//           data: metadata.data.bytecode.object,
//           arguments: constructorArgs
//       })
  
//       const newContractInstance = await contract.send({
//           from: accounts[0],
//           gas: 1500000,
//           gasPrice: '30000000000'
//       })
//       console.log('Contract deployed at address: ', newContractInstance.options.address)
//   } catch (e) {
//       console.log(e.message)
//   }
// })()