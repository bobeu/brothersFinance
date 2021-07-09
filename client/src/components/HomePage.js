import React from "react";
import { Link } from "react-router-dom";
// import "bootstrap/dist/css/bootstrap.min.css";


function HomePage() {
    return (
        <div className="Home">
            <h2>Welcome to PeerFinance</h2>
            <h3>Connect Wallet</h3>
            <Link to="Transfer" className="btn btn-primary">Transfer</Link>
            {/* Note: It does not load the TransferPage state unless I refresh */}
            <Link to="Token" className="btn btn-primary">Token</Link> 

        </div>
        );
    }

export default HomePage;