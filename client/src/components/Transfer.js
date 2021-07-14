import React, { useState, useEffect } from 'react';
// // import { Link } from "react-router-dom";
import getWeb3 from '../getWeb3';
// // import TransferForm from "./TransferForm";
import SafeBROsToken from "../contracts/SafeBROsToken.json";
// import TextInput from './Common/TextInput';
import SuccessReturnMessage from './Common/SuccessReturnMessage';

const Transfer = props => {
    let message = false;
    
    function exec() {
        new Promise(async (resolve, reject) => {
            try{
                const web3 = getWeb3();
                const accounts = await web3.eth.getAccounts();
                const networkId = await web3.eth.net.getId();
                const deployedNetwork = SafeBROsToken.networks[networkId];
                const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
                message = await instance.methods.transfer(props.address, props.amount).send({from: accounts[0]});
                console.log(message);
                resolve(message);
                console.log(message);
                
            } catch (error) {
                reject(error);
        }
    });}

    return (
        <SuccessReturnMessage message={message} />
    );    
}

export default Transfer;

// const contractAddress = deployedNetwork.address;
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