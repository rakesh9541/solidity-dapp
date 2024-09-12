const networkConfig = {
    11155111: {
        name: "sepolia",
        ethUsdPriceFeed: "adsressaddress",
    },
    137: {
        name: "polygon",
        ethUsdPriceFeed: adsressadress,
    },
};

const DECIMALS = 8;
const INITIAL_ANSWER = 200000000000; // 2000.00000000 --> 8 decimals

const developmentChains = ["hardhat", "localhost"];

module.exports = { networkConfig, developmentChains, DECIMALS, INITIAL_ANSWER };
