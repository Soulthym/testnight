const BambooUpgrader = artifacts.require("BambooUpgrader");

module.exports = function (deployer) {
  deployer.deploy(BambooUpgrader, 30);
};
