const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const CrowdfundingModule = buildModule("CrowdfundingModule", (m) => {
  const crowdfunding = m.contract("Crowdfunding");

  return { crowdfunding };
});

module.exports = CrowdfundingModule;