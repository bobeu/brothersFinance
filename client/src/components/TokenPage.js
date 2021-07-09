import React, {useEffect, useState} from "react";
import SafeBROsToken from "../contracts/SafeBROsToken.json";
import getWeb3 from "../getWeb3";
import MarkUpTokenInfo from "./MarkUpTokenInfo";
import "bootstrap/dist/css/bootstrap.min.css";


function TokenPage() {
  const [[listOf, token], setListOf] = useState([
    {
      storageValue: 0,
      c_address: null,
      web3: null,
      accounts: null,
      contract: null,
      name_: "",
      symbol: "", 
      Decimal: 0, 
      userBalance: 0
    }, {
      _name: "",
      symbol: "",
      decimal: 0,
      totalSupply: 0,
      contract_address: null
    }
  ]);

  useEffect(() => {
    getListOf();
  }, []);

  const getListOf = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();
      
      // Get the contract instance and contract address.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = SafeBROsToken.networks[networkId];
      const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
      const contractAddress = deployedNetwork.address;
      
      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      const c_address= contractAddress;
      const web3_ = web3;
      const name_ = await instance.methods.name().call();
      const symbol = await instance.methods.symbol().call();
      const Decimal = await instance.methods.decimals().call();
      const storageValue = await instance.methods.totalSupply().call();
      const userBalance = await instance.methods.balanceOf(accounts[0]).call();
      const accounts_= accounts; 
      const contract_ = instance; 

      setListOf(
        {
          storageValue: storageValue,
          c_address: c_address,
          web3: web3_,
          accounts: accounts_,
          contract: contract_,
          name_: name_,
          symbol: symbol,
          Decimal: Decimal,
          userBalance: userBalance
      }, {
        _name: name_,
        symbol: symbol,
        decimal: Decimal,
        totalSupply: storageValue,
        contract_address: c_address
      });
      console.log(listOf, token);
      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
        );
      console.error(error);
    }
  }

  // if (!web3) {
  //   return <div>Loading Web3, accounts, and contract...</div>;
  // }
    return (
      MarkUpTokenInfo(listOf, token)
    );
  }
  
  
  export default TokenPage;

  
  
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
  

  // try{
    //   const web3 = await getWeb3();
    //   const accounts = await web3.eth.getAccounts();
    
    //   // Get the contract instance and contract address.
    //   const networkId = await web3.eth.net.getId();
  //   const deployedNetwork = SafeBROsToken.networks[networkId];
  //   const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
  //   const contractAddress = deployedNetwork.address; 
  
  //   c_address= contractAddress;
  //   web3= web3;
  //   name = await contract.methods.name().call();
  //   symbol = await contract.methods.symbol().call();
  //   Decimal = await contract.methods.decimals().call();
  //   storageValue = await contract.methods.totalSupply().call();
  //   userBalance = await contract.methods.balanceOf(accounts[0]).call();
  //   accounts= accounts; 
  //   contract= instance;
  // } catch (error) {
    //   // Catch any errors for any of the above operations.
  //   alert(
  //     `Failed to load web3, accounts, or contract. Check console for details.`,
  //   );
  //   console.error(error);
  // }


  // runExample = async () => {
  //   const {accounts, contract} = this.state;
  //   // const value = 459;
  //   // Stores a given value, 5 by default.

  //   this.setState({listOf : [_name, _symbol, _decimal, _totalSupply, _balance]});
  
  //   // Update state with the result.
  //   this.setState({ 
  //       storageValue: _totalSupply, 
  //       name: _name, 
  //       Decimal: _decimal, 
  //       symbol: _symbol, 
  //       userBalance: _balance
  //     });
  //   };
     
        // <table className="table">
        //   <thead>
        //     <tr>
        //       <th>Name</th>
        //       <th>Symbol</th>
        //       <th>Decimal</th>
        //       <th>TotalSupply</th>
        //       <th>Userbalance</th>
        //     </tr>
        //   </thead>

        //   <tbody>
        //     {/* {listOf.map(listof => {
        //     return ( */}
        //       {/* key={listof.id} */}
        //         <tr>
        //           <td>{listOf[0]}</td>
        //           <td>{listOf[1]}</td>
        //           <td>{listOf[2]}</td>
        //           <td>{listOf[3]}</td>
        //           <td>{listOf[4]}</td>
        //         </tr>
        //       {/* );})} */}
        //   </tbody>
        // </table>