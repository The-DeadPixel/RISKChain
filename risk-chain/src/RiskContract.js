/**
This file seems to be having an issue, there is a resolution and discussion here:
 https://github.com/ethereum/web3.js/issues/1969


import Web3 from 'web3';

const web3 = new Web3(window.Web3.currentProvider);

const address = "0xADDRESS_OF_CONTRACT"; // Here we need to put the address that the contract is deployed to

const abi = []; // Here we need to bring in the json abi

export default new web3.eth.Contract(abi, address);



 */