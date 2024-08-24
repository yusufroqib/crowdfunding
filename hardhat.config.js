require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.24",
	sourcify: {
		enabled: true,
	},
	networks: {
		sepolia: {
			url: process.env.SEPOLIA_URL,
			accounts: [`0x${process.env.PRIVATE_KEY}`],
		},
	},
	etherscan: {
		apiKey: process.env.ETHER_SCAN_API_KEY,
	},
};

// $ npx hardhat ignition deploy ./ignition/modules/Lock.js --network sepolia --verify
