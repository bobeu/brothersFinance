import React from "react";
import { useState } from  "react";
// import PropTypes from 'prop-types';
import Transfer from "../Transfer";

function TextInput() {
    const [ params, setParams ] = useState({
        address: "",
        amount: 0
    });


     const handleSubmit = (event) => {
        event.preventDefault();
    }

    const handleInputChange = (event) => {
        event.preventDefault();
        setParams({
            ...params, 
            [event.target.name]: event.target.value }
        );
        console.log(params, event);
    }

    return(
        <div>
            <h2>Transfer</h2>
            <form onSubmit={handleSubmit}>
                <div>
                    <input 
                        className="input" 
                        type="text" 
                        placeholder='Recipient Address' 
                        name={params.address} 
                        onChange={handleInputChange} 
                        value={params.address} 
                        />
                </div>
                <div>
                    <input
                        className="input"
                        type="number"  
                        placeholder='Value' 
                        name={params.amount} 
                        onChange={handleInputChange} 
                        value={params.amount}
                        />
                </div>
                <p><button className="input" className="btn btn-primary">Send Transaction</button></p>
            </form>,
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
