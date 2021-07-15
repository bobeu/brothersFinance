import React, { useState, useEffect } from "react";
import tokenCmon from "../../Common/TokenCmon";
import Result from "../../Common/Result";

function Transfer(props) {
    const [ results, setErrors ] = useState({result_: Boolean,});

    useEffect(() => {
        ( async () => {
            exec();
        })()
    }, []);
    
    function exec() {
        const s = new Promise(
            async (resolve, reject) => {
                try{
                    const web3 = tokenCmon();
                    const account = await web3.account;
                    const result = await web3.contract_instance.methods.transfer(props.rec, props.amount).send({from: account});
                    resolve(result);
                  

                    setErrors({result_: result});
                    
                } catch (error) {
                    reject(error);
                }
        })();
    }

    return(
        <Result results={results}/>
    );
}
    

export default Transfer;
