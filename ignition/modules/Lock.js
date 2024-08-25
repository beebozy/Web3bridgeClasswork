const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");



module.exports = buildModule("LockModule", (m) => {

  const lock = m.contract("CrowdFunding");

  return { lock };
});

/*const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("TokenModule", (m) => {
  const token = m.contract("Token");

  return { token };
});

module.exports = TokenModule;*/