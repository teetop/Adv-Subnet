const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");


module.exports = buildModule("GameModule", (m) => {

  const players = ["0x", "0x", "0x"];

  const game = m.contract("Game", [players]);

  return { game };
});
