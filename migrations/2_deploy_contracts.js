const KebabToken = artifacts.require("KebabToken");
const KetchupBar = artifacts.require("KetchupBar");
const MasterChef = artifacts.require("MasterChef");
let admin = "0xf4F430E3E07270e5Cb272c48685289a8129BA121"

module.exports = function(deployer) {
  // 1st deployment
  deployer.deploy(KebabToken).then(function() {
    return deployer.deploy(KetchupBar, KebabToken.address).then(function() {
      return deployer.deploy(MasterChef, KebabToken.address, KetchupBar.address, admin, "1000000000000000000", 4021488)
    })
  })
};