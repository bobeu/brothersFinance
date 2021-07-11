import React, { useState, useEffect } from 'react';
// // import { Link } from "react-router-dom";
import getWeb3 from '../getWeb3';
// // import TransferForm from "./TransferForm";
import SafeBROsToken from "../contracts/SafeBROsToken.json";
// import TextInput from './Common/TextInput';

const Transfer = props => {
    // const [ params, setParams ] = useState({
    //     address: null,
    //     amount: null
    // });

    // useEffect(() => {
    //     handleChange();
    // }, []);

    // const getParams = () => {
        

    //     setParams({

    //     })
    // };
    // function handleChange(event) {
    //     const target = event.target;
    //     setParams(
    //         { ...params, [target.name]: target.value }
    //     );
    //     console.log(params, target);
    // }
    function exec() {
        new Promise(async (resolve, reject) => {
            try{
                const web3 = getWeb3();
                const accounts = await web3.eth.getAccounts();
                const networkId = await web3.eth.net.getId();
                const deployedNetwork = SafeBROsToken.networks[networkId];
                // const contractAddress = deployedNetwork.address;
                const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
                const result = await instance.methods.transfer(props.address, props.amount).send({from: accounts[0]});
                resolve(result);
                if(result) {
                    alert('');
                }
            } catch (error) {
                reject(error);
        }
    });}

    return (
    <div>
        {exec}
        {/* <h2>Transfer</h2> */}
        {/* <Link to="/" className="btn btn-primary">Home</Link>
        <Link to="Token" className="btn btn-primary">Token</Link> */}
        {/* <TransferForm params={params} onChange={handleChange}/> */}
    </div>
    );    
}

export default Transfer;