import React, { useState } from "react";
import Airdrop from "../Contracts/Airdrop";
import Core from "../Contracts/Core";
import Token from "../Contracts/Token";

const LoadContract = async () => {
    const contract = await {
        airdrop: Airdrop,
        core: Core,
        token: Token
    };

    return(
        <contract />
    );
};

export default LoadContract;