const { assert } = require("chai");

const CryptoMonkey = artifacts.require("./CryptoMonkey");

require("chai").use(require("chai-as-promised")).should();

contract("CryptoMonkey", (accounts) => {
	let contract;
	before(async () => {
		contract = await CryptoMonkey.deployed();
	});

	describe("deployment", async () => {
		it("deploys successfully", async () => {
			const address = await contract.address;

			assert.notEqual(address, "");
			assert.notEqual(address, null);
			assert.notEqual(address, undefined);
			assert.notEqual(address, 0x0);
		});

		it("matches name", async () => {
			const name = await contract.name();

			assert.equal(name, "CryptoMonkeyz");
		});

		it("matches symbol", async () => {
			const symbol = await contract.symbol();

			assert.equal(symbol, "CMNKZ");
		});

		it("mints", async () => {
			const result = await contract.mint("https...1");
			const totalSupply = await contract.totalSupply();

			const event = result.logs[0].args;
			//Success
			assert.equal(totalSupply, 1);
			assert.equal(
				event._from,
				"0x0000000000000000000000000000000000000000",
				"from address is the contract"
			);
			assert.equal(event._to, accounts[0], "to address is msg.sender");

			//Failure
			await contract.mint("https...1").should.be.rejected;
		});
	});

	describe("indexing", async () => {
		it("lists CryptoMonkeyz", async () => {
			await contract.mint("https...2");
			await contract.mint("https...3");
			await contract.mint("https...4");
			const totalSupply = await contract.totalSupply();
			let result = [];
			let CryptoMonkey;

			for (let i = 1; i <= totalSupply; i++) {
				CryptoMonkey = await contract.cryptoMonkeyz(i - 1);
				result.push(CryptoMonkey);
			}

			const expect = ["https...1", "https...2", "https...3", "https...4"];
			assert.equal(result.join(","), expect.join(","));
		});
	});
});
