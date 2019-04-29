// invoke the deployment with "node deploy.js" from the ethereum directory

const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");

const compiledTrojanSecret = require("./build/RISK.json");
console.log(compiledTrojanSecret.interface);
console.log("Copy this ABI into the ABI json variable in file trojanSecret.js");


const provider = new HDWalletProvider(
    "cricket wool shallow size original car radio layer lava wisdom media neutral",
    "https://rinkeby.infura.io/v3/2a8f3769a6e448c583fc3d4a6ae7c143"
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    console.log("attempting to deploy from account", accounts[0]);

    const result = await new web3.eth.Contract(
        JSON.parse(compiledTrojanSecret.interface)
    )
        .deploy({ data: compiledTrojanSecret.bytecode })
        .send({ gas: "2000000", from: accounts[0] });

    console.log("Contract deployed to rinkeby at", result.options.address);
    console.log("Copy this contract address into the address variable in file RISK.js");
};

deploy();