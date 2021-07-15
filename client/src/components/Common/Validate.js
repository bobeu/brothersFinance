import React, { useState, useEffect } from "react";
import getWeb3 from "../../getWeb3";
import SafeBROsToken from "../../contracts/SafeBROsToken.json";

function Validate(props) {
    // let errors = values;
    const [ results, setErrors ] = useState({result_: Boolean,});

    useEffect(() => {
        ( async () => {
            exec();
        })()
    }, []);
    
    function exec() {
        const transfer = new Promise(
            async (resolve, reject) => {
                try{
                    const web3 = getWeb3();
                    const accounts = await web3.eth.getAccounts();
                    const networkId = await web3.eth.net.getId();
                    const deployedNetwork = SafeBROsToken.networks[networkId];
                    const instance = new web3.eth.Contract(SafeBROsToken.abi, deployedNetwork.address);
                    const result = await instance.methods.transfer(props.address, props.amount).send({from: accounts[0]});
                    console.log(result);
                    resolve(result);
                    console.log(result);

                    setErrors({result_: result});
                    
                } catch (error) {
                    reject(error);
                }
        })();
    }

    return(
        <div>
            {
            !results ? <div><h3>Failed</h3></div> : <div><h3>Transfer successful</h3></div>
            }
        </div>
    );
}
    

export default Validate;

// else if(values.amount == 0) {
//     errors.amount=;
// }