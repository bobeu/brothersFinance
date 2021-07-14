import React, { useState, useEffect } from "react";
import PeerBrothers from "./PeerBrothers";


const UserPage = (props) => {
    console.log(PeerBrothers);
    const [userInfo, setUserInfo] = useState({
        address: "",
        balance: 0,
        groupAdmin: ""
    });

    useEffect(() => { getUserInfo(); }, []);

    const getUserInfo = () => {
        const a = PeerBrothers.t.accounts;
        const b = PeerBrothers.t.contract_instance.methods.balanceOf(a).call({from: a});
        const g = PeerBrothers.c.contract_instance.methods.upline().call({from: a});

        setUserInfo({
            address: a,
            balance: b,
            groupAdmin: g
        })
    };

    return(
        <section className="App">
            {!props.web3 ? <p>Oops! Something went wrong</p> : <section>{<div>
                <h2>Welcome!</h2>
                <p><strong>{userInfo.address}</strong></p>
                {/* <h3>Contract Address: <strong>{p.c_address}</strong></h3> */}
                {/* <p>Interact with <strong>BRO TOKEN</strong> below.</p> */}
                <div>
                {/* <p>Trying out some functions:</p><br></br>  */}
                <p><strong>Balance: {userInfo.balance}</strong></p><br></br>
                <p><strong>Upline: {userInfo.groupAdmin}</strong></p><br></br>
                {/* <p><strong>Decimal: {p.Decimal}</strong></p><br></br>
                <p><strong>Total Supply: {p.storageValue}</strong></p><br></br>
                <p><strong>User balance: {p.userBalance}</strong></p> */}
                {/* <p><strong>Balance: {p.balance}</strong></p> */}
                </div>
            </div>
            }</section>}
    </section>
    );
};

export default UserPage;