// invoke the deployment with "node deploy.js" from the ethereum directory

const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");

const compiledRiskChain = require("./build/risk-chain.json"); // We need to add this file?
console.log(compiledRiskChain.interface);
console.log("Copy this ABI into the ABI json variable in file RiskContract.js");

const provider = new HDWalletProvider(
    "draw donor adult scissors pulp document enrich supreme skull order pen oak",
    "rinkeby.infura.io/v3/24bcc8ff85524dca96beda03d5556d79" // infura address endpoint

);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    console.log("attempting to deploy from account", accounts[0]);

    const result = await new web3.eth.Contract(
        JSON.parse(compiledRiskChain.interface)
    )
        .deploy({ data: compiledRiskChain.bytecode })
        .send({ gas: "2000000", from: accounts[0] });

    console.log("Contract deployed to rinkeby at", result.options.address);
    console.log("Copy this contract address into the address variable in file trojanSecret.js");
};

deploy();

