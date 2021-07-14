import React, { useState } from "react";
import AirdropCmon from "../../Common/AirdropCmon";

const AirdropCount = (Web3) => {
    const [counter, setCounter] = useState(counter = 0);

    useEffect(() => {
        getFuncs();
      }, []);

    const getFuncs = async () => {
        const newer = await AirdropCmon.contract_instance.methods.airdropCount().call();
        setCounter(counter = newer);
    };

    return(
        <div>
            <h3 className="Counter">Total registered hunters: <span>{counter}</span></h3>
        </div>
    );
};

export default AirdropCount;
