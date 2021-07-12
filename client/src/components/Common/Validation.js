import React from "react";

const Validation = (values) => {

    let errors = {};
    if(!values.address) {
        errors.address="Address is required.";
    } else if(values.address.length > 42 || values.address.length < 42) {
        errors.address="Invalid address";
    }
    if(!values.amount) {
        errors.amount="value is required";
    } else if(values.amount == 0) {
        errors.amount="Amount must be greater than 0";
    }
    return errors;
}

export default Validation;