import React from "react";
import { NavLink } from "react-router-dom";

function Header () {
    const active_Style = {color : "orange"};
    return (
        <nav>
            <NavLink activeStyle={active_Style} to="/" exact >Home</NavLink>
            {" | "} 
            <NavLink activeStyle={active_Style} to='/Transfer'>Transfer</NavLink>
            {" | "} 
            <NavLink activeStyle={active_Style} to='/Token'>Token</NavLink>
        </nav>
    );
}

export default Header;