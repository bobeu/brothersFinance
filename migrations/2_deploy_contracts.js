var SimpleStorage = artifacts.require("./SimpleStorage.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
};






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
      
//       const contractName = 'Storage' // Change this for other contract
//       const constructorArgs = []    // Put constructor args (if any) here for your contract
  
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