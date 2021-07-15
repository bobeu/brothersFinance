import React from "react";
import { useState } from  "react";
import { Button } from "react-bootstrap";
import Validate from "./Validate";

function TextInput() {
    let errors = {};
    const [ params, setParams ] = useState({
        address: "",
        amount: 0,
    });

    function onInputChange(event) {
        event.preventDefault();
        setParams({
            ...params, 
            [event.target.name]: event.target.value,
        });
    }

    function handleFormSubmit(event) {
        event.preventDefault();
        if(!params.address && !params.amount) {
            if(!params.address || params.address.length < 42 || params.address.length > 42) {
                errors.address = "Invalid address.";
            }
            if(params.amount === 0) {
                errors.amount="Amount should be greater than 0 ";
    
            }
            return false;
        } else if(params.address.length === 42 && params.amount > 0) {
            Validate(params);
        }
        
    };
    // onSubmit={handleSubmit}
    return(
        <div>
              <div>
                <h3 className="container">Transfer</h3>
            </div>
            <div>
                <form> {/*className="form-wrapper"*/}
                    <div className="form-group">
                        <label htmlFor="address">Recipient</label>
                        <div className="field">
                            <input
                                id="address"
                                type="text" 
                                onChange={onInputChange} 
                                placeholder='address' 
                                name="address" 
                                className="form-control" 
                                value={params.address} 
                                />
                                {errors.address && <p className="error">{errors.address}</p>}
                        </div>
                    </div>

                    <div className="form-group">
                        <label htmlFor="amount">Amount</label>
                        <input
                            id="amount"
                            name="amount" 
                            onChange={onInputChange} 
                            value={params.amount}
                            type="number"
                            className="form-control"
                            placeholder='Value' 
                            />
                            {errors.amount && <p className="error">{errors.amount}</p>}
                    </div>
                    <div><button className="submit" className="btn btn-primary" onClick={handleFormSubmit}>Send Transaction</button></div>
                </form>,
            </div>
            {/* {Transfer(params)} */}

        </div>
    );
}

export default TextInput;


//     let wrapperClass = "form-group";
//     if(props.error.length > 0) {
//         wrapperClass += "has-error";
//     }
//     return(
//         <div className={wrapperClass}>
//                 <label htmlFor={props.id}>{props.label}</label>
//                 <div className="field">
//                     <input 
//                         id={props.id}
//                         types="text"
//                         onChange={props.onChange}
//                         name={props.name}
//                         className="form-control"
//                         value={props.params.address || ""}
//                     />
//                 </div>
//                 {props.error && <div className="alert alert-danger">{props.error}</div>}
//             </div>
//     );
// }

// TextInput.propTypes = {
//     id: PropTypes.string.isRequired,
//     name: PropTypes.string.isRequired,
//     label: PropTypes.string.isRequired,
//     onChange: PropTypes.func.isRequired,
//     value: PropTypes.string,
//     error: PropTypes.string
// };
// TextInput.defaultProps = { error: ""};
