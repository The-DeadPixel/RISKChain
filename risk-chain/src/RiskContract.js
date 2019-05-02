/**
 This file seems to be having an issue, there is a resolution and discussion here:
 https://github.com/ethereum/web3.js/issues/1969

 */

import Web3 from 'web3';

const web3 = new Web3(window.Web3.currentProvider);

const address = "0xADDRESS_OF_CONTRACT"; // Here we need to put the address that the contract is deployed to

const abi = [
    {
        "constant": false,
        "inputs": [
            {
                "name": "input",
                "type": "uint256[]"
            }
        ],
        "name": "PlaceTroopsDriver",
        "outputs": [
            {
                "name": "success",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "input",
                "type": "uint256[]"
            }
        ],
        "name": "TrfArmiesDriver",
        "outputs": [
            {
                "name": "success",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "input",
                "type": "uint256[]"
            }
        ],
        "name": "AttackDriver",
        "outputs": [
            {
                "name": "success",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [],
        "name": "getCurrentPlayer",
        "outputs": [
            {
                "name": "player",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "player",
                "type": "address"
            }
        ],
        "name": "getSizeOfHand",
        "outputs": [
            {
                "name": "size",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "currentPlayer",
                "type": "address"
            }
        ],
        "name": "getCurrentPlayerOpponents",
        "outputs": [
            {
                "name": "opponents",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [],
        "name": "getGameState",
        "outputs": [
            {
                "name": "boardState",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "data",
                "type": "uint256[]"
            },
            {
                "name": "arraySize",
                "type": "uint256"
            }
        ],
        "name": "sort",
        "outputs": [
            {
                "name": "",
                "type": "uint256[]"
            }
        ],
        "payable": false,
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "input",
                "type": "uint256[]"
            }
        ],
        "name": "playCards",
        "outputs": [
            {
                "name": "success",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "player",
                "type": "address"
            }
        ],
        "name": "getHand",
        "outputs": [
            {
                "name": "handJSON",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "player",
                "type": "address"
            }
        ],
        "name": "getPlayerIncome",
        "outputs": [
            {
                "name": "income",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "name": "players",
                "type": "address[]"
            },
            {
                "name": "names",
                "type": "string[]"
            },
            {
                "name": "seed",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "constructor"
    }
];

export default new web3.eth.Contract(abi, address);


