import React from 'react';
import { Link } from "react-router-dom";

function NotFoundPage() {
        return (
            <div>
                <h2>Error: Page Not Found</h2>
                <Link to="/" className="btn btn-primary">Back to Home</Link>
            </div>
        );
    }

export default NotFoundPage;