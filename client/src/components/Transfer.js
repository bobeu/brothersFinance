import React from 'react';
import { Link } from "react-router-dom";

function Transfer() {
        return (
            <div>
                <h2>Transfer</h2>
                <Link to="/" className="btn btn-primary">Home</Link>
                <Link to="Token" className="btn btn-primary">Token</Link>
            </div>
        );
    }

export default Transfer;