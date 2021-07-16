import React, { useState } from "react";
import airdropCmon from "../../Common/airdropCmon";
import React, { useState, useEffect } from "react";
import Result from "../../Common/Result";

function AirdropCount() {
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
                    const web3 = airdropCmon();
                    const account = await web3.account;
                    const result = await web3.contract_instance.methods.airdropCount().call({from: account});
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
    

export default AirdropCount;

