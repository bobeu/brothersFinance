// import React, {useEffect, useState} from "react";
// import SafeBROsToken from "../contracts/SafeBROsToken.json";
// import getWeb3 from "../getWeb3";
// // import "bootstrap/dist/css/bootstrap.min.css";
// // import Grid from "@material-ui/core/Grid";


// function TokenPage() {
//   const [listOf, setListOf] = useState([
//     {
//       storageValue: 0,
//       c_address: null,
//       web3: null,
//       accounts: null,
//       contract: null,
//       name_: "",
//       symbol: "", 
//       Decimal: 0, 
//       userBalance: 0
//     },
//   ]);
//  // eslint-disable-next-line
//   async () => {
//       try{
//         const newlistOf = [...listOf]
//         const web3 = await getWeb3();
//         const accounts = await web3.eth.getAccounts();

//         // Get the contract instance and contract address.
//         const networkId = await web3.eth.net.getId();
//         const deployedNetwork = SafeBROsToken.networks[networkId];
//         const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
//         const contractAddress = deployedNetwork.address; 

//         newlistOf[0].c_address = contractAddress;
//         newlistOf[0].web3 = web3;
//         newlistOf[0]._name = await instance.methods.name().call();
//         newlistOf[0].symbol = await instance.methods.symbol().call();
//         newlistOf[0].Decimal = await instance.methods.decimals().call();
//         newlistOf[0].storageValue = await instance.methods.totalSupply().call();
//         newlistOf[0].userBalance = await instance.methods.balanceOf(accounts[0]).call();
//         newlistOf[0].accounts = accounts; 
//         newlistOf[0].contract = instance;
//         setListOf(newlistOf)
//         console.log(web3, contractAddress)
//       } catch (error) {
//         // Catch any errors for any of the above operations.
//         alert(
//           `Failed to load web3, accounts, or contract. Check console for details.`,
//         );
//         console.error(error);
//       }
//     };

//     if (!listOf.web3) {
//       return <div>Loading Web3, accounts, and contract...</div>;
//     }
//     return (
//       <div className="app">
//         <Grid container spacing={24} style={{padding:24}}>
//           {/* {listOf.map((listof) => { */}
//             return (
//               <div>
//                 <h2>Welcome!</h2>
//                   <p><strong>{listOf.accounts}</strong></p>
//                   <h3>Contract Address: <strong>{listOf.c_address}</strong></h3>
//                   <p>Interact with <strong>BRO TOKEN</strong> below.</p>
//                   <p>
//                     Trying out some functions:<br></br> 
//                     <strong>Token name: {listOf._name}</strong><br></br>
//                     <strong>Symbol: {listOf.symbol}</strong><br></br>
//                     <strong>Decimal: {listOf.Decimal}</strong>
//                   </p>
//                   <div>Total Supply: {listOf.storageValue}</div><br></br>
//                   <div className="Bal">User balance: {listOf.userBalance}</div><br></br>
      
//               </div>
//             );
//           {/* } )} */}
          
//         </Grid>
//       </div> 
//     );
//   }


// export default TokenPage;