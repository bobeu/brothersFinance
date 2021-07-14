import React, { useState, useEffect } from "react";
import PeerBrothers from "../../../../build/contracts/PeerBrothers.json";
import getWeb3 from "../../getWeb3";

const Core = () => {
    const [contract, setCoreObj] = useState(
        {
            address: "",
            peerGroupCount: 0,
            exist: null,
            isAPeerBrother: null,
            isAdmin: null,
            upline: "",
            peerInfo: null,
            setRole: null,
            rewardPeerMember: null,
            getStatus: null,
            changeStatus: null,
            resetData: null,
            createPeerGroup: null,
            getMemberinfo: null,
            joinYourPeer: null,
            resolve: null,
            getLastPosition: null,
            getLastPayDate: null,
            getFinance: null,
            getPaymentInfo: null,
            getYourPositionId: null,
            getTotalPaidMembers: null,
            getDateInfo: null,
            payBack: null,
            getCurrentTimestamp: null,
            getCurrentBlockNumber: null,
            getDebtbalance: null
        });
    
useEffect(() => {
    getCore();
}, []);

    const getCore = async () => {
        try {
          const web3 = await getWeb3();
    
          // Use web3 to get the user's accounts.
          const accounts = await web3.eth.getAccounts();
          
          // Get the contract instance and contract address.
          const networkId = await web3.eth.net.getId();
          const deployedNetwork = SafeBROsToken.networks[networkId];
          const contractAddress = deployedNetwork.address;
          const instance = new web3.eth.Contract(SafeBROsToken.abi, contractAddress);
          // console.log(deployedNetwork.address);
          // console.log(instance);
    
          const nam = await instance.methods.name().call();
          const sym = await instance.methods.symbol().call();
          const Dec = await instance.methods.decimals().call();
          const userBal = await instance.methods.balanceOf(accounts[0]).call();
          const total_s = await instance.methods.totalSupply().call();
          // const bal = web3.eth.getBalance();
          
          // Set web3, accounts, and contract to the state, and then proceed with an
          // example of interacting with the contract's methods
          setListOf(
            {
              storageValue: total_s,
              c_address: contractAddress,
              web3: web3,
              accounts: accounts,
              contract: instance,
              name_: nam,
              symbol: sym,
              Decimal: Dec,
              userBalance: userBal,
              token: [
                nam,
                sym,
                Dec,
                total_s,
                contractAddress
              ]
          });
          // console.log(web3);/
          // console.log(web3.BatchRequest());
    
    
          } catch (error) {
            // Catch any errors for any of the above operations.
            alert(
            `Failed to load web3, accounts, or contract. Check console for details.`,
            );
          console.error(error);
        }
      }

    return();
};

export default Core;
