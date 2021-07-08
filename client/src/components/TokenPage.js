import React, {useEffect, useState} from "react";
import SafeBROsToken from "../contracts/SafeBROsToken.json";
import getWeb3 from "../getWeb3";
import "bootstrap/dist/css/bootstrap.min.css";


function TokenPage() {
  const [listOf, setListOf] = useState([]);
  // const [
  //   {storageValue=0,
  //   c_address="",
  //   web3=null,
  //   accounts=null,
  //   contract=null,
  //   name="",
  //   symbol="", 
  //   Decimal=0, 
  //   userBalance=0},
  //   initialize
  // ] = useState();

  useEffect(async () => {
      try{
        const web3 = await getWeb3();
        const accounts = await web3.eth.getAccounts();

        // Get the contract instance and contract address.
        const networkId = await web3.eth.net.getId();
        const deployedNetwork = SafeBROsToken.networks[networkId];
        const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
        const contractAddress = deployedNetwork.address; 

        c_address= contractAddress;
        web3= web3;
        name = await contract.methods.name().call();
        symbol = await contract.methods.symbol().call();
        Decimal = await contract.methods.decimals().call();
        storageValue = await contract.methods.totalSupply().call();
        userBalance = await contract.methods.balanceOf(accounts[0]).call();
        accounts= accounts; 
        contract= instance;
      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`,
        );
        console.error(error);
      }

    });


  async function initialize () {
    try {
      // Get network provider and web3 instance.
      // const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      // const accounts = await web3.eth.getAccounts();

      // // Get the contract instance and contract address.
      // const networkId = await web3.eth.net.getId();
      // const deployedNetwork = SafeBROsToken.networks[networkId];
      // const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
      // const contractAddress = deployedNetwork.address;

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
        // c_address= contractAddress;
        // web3= web3;
        // name = await contract.methods.name().call();
        // symbol = await contract.methods.symbol().call();
        // Decimal = await contract.methods.decimals().call();
        // storageValue = await contract.methods.totalSupply().call();
        // userBalance = await contract.methods.balanceOf(accounts[0]).call();
        // accounts= accounts; 
        // contract= instance; 
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  // runExample = async () => {
  //   const {accounts, contract} = this.state;
  //   // const value = 459;
  //   // Stores a given value, 5 by default.

  //   this.setState({listOf : [_name, _symbol, _decimal, _totalSupply, _balance]});

  //   // Update state with the result.
  //   this.setState({ 
  //     storageValue: _totalSupply, 
  //     name: _name, 
  //     Decimal: _decimal, 
  //     symbol: _symbol, 
  //     userBalance: _balance
  //   });
  // };

    if (!web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h2>Welcome!</h2>
        <p><strong>{accounts[0]}</strong></p>
        <h3>Contract Address: <strong>{c_address}</strong></h3>
        <p>Interact with <strong>BRO TOKEN</strong> below.</p>
        <p>
          Trying out some functions:<br></br> 
          <strong>Token name: {name}</strong><br></br>
          <strong>Symbol: {symbol}</strong><br></br>
          <strong>Decimal: {Decimal}</strong>
        </p>
        <div>Total Supply: {storageValue}</div><br></br>
        <div className="Bal">User balance: {userBalance}</div><br></br>
     
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Symbol</th>
              <th>Decimal</th>
              <th>TotalSupply</th>
              <th>Userbalance</th>
            </tr>
          </thead>

          <tbody>
            {/* {listOf.map(listof => {
              return ( */}
              {/* key={listof.id} */}
                <tr>
                  <td>{listOf[0]}</td>
                  <td>{listOf[1]}</td>
                  <td>{listOf[2]}</td>
                  <td>{listOf[3]}</td>
                  <td>{listOf[4]}</td>
                </tr>
              {/* );})} */}
          </tbody>
        </table>
      </div>
    );
  }


export default TokenPage;
