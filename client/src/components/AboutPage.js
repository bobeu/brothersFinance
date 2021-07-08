import React from 'react';
import { Link } from "react-router-dom";

class AboutPage extends React.Component {
    render() {
        return (
            <div>
                <h2>About</h2>
                <Link to="/" className="btn btn-primary">Home</Link>
                <Link to="Token" className="btn btn-primary">Token</Link>
            </div>
        );
    }
}

export default AboutPage;