import { useEffect, useState } from "react";
import AirdropCmon from "./Common/AirdropCmon";
import CoreCmon from "./Common/CoreCmon";
import TokenCmon from "./Common/TokenCmon";

const PeerBrothers = () => {
    const [objs_, _init_] = useState({});

    useEffect(() => { getInit(); }, []);

    const getInit = async () => {
        const act = {
            a: AirdropCmon,
            c: CoreCmon,
            t: TokenCmon,
        }
        _init_(act);
    }
    return(objs_);
}

export default PeerBrothers;