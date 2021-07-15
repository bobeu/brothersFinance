import React, { useState, useEffect } from "react";
import CoreCmon from "../../Common/coreCmon";
import Result from "../../Common/Result";

function Exist(props) {
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
                    const web3 = CoreCmon();
                    const account = await web3.account;
                    const result = await web3.contract_instance.methods.exist(props.targ).send({from: account});
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
    

export default Exist;
