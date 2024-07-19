const TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
import {buildModule} from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Dex", (m: any) => {
    const tokenAddress = m.getParameter("_token", TOKEN_ADDRESS)
    const dex = m.contract("Dex", [tokenAddress])
    return dex;
})

/**
 * /**
 * deployed on localhost: (chainid: 31337)
 * [ Token ] successfully deployed 🚀

    Deployed Addresses

    Token#Token - 0x5FbDB2315678afecb367f032d93F642f64180aa3
*/
