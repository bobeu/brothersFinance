import React from "react";
import UserPage from "../UserPage";

const ConnectWallet = () => {

    return(
        <div className="Button">
            <button className="btn btn-primary" onClick={UserPage}>
                <h3>Connect Wallet</h3>
            </button>
        </div>
    )
};

export default ConnectWallet;