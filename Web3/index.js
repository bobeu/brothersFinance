const Web3 = require('web3');

const web3 = new Web3('http://127.0.0.1:8545');

web3.eth.getAccounts()
.then(console.log);

web3.eth.getBlockNumber()
.then(console.log);

web3.eth.getBalance('0x0fBCd8695D212Db87FEa1b780380581e4F2F026E')
.then(console.log);