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
                        name="address"
                        className="form-control"
                        value=""
                    />
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="Amount">Amount</label>
                <div className="field">
                    <select 
                        id="amount"
                        name="amount"
                        onChange={props.onChange}
                        value=""
                        className="form-control"
                    />
                    <option value="" />
                    <option value="0">Cary House</option>
                    <option value="2">Scott Allen</option>
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="category">Category</label>
                <div className="field">
                    <select 
                        types="text"
                        id="category"
                        name="category"
                        className="form-control"
                        value=""
                    />
                </div>
            </div>

            <input type="submit" value="Save/" className="btn btn-primary" />
        </form>
    );
}