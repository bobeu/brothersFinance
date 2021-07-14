import React, { useState, useEffect } from "react";
import AirdropCmon from "../../Common/AirdropCmon";

const Airdrops = (Web3) => {
    const [ad, setResult] = useState({});

    useEffect(() => {
        getResult();
      }, []);

    const getResult = async () => {
        const result = await AirdropCmon.contract_instance.methods.airdrops().call();
        setResult(result);
    };

    return(
        <div className="AirdropClaim">
            <h3>Airdrop info</h3>
            <ul className="Airdrop-wrapper">
                <li>Pool Balance: {ad.poolBalance}</li>
                <li>Status: {ad.active}</li>
                <li>Active Time: {ad.activeTime}</li>
                <li>Total Claimed: {ad.totalClaimed}</li>
                <li>Unit claimable: {ad.unitClaim}</li>
            </ul>
            <h3 className="Counter"><span>{ad}</span></h3>
        </div>
    );
};

export default Airdrops;
