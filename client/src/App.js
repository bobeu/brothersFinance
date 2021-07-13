import "bootstrap/dist/css/bootstrap.min.css";

import React from 'react';
import HomePage from "./components/HomePage";
import Transfer from "./components/Transfer";
import TokenPage from "./components/TokenPage";
import NotFoundPage from "./components/NotFoundPage";
import Header from "./components/Common/Header";
import { Route, Switch, Redirect } from "react-router-dom";
import MarkUpTokenInfo from "./components/MarkUpTokenInfo";
import TextInput from "./components/Common/TextInput";

import "./App.css";

// import { Card } from '@material-ui/core/Card';
// import { CardActions } from "@material-ui/core/CardActions";
// import { CardContent } from "@material-ui/core/CardContent";
// import { CardMedia } from "@material-ui/core/CardMedia";
// import { Typography } from "@material-ui/core/Typography";
// import { Button } from "@material-ui/core/Button";
// // import { Grid } from "@material-ui/core";
// import { Icon } from "@material-ui/core/Icon";

function App() {
  
  return (
    <div className="container-fluid">
      <Header />
      <Switch>
        <Route path="/" exact component={HomePage}/>
        <Route path="/Transfer" component={TextInput}/>
        {/* <Route path="/markUp" component={MarkUpTokenInfo}/> */}
        <Route path="/Token" component={TokenPage}/>
        <Redirect from="/about-page" to="/"/>
        <Route path="/" component={NotFoundPage}/>
      </Switch>
    </div>
  );
}

export default App;



// function getPage() {
//   const route = window.location.pathname;
//   if(route === "/About") return <AboutPage />;
//   else if(route === "/Token") return <TokenPage />;
//   return <HomePage />;
// }

// package.json edit
// {
//   "name": "client",
//   "version": "0.1.0",
//   "private": true,
//   "dependencies": {
//     "bootstrap": "^4.3.1",
//     "flux": "^4.0.1",
//     "react": "^18.0.0-alpha-ed6c091fe-20210701",
//     "react-dom": "^18.0.0-alpha-ed6c091fe-20210701",
//     "react-router-dom": "^5.0.0",
//     "react-scripts": "3.2.0",
//     "web3": "1.2.2"






















// const PeerBrothers = require('./contracts/PeerBrothers.json');
// const Web3 = require('web3');

// // example = async(accounts, contract) => {
// //     await contract.methods.getCurrentTimestamp().call({from: accounts[0]});
// // }

// Mount = async() => {
//     const web3 = await new Web3('http://127.0.0.1:8545');
//     const accounts = await web3.eth.getAccounts();
//     console.log(accounts);
//     const networkId = await web3.eth.net.getId();
//     const deployedNetwork = PeerBrothers.networks[networkId];
//     // const address = deployedNetwork.address;
//     const instance = new web3.eth.Contract(
//         PeerBrothers.abi,
//         deployedNetwork && deployedNetwork.address
//     )
//     // console.log(deployedNetwork.address);
//     const x = 57;
//     const y = web3.utils.toWei(x.toString(), 'microether');
//     console.log(y);
//     const z = await web3.utils.fromWei(y, 'ether');
//     console.log('Z:', z);
//     const bn = await web3.utils.toBN(y);

//     const asc = 'Hello World';
//     const hex = web3.utils.asciiToHex(asc);
//     console.log(hex);
//     const as = await web3.utils.hexToAscii(hex);
//     console.log(as);

//     const num = 445;
//     const nth = web3.utils.numberToHex(num)
//     console.log(nth)

//     console.log(web3.utils.hexToNumber(nth))

//     const hash = web3.utils.sha3('takesInString');
//     const fromNum = web3.utils.sha3(num.toString());
//     console.log('hash:', hash,'\n', 'frmNum:', fromNum)
//     // console.log(instance);
//     // example(accounts, inbstance);
// }

// Mount();

// WEB3 FUNCTIONS
// web3.eth.sendTransaction
// example:
        // web3.eth.sendTransaction({from: '0x123...', data: '0x432...'})
        // .once('sending', function(payload){ ... })
        // .once('sent', function(payload){ ... })
        // .once('transactionHash', function(hash){ ... })
        // .once('receipt', function(receipt){ ... })
        // .on('confirmation', function(confNumber, receipt, latestBlockHash){ ... })
        // .on('error', function(error){ ... })
        // .then(function(receipt){
        //     // will be fired once the receipt is mined
        // });

// web3.eth.Contract 
// Web3.utils
// web3.utils
// web3.version
// web3.setProvider(myProvider)
// web3.eth.setProvider(myProvider)
// web3.shh.setProvider(myProvider)
// web3.bzz.setProvider(myProvider)

// EXAMPLE
// var Web3 = require('web3');
// var web3 = new Web3('http://localhost:8545');
// // or
// var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

// // change provider
// web3.setProvider('ws://localhost:8546');
// // or
// web3.setProvider(new Web3.providers.WebsocketProvider('ws://localhost:8546'));

// // Using the IPC provider in node.js
// var net = require('net');
// var web3 = new Web3('/Users/myuser/Library/Ethereum/geth.ipc', net); // mac os path
// // or
// var web3 = new Web3(new Web3.providers.IpcProvider('/Users/myuser/Library/Ethereum/geth.ipc', net)); // mac os path
// // on windows the path is: "\\\\.\\pipe\\geth.ipc"
// // on linux the path is: "/users/myuser/.ethereum/geth.ipc"

// const Web3 = require('web3');

// let web3 = new Web3(Web3.givenProvider || "ws://localhost:8545");
// // console.log(Web3.modules);
// console.log(web3.version);




























// import React, { Component } from "react";
// import SimpleStorageContract from "./contracts/SimpleStorage.json";
// import getWeb3 from "./getWeb3";

// import "./App.css";

// class App extends Component {
//   state = { storageValue: 0, web3: null, accounts: null, contract: null };

//   componentDidMount = async () => {
//     try {
//       // Get network provider and web3 instance.
//       const web3 = await getWeb3();

//       // Use web3 to get the user's accounts.
//       const accounts = await web3.eth.getAccounts();

//       // Get the contract instance.
//       const networkId = await web3.eth.net.getId();
//       const deployedNetwork = SimpleStorageContract.networks[networkId];
//       const instance = new web3.eth.Contract(
//         SimpleStorageContract.abi,
//         deployedNetwork && deployedNetwork.address,
//       );

//       // Set web3, accounts, and contract to the state, and then proceed with an
//       // example of interacting with the contract's methods.
//       this.setState({ web3, accounts, contract: instance }, this.runExample);
//     } catch (error) {
//       // Catch any errors for any of the above operations.
//       alert(
//         `Failed to load web3, accounts, or contract. Check console for details.`,
//       );
//       console.error(error);
//     }
//   };

//   runExample = async () => {
//     const { accounts, contract } = this.state;

//     // Stores a given value, 5 by default.
//     await contract.methods.set(5).send({ from: accounts[0] });

//     // Get the value from the contract to prove it worked.
//     const response = await contract.methods.get().call();

//     // Update state with the result.
//     this.setState({ storageValue: response });
//   };

//   render() {
//     if (!this.state.web3) {
//       return <div>Loading Web3, accounts, and contract...</div>;
//     }
//     return (
//       <div className="App">
//         <h1>Good to Go!</h1>
//         <p>Your Truffle Box is installed and ready.</p>
//         <h2>Smart Contract Example</h2>
//         <p>
//           If your contracts compiled and migrated successfully, below will show
//           a stored value of 5 (by default).
//         </p>
//         <p>
//           Try changing the value stored on <strong>line 42</strong> of App.js.
//         </p>
//         <div>The stored value is: {this.state.storageValue}</div>
//       </div>
//     );
//   }
// }

// export default App;
