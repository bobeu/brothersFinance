// import { get } from 'jquery';
import React from 'react';
import { Link } from "react-router-dom";
import getWeb3 from '../getWeb3';

function Transfer(props) {
    // const Web3 = getWeb3();
    // const account = Web3.accounts;
    // return (async () =>{
            // const t = await Web3.methods.transfer().send(props.recipient, props.value, {from: account[0]});
    return (
        <div>
            <h2>Transfer</h2>
            <Link to="/" className="btn btn-primary">Home</Link>
            <Link to="Token" className="btn btn-primary">Token</Link>
        </div>
    );
        // });
    
}

export default Transfer;