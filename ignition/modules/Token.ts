import {buildModule} from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Token", (m: any) => {
    const tokenContract = m.contract("Token", [])
    return tokenContract
})

/**
 * deployed on localhost:
 * [ Token ] successfully deployed 🚀

    Deployed Addresses

    Token#Token - 0x5FbDB2315678afecb367f032d93F642f64180aa3
*/