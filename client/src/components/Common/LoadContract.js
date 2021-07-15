import React, { useEffect, useState } from "react";
import Airdrop from "../Contracts/Airdrop";
import Core from "../Contracts/Core";
import Token from "../Contracts/Token";

const LoadContract = async () => {
    const [contract, setContract] = useState({});

    useEffect(() => { getContracts() }, []);

    function getContracts() {
        setContract({
            a: Airdrop,
            c: Core,
            t: Token
        });
    }
    return(
        contract
    );
};

export default LoadContract;