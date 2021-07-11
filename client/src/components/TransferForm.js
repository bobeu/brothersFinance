import React from "react";

function TransferForm(props) {
    return(
        <form>
            <div className="form-group">
                <label htmlFor="Address">Address</label>
                <div className="field">
                    <input 
                        id="address"
                        types="text"
                        onChange={props.onChange}
                        name="address"
                        className="form-control"
                        value={props.params.address || ""}
                    />
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="Amount">Amount</label>
                <div className="field">
                    <input 
                        id="amount"
                        name="amount"
                        type="text"
                        onChange={props.onChange}
                        value={props.params.amount || ""}
                        className="form-control"
                    />
                </div>
            </div>
            <input type="submit" value="Save" className="btn btn-primary" />
        </form>
    );
}

export default TransferForm;