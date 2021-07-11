// import { get } from 'jquery';
import React, { useState, useEffect } from 'react';
import { Link } from "react-router-dom";
import getWeb3 from '../getWeb3';
import TransferForm from "./TransferForm";
import SafeBROsToken from "../contracts/SafeBROsToken.json";

const Transfer = props => {
    const [ params, setParams ] = useState({
        address: "",
        amount: null
    });

    // useEffect(() => {
    //     getParams();
    // }, []);

    // const getParams = () => {
        

    //     setParams({

    //     })
    // };
    function handleChange({ target }) {
        setParams(
            { ...params, [target.name]: target.value }
        );
    }

    // const web3 = getWeb3();
    // const accounts = await web3.eth.getAccounts();
    // const networkId = await web3.eth.net.getId();
    // const deployedNetwork = SafeBROsToken.networks[networkId];
    // // const contractAddress = deployedNetwork.address;
    // const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
    // const tf = await instance.methods.transfer(props.address, props.amount, {from: accounts[0]});


    // const Web3 = getWeb3();
    // const account = Web3.accounts;
    // return (async () =>{
        // const t = await Web3.methods.transfer().send(props.recipient, props.value, {from: account[0]});
        return (
        <div>
            <h2>Transfer</h2>
            <Link to="/" className="btn btn-primary">Home</Link>
            <Link to="Token" className="btn btn-primary">Token</Link>
            <TransferForm params={params} onChange={handleChange}/>
        </div>
    );
        // });
    
}

export default Transfer;