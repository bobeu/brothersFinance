import React from 'react';
// // import { Link } from "react-router-dom";
// import getWeb3 from '../getWeb3';
// // import TransferForm from "./TransferForm";
// import SafeBROsToken from "../contracts/SafeBROsToken.json";
import TextInput from './Common/TextInput';
// import SuccessReturnMessage from './Common/SuccessReturnMessage';
// import Validation from "./Common/Validate";

const Transfer = () => {
    
    return (
        <>
            <TextInput />
            {/* <SuccessReturnMessage message={message} /> */}
        </>
    );    
}

export default Transfer;

// const contractAddress = deployedNetwork.address;
// const [ params, setParams ] = useState({
    //     address: null,
    //     amount: null
    // });

    // useEffect(() => {
    //     handleChange();
    // }, []);

    // const getParams = () => {
        

    //     setParams({

    //     })
    // };
    // function handleChange(event) {
    //     const target = event.target;
    //     setParams(
    //         { ...params, [target.name]: target.value }
    //     );
    //     console.log(params, target);
    // }