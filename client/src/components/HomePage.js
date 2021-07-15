import React, { DocumentType } from "react";
import { Link } from "react-router-dom";
import UserPage from "./UserPage";
import { Button, Card, Form, InputGroup} from "react-bootstrap";

import "bootstrap/dist/css/bootstrap.min.css";
// import ConnectWallet from "./Common/ConnectWallet";


function HomePage() {
    const handleClick = () => {
        // UserPage();
    }
    return (
        <>
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

            <div>
                <div>
                    <h3>Welcome to PeerFinance</h3>
                    <Button type="button" className="btn btn-outline-info btn-lg">
                        Connect Wallet
                    </Button>
                </div>
                <section className="container">
                    <div className="card shadow">
                        <div className="card-body">
                            <Button type="button">Search</Button>
                            <Form >
                                
                            </Form>
                        </div>
                    </div>
                </section>

                <div className="container">
                    <div className="card mt-4">
                        <div className="card-body">

                        </div>
                    </div>
                </div>
            </div>
        </>
        );
    }

export default HomePage;

