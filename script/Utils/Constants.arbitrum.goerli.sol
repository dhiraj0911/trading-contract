// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library Constants {

    struct RiskConfig {
        address tranche;
        uint256 riskFactor;
    }

    //Public addreses to be used 
    address public constant WETH = 0xEe01c0CD76354C383B8c7B4e65EA88D00B06f36f;
    address public constant EOA_REPORTER = 0xF437d5dc8bCb4b75611F73ee4DBf89C995fbeC8D;
    
    ///@dev Populate these based opn Arbitrum Vaules
    address public constant USDC = 0x179522635726710Dd7D2035a81d856de4Aa7836c;
    address public constant USDC_PRICE_FEED = WETH;
    uint256 public constant USDC_PRICE_FEED_DECIMALS = 6;
    uint256 public constant USDC_DECIMALS =  6;
    uint256 public constant USDC_CHAINLINK_TIMEOUT = 600;// Actual value used By LEVEL 
    uint256 public constant USDC_CHAINLINK_DEVIATION = 1000;// Actual value used by LEVEL

    address public constant INDEX_1 = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address public constant INDEX_1_PRICE_FEED = WETH;
    uint256 public constant INDEX_1_PRICE_FEED_DECIMALS = 6;
    uint256 public constant INDEX_1_DECIMALS =  6;
    uint256 public constant INDEX_1_CHAINLINK_TIMEOUT = 600;
    uint256 public constant INDEX_1_CHAINLINK_DEVIATION = 1000;

    address public constant USDT = WETH;
    address public constant USDT_PRICE_FEED = WETH;
    uint256 public constant USDT_PRICE_FEED_DECIMALS = 6;
    uint256 public constant USDT_DECIMALS =  6;
    uint256 public constant USDT_CHAINLINK_TIMEOUT = 600;
    uint256 public constant USDT_CHAINLINK_DEVIATION = 1000;

    address public constant DAI = WETH;
    address public constant DAI_PRICE_FEED = WETH;
    uint256 public constant DAI_PRICE_FEED_DECIMALS = 6;
    uint256 public constant DAI_DECIMALS =  6;
    uint256 public constant DAI_CHAINLINK_TIMEOUT = 600;
    uint256 public constant DAI_CHAINLINK_DEVIATION = 1000;

    // Linkers
    ///@dev Recheck these and change these as per Contracts deployed
    address public constant TRANCHE1 = 0xB5C42F84Ab3f786bCA9761240546AA9cEC1f8821;
    address public constant SENIOR_TRANCH = 0x345Daa8F15777Cd668C283F3865CAc295392f5fE;
    address public constant MIDDLE_TRANCH = 0xFeCcb265529CB45Fe773e52891c79B79399C8B24;
    address public constant JUNIOR_TRANCH = 0x99779364D99711FA635fC5D671c98286DBa6611C;
    address public constant ORACLE = 0x190e9ac3DBd7575C8E84608300480CF14d3F0CA7;
    address public constant ORDER_MANAGER = 0x52924fad59092b82bC3D0859d2A7acE68ff6B61B;
    address public constant POOL_HOOK = TRANCHE1;
    address public constant FEE_DISTRIBUTOR = TRANCHE1;
    address public constant LIQUIDITY_POOL = 0x37341b54a0ae96b8c0bf7467Ad8f1288e0a4f0dC;
    address public constant LIQUIDITY_ROUTER = 0xc7e1c76641790fBA8eF765D95BeFCe7374eAb8d5;
    address public constant ORDER_HOOK = TRANCHE1;
    address public constant ORDER_EXECUTOR = TRANCHE1;
    address public constant PRICE_REPORTER_EOA = 0xF437d5dc8bCb4b75611F73ee4DBf89C995fbeC8D;
    address public constant TRADE_EXECUTOR = 0xFa8Ee9623c8Fd710dF6CE13e7c46f0cfE7BF71F6;
    address public constant LP_TOKEN_MINTER = TRANCHE1;
    address public constant LOYALTY_TOKEN_RWAX = TRANCHE1;
    address public constant REFERRAL_CONTROLLER = TRANCHE1;
    address public constant INDEX_2 = TRANCHE1;
    address public constant PRICE_REPORTER = 0x962A742bd531eB85E1D0812FF695fc3c63EDCE64;

/**----------------------POOL-------------------------------------------------------------------- */
    uint256 public constant MAX_LEVERAGE = 50;
    uint256 public constant MAINTENANCE_MARGIN = 2e8; // 2%
    uint256 public constant POSITION_FEE = 1e8; // 1%
    uint256 public constant LIQUIDATION_FEE = 5e30; // 5$
    uint256 public constant INTEREST_RATE = 1e6; // 0.01%
    uint256 public constant ACCRUAL_INTERVAL = 3600; // 1 Hour
    uint256 public constant BASE_SWAP_FEE =  25e6; // 0.25%
    uint256 public constant STABLE_BASE_SWAP_FEE =  1e6; // 0.01%
    uint256 public constant TAX_BASIS_POINT =  4e7; // 0.4%
    uint256 public constant STABLE_TAX_BASIS_POINT =  5e6; // 0.05%
    uint256 public constant ADD_REMOVE_LIQUIDITY_FEE = 2e8;
    uint256 public constant DAO_FEE = 55e8;
    /// newAdd
    uint256 public constant MAX_SHORT_SIZE_INDEX_1 = 1e40; // 1e30 is 1USD worth of index
    uint256 public constant MAX_LONG_SIZE_RATIO_INDEX_1 = 95e8; // 0.5
    /**
    RiskConfig public constant USDC_RISK_CONFIG = RiskConfig({
        tranche : TRANCHE1 ,
        riskFactor : 0 // Risk factor is zero for stables
    });
    */

/**----------------------ORDER MANAGER-------------------------------------------------------------------- */

    uint256 public constant MIN_PERPETUAL_EXECUTION_FEE = 35e14;//1e17 is 0.1ETH, Vaule from Level Contracts = 3500000000000000
    uint256 public constant MIN_SWAP_EXECUTION_FEE = 15e14; //1e17; //0.1ETH, Vaule from Level Contracts = 1500000000000000

/**----------------------ORACLE-------------------------------------------------------------------- */

    address public constant ORACLE_REPORTER = TRANCHE1;

/**----------------------KEEPERS-------------------------------------------------------------------- */
    address public constant FEE_TOKEN_1 = TRANCHE1;
    address public constant FEE_TOKEN_2 = TRANCHE1;

    
/**----------------------POOL HOOK-------------------------------------------------------------------- */

    uint256 public constant POSITION_SIZE_MULTIPLIER = 500;
    uint256 public constant SWAP_SIZE_MULTIPLIER = 100;
    uint256 public constant STABLE_SWAP_SIZE_MULTIPLIER = 200;
}


