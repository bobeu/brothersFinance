import React from "react";
import { useState } from  "react";
// import PropTypes from 'prop-types';
import Transfer from "../Transfer";
import Validation from "./Validation";

function TextInput() {
    const [errors, setErrors] = useState({});
    const [ params, setParams ] = useState({
        address: "",
        amount: 0,
    });


     const handleChange = (event) => {
        event.preventDefault();
        setParams({
            ...params, 
            [event.target.name]: event.target.value 
        });
    }

    const handleFormSubmit = (event) => {
        event.preventDefault();
        setErrors(Validation(params));
        Transfer(params);
        // return (
        //     <div>
        //         <Transfer params={params}/>
        //     </div>
        // );
        // console.log(params, event);
    }
    // onSubmit={handleSubmit}
    return(
        <div>
            <div>
            <h3 className="container">Transfer</h3>
            </div>
            
            <div>
                <form className="form-wrapper">
                    <div className="container">
                        <input 
                            className="input" 
                            type="text" 
                            placeholder='Recipient Address' 
                            name="address" 
                            value={params.address} 
                            onChange={handleChange} 
                            />
                            {errors.address && <p className="error">{errors.address}</p>}
                    </div>
                    <div className="container">
                        <input
                            className="input"
                            type="number"  
                            placeholder='Value' 
                            name="amount" 
                            value={params.amount}
                            onChange={handleChange} 
                            />
                            {errors.amount && <p className="error">{errors.amount}</p>}
                    </div>
                    <div className="container"><button className="submit" className="btn btn-primary" onClick={handleFormSubmit}>Send Transaction</button></div>
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
