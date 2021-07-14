import React from "react";
// import "./App.css";


const SuccessReturnMessage = (message) => {
    // let message = false;
    return (
        <div className="container">
            <div className="app-wrapper">
                <h2 className="success">
                    {
                    !message ? 
                    <div className="MessageReturn"> 
                        <h3>Transaction unsuccessful</h3>
                    </div> : 
                    <div className="MessageReturn">
                        <h3>Transaction completed</h3>
                    </div>
                    }
                </h2>
            </div>
        </div>
    );
};

export default SuccessReturnMessage;