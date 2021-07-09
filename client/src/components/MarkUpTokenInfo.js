import React from "react";
import { Link } from "react-router-dom";

function MarkUpTokenInfo(props, f) {
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
                <p><strong>Token name: {f.name_}</strong></p><br></br>
                <p><strong>Symbol: {f.symbol}</strong></p><br></br>
                <p><strong>Decimal: {f.Decimal}</strong></p><br></br>
                <p><strong>Total Supply: {f.storageValue}</strong></p><br></br>
                <p><strong>User balance: {f.userBalance}</strong></p>
                </div>

                <div>
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Symbol</th>
                                <th>Decimal</th>
                                <th>TotalSupply</th>
                                <th>Contract Address</th>
                            </tr>
                        </thead>

                        <tbody>
                            {props.token.map(tk => {
                                return (
                                    <tr key={tk.id}>
                                        <td><Link to={"/tk/" + tk.slug}>{tk._name}</Link></td>
                                        <td>{tk.symbol}</td>
                                        <td>{tk.decimal}</td>
                                        <td>{tk.totalSupply}</td>
                                        <td>{tk.contract_address}</td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            </div>}</section>}
        </section>
    );
}

export default MarkUpTokenInfo;

