import React from "react";


const Navbar = () => {

    return (
        <div>
            <nav className="navbar navbar-expand-lg bg-secondary navbar-dark">
                <div className="container">
                    <a href="#" className="navbar-brand">HomePage</a>
                    <Button
                        className="navbar-toggler" 
                        type="button" 
                        data-bs-toggle="collapse" 
                        data-bs-target="#navmenu"
                        >
                        <span className="navbar-toggler-icon"></span>
                    </Button>

                    <div className="collapse navbar-collapse" id="navmenu">
                        <ul className="navbar-nav ms-auto">
                            <li className="nav-item">
                                <a href="#" className="nav-link">PeerBrothers</a>
                            </li>
                            <li className="nav-item">
                                <a href="#" className="nav-link">Airdrop</a>
                            </li>
                            <li className="nav-item">
                                <a href="#" className="nav-link">Token</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </div>
    );
};


export default Navbar;