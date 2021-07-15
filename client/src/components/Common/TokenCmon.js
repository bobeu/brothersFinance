import React, { useState, useEffect } from "react";
import SafeBROsToken from "../../contracts/SafeBROsToken.json";
import getWeb3 from "../../getWeb3";

const tokenCmon = () => {
    const [web3, setWeb3Obj] = useState({
        web3Obj: null,
        account: null,
        network_id: null,
        deployed_network: null,
        contract_address: "",
        contract_instance: null,
    });

    useEffect(() => {
        getWeb3Obj();
    }, []);

    const getWeb3Obj = async () => {
        try {
          const web3 = await getWeb3();

          // Use web3 to get the user's accounts.
          const accounts = await web3.eth.getAccounts();
          
          // Get the contract instance and contract address.
          const networkId = await web3.eth.net.getId();
          const deployedNetwork = SafeBROsToken.networks[networkId];
          const contractAddress = deployedNetwork.address;
          const instance = new web3.eth.Contract(SafeBROsToken.abi, contractAddress);
       
          setWeb3Obj(
            {
                web3Obj: web3,
                account: accounts,
                network_id: networkId,
                deployed_network: deployedNetwork,
                contract_address: contractAddress,
                contract_instance: instance,
          });
    
          } catch (error) {
            // Catch any errors for any of the above operations.
            alert(
            `Something went wrong.`,
            );
          console.error(error);
        }
      }

    return(web3);
};

export default tokenCmon;
