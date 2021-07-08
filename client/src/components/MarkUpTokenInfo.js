import React from "react";

function MarkUpTokenInfo(props) {
    return(
        <section className="App">
            {!props.web3 ? <p>Loading Web3, accounts, and contract...</p> : <section>{
            <div>
                <h2>Welcome!</h2>
                <p><strong>{props.accounts[0]}</strong></p>
                <h3>Contract Address: <strong>{props.c_address}</strong></h3>
                <p>Interact with <strong>BRO TOKEN</strong> below.</p>
                <div>
                <p>Trying out some functions:</p><br></br> 
                <p><strong>Token name: {props.name_}</strong></p><br></br>
                <p><strong>Symbol: {props.symbol}</strong></p><br></br>
                <p><strong>Decimal: {props.Decimal}</strong></p><br></br>
                <p><strong>Total Supply: {props.storageValue}</strong></p><br></br>
                <p><strong>User balance: {props.userBalance}</strong></p>
                </div>
            </div>}</section>}
        </section>
    );
}

export default MarkUpTokenInfo;

