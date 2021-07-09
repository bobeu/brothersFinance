import React from "react";
import { Link } from "react-router-dom";

const MarkUpTokenInfo = props => {
    const p = props;
    const t = p.token;
    return(
        <>
            <section className="App">
                {!props.web3 ? <p>Loading Web3, accounts, and contract...</p> : <section>{
                <div>
                    <h2>Welcome!</h2>
                    <p><strong>{p.accounts[0]}</strong></p>
                    <h3>Contract Address: <strong>{p.c_address}</strong></h3>
                    <p>Interact with <strong>BRO TOKEN</strong> below.</p>
                    <div>
                    <p>Trying out some functions:</p><br></br> 
                    <p><strong>Token name: {p.name_}</strong></p><br></br>
                    <p><strong>Symbol: {p.symbol}</strong></p><br></br>
                    <p><strong>Decimal: {p.Decimal}</strong></p><br></br>
                    <p><strong>Total Supply: {p.storageValue}</strong></p><br></br>
                    <p><strong>User balance: {p.userBalance}</strong></p>
                    {/* <p><strong>Balance: {p.balance}</strong></p> */}

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
                                {/* {props.token.map(markUp => { */}
                                    {/* return ( */}
                                        {/* <tr key={markUp.id}> */}
                                        <tr>
                                            <td><Link to={"/t/" + t.slug}>{t[0]}</Link></td>
                                            <td><Link to={"/t/" + t.slug}>{t[1]}</Link></td>
                                            <td><Link to={"/t/" + t.slug}>{t[2]}</Link></td>
                                            <td><Link to={"/t/" + t.slug}>{t[3]}</Link></td>
                                            <td><Link to={"/t/" + t.slug}>{t[4]}</Link></td>
                                        </tr>
                                    {/* ); */}
                                {/* })} */}
                            </tbody>
                        </table>
                    </div>
                </div>}</section>}
            </section>
        </>
    );
}

export default MarkUpTokenInfo;

