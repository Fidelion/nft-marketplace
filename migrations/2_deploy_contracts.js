const CryptoMonkey = artifacts.require("CryptoMonkey");

module.exports = function (deployer) {
	deployer.deploy(CryptoMonkey);
};
