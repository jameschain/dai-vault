var Vault = artifacts.require("Vault");

module.exports = function(deployer) {
    deployer.deploy(Vault, "0xaD6D458402F60fD3Bd25163575031ACDce07538D");
};