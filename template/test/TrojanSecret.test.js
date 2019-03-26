const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);

const compiledTrojanSecret = require("../ethereum/build/TrojanSecret.json");

let accounts;
let trojanSecret;
let secret;
let message;

// this mocha test suite is executed by the command "npm run test"


// each "it" block will execute a clean slate deployment of the contract with automatic "beforeEach" invocation
beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  // console.log(accounts);

  trojanSecret = await new web3.eth.Contract(
    JSON.parse(compiledTrojanSecret.interface)
  )
    .deploy({ data: compiledTrojanSecret.bytecode })
    .send({ from: accounts[0], gas: "2000000" });
});

// The test suite is given in a DESCRIBE function calling multiple IT functions as tests

describe("Trojan Secret Contract", () => {

  it("contract can be deployed", () => {
    assert.ok(trojanSecret.options.address);
  });

  it("Alice can register as a Trojan", async () => {
    await trojanSecret.methods.registerTrojan("Alice").send({
      from: accounts[1],
      gas: "1000000"
    });
    const numTrojans = await trojanSecret.methods.memberCount().call({
      from: accounts[1]
    });
    assert(numTrojans == 1);
  });

  it("Alice cannot register twice", async () => {
    await trojanSecret.methods.registerTrojan("Alice").send({
      from: accounts[1],
      gas: "1000000"
    });
    try {  // I am explicitly trying to catch an exception from the REGISTER solidity function
      await trojanSecret.methods.registerTrogjan("Alice").send({
        from: accounts[1],
        gas: "1000000"
      });
      assert(false);  // if it doesn't throw an error, this line will execute to indicate failure
    } catch (err) {   // this will catch the error
      assert(err);    // if we have an error, this will evaluate true and the test passes
    }
  });

  it("Alice can create a secret but Bob cannot read it", async () => {
    await trojanSecret.methods.registerTrojan("Alice").send({
      from: accounts[1],
      gas: "1000000"
    });

    await trojanSecret.methods
      .setSecret("Alice", "My name is really Joseph")
      .send({
        from: accounts[1],
        gas: "1000000"
      });

    secret = await trojanSecret.methods.getSecret("Alice").call({
      from: accounts[2],
      gas: "1000000"
    });

    assert(secret == "message is locked");
  });

  it("Bob can unlock and read Alice's secret", async () => {
    await trojanSecret.methods.registerTrojan("Alice").send({
      from: accounts[1],
      gas: "1000000"
    });

    await trojanSecret.methods
      .setSecret("Alice", "My name is really Joseph")
      .send({
        from: accounts[1],
        gas: "1000000"
      });

    await trojanSecret.methods.unlockMessage("Alice").send({
      from: accounts[2],
      value: web3.utils.toWei("1", "ether"),
      gas: "1000000"
    });

    secret = await trojanSecret.methods.getSecret("Alice").call({
      from: accounts[2],
      gas: "1000000"
    });
    console.log(secret);
    assert(secret == "My name is really Joseph");
  });

  it("Add players Alice, Bob, Carol. Delete Bob. Add player Dan. List the players and you should get\n" +
      "Alice, Carol and Dan.", async () => {
    await trojanSecret.methods.registerTrojan("Alice").send({
      from: accounts[1],
      gas: "1000000"
    });
    await trojanSecret.methods.registerTrojan("Bob").send({
      from: accounts[2],
      gas: "1000000"
    });
    await trojanSecret.methods.registerTrojan("Carol").send({
      from: accounts[3],
      gas: "1000000"
    });
    await trojanSecret.methods.unregisterTrojan("Bob").send({
      from: accounts[2],
      gas: "1000000"
    });
    await trojanSecret.methods.registerTrojan("Dan").send({
      from: accounts[4],
      gas: "1000000"
    });
    message = await trojanSecret.methods.listPlayers().call({
      from: accounts[1]
    });
    console.log(message);
    assert(message == "Alice , Carol , Dan");
  });

  it("A loop that creates more than ten players from a list of names. The eleventh addition should fail due\n" +
      "to the limit of ten players.", async () => {
    let attempt = 0;
    try {
    for (attempt = 0; attempt < 15; attempt++) {
      await trojanSecret.methods.registerTrojan(attempt.toString()).send({
        from: accounts[1],
        gas: "1000000"
      });
    }
    }catch(err){

    }finally{
      console.log(attempt);
      assert(attempt == 10);
      const numTrojans = await trojanSecret.methods.memberCount().call({
        from: accounts[1]
      });
      assert(attempt == numTrojans)
    }

  });

});
