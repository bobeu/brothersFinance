import React, { DocumentType } from "react";
import { Link } from "react-router-dom";
import UserPage from "./UserPage";
import { Button, Card, Form, InputGroup} from "react-bootstrap";
import Navbar from "./Common/Navbar";
import "bootstrap/dist/css/bootstrap.min.css";
// import ConnectWallet from "./Common/ConnectWallet";


function HomePage() {
    const handleClick = () => {
        // UserPage();
    }
    return (
        <>
        <div>
            <Navbar/>
        </div>,
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
                            <input className="" placeholder="aaa"/>
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

