pragma solidity 0.8.15;

import "forge-std/Test.sol";
import {Constants} from '../script/Utils/Constants.arbitrum.goerli.sol';
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin/proxy/transparent/ProxyAdmin.sol";
import {Pool, TokenWeight} from "../src/pool/Pool.sol";
import {LiquidityRouter} from "../src/pool/LiquidityRouter.sol";
import {PoolHook} from "../src/hooks/PoolHook.sol";
import {PriceReporter} from "../src/keeper/PriceReporter.sol";
import {TradeExecutor} from "../src/keeper/TradeExecutor.sol";
import {RwaxOracle} from "../src/oracle/RwaxOracle.sol";
import {OrderManager} from "../src/orders/OrderManager.sol";
import {ETHUnwrapper} from "../src/orders/ETHUnwrapper.sol";
import {LPToken} from "../src/tokens/LPToken.sol";
import {OrderHook} from "../src/orders/OrderHook.sol";
import {FeeDistributor} from "../src/pool/FeeDistributor.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {Index} from "../src/index/Index.sol";

contract Base is Test {

    address public blackLister;
    address public alice;
    address public bob;
    address public deployer;
    address public executor;
    address public eoaReporter;

    ProxyAdmin public proxyAdmin;
    Pool public liquidityPool;
    LiquidityRouter public router;
    PoolHook public poolHook;

    LPToken public seniorTranch;
    LPToken public juniorTranch;
    LPToken public middleTranch;

    ETHUnwrapper public ethUnwrapper;
    OrderManager public orderManager;
    OrderHook    public orderHook;

    PriceReporter public priceReporter;
    TradeExecutor public tradeExecutor;
    
    RwaxOracle public rwaxOracle;
    FeeDistributor public feeDistributor;

    MockERC20 public usdc;
    Index public index1;

    //Pay token
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    mapping(address => uint256) public pKey;

    function setUp() public virtual{

        __labelAddress();
        vm.startPrank(deployer);
        __deployContracts();
        vm.stopPrank();

        vm.startPrank(eoaReporter);
        __initTokenPrices();
        vm.stopPrank();
    }

    function __labelAddress() internal {
        uint256 privateKey;
        (alice, privateKey) =  makeAddrAndKey("alice");
        pKey[alice] = privateKey;
        vm.deal(alice, 1 ether);

        (blackLister, privateKey) =  makeAddrAndKey("blackLister");
        pKey[blackLister] = privateKey;
        vm.deal(blackLister, 1 ether);
        
        (bob, privateKey) = makeAddrAndKey("bob");
        pKey[bob] = privateKey;
        vm.deal(bob, 1 ether);
        
        (deployer, privateKey) = makeAddrAndKey("deployer");
        pKey[deployer] = privateKey;
        vm.deal(deployer, 1 ether);
        
        (executor, privateKey) = makeAddrAndKey("executor");
        pKey[executor] = privateKey;
        vm.deal(executor, 1 ether);
        
        (eoaReporter, privateKey) = makeAddrAndKey("eoaReporter");
        pKey[eoaReporter] = privateKey;
        vm.deal(eoaReporter, 1 ether);
    }

    function __deployContracts() internal {

        __deployMockTokens();
        __deployProxyAdmin();
        __deployOracle();
        __deployEthUnwrapper();
        __deployOrderManager();
        ///@dev Deploy referral once referral tokenomics is finalized
        //__deployReferralController(); 
        __deployOrderHook();
        __deployLiquidityPool();
        __deployLiquidityPoolHook();
        __deployLiquidityRouter();
        __deployTranches();
        __deployKeepers();
        __deployfeeDistributor();
    }

    /// newAdd
    function __deployMockTokens() internal {
        usdc = new MockERC20("Circle USD", "USDC", 6);
        index1 = new Index();
    }

    function __deployProxyAdmin() internal {
        proxyAdmin = new ProxyAdmin(); // Deploy proxy Admin
    }

    function __deployOracle() internal {

        rwaxOracle = new RwaxOracle();

        ///@dev This will change based on New oracle from Redstone or API3
        ///@dev This can be overwritten by simply calling this api again. So, No issue.
        rwaxOracle.configToken(address(usdc), 
                           Constants.USDC_DECIMALS,
                           Constants.USDC_PRICE_FEED,
                           Constants.USDC_PRICE_FEED_DECIMALS,
                           Constants.USDC_CHAINLINK_TIMEOUT,
                           Constants.USDC_CHAINLINK_DEVIATION);
        /// newAdd
        rwaxOracle.configToken(address(index1), 
                    Constants.INDEX_1_DECIMALS,
                    Constants.INDEX_1_PRICE_FEED,
                    Constants.INDEX_1_PRICE_FEED_DECIMALS,
                    Constants.INDEX_1_CHAINLINK_TIMEOUT,
                    Constants.INDEX_1_CHAINLINK_DEVIATION);

    }

    function __deployEthUnwrapper() internal {
        ethUnwrapper = new ETHUnwrapper(Constants.WETH);
    }

    function __deployOrderManager() internal {

        OrderManager orderManagerImpl = new OrderManager(); // Deploy Implementation contracts

        // Deploy Proxy calling initialize as well
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(orderManagerImpl),
            address(proxyAdmin),
            new bytes(0));

        // Cast proxy to orderManager   
        orderManager = OrderManager(payable(address(proxy)));

        orderManager.initialize(Constants.WETH, 
                                address(rwaxOracle), 
                                Constants.MIN_PERPETUAL_EXECUTION_FEE,
                                address(ethUnwrapper));

        orderManager.setOracle(address(rwaxOracle));
        orderManager.setMinExecutionFee(Constants.MIN_PERPETUAL_EXECUTION_FEE, Constants.MIN_SWAP_EXECUTION_FEE);
        //orderManager.updateOrderHookReferral(referralController);
    }

    function __deployOrderHook() internal {
        orderHook = new OrderHook(address(orderManager),
                                  address(0));

        orderManager.setOrderHook(address(orderHook));
        
    }

    function __deployLiquidityPool() internal {

        Pool pool = new Pool(); // Deploy Implementation contracts

        // Deploy Proxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(pool),
            address(proxyAdmin),
            new bytes(0));

        // Cast proxy to pool
        liquidityPool = Pool(address(proxy));
        liquidityPool.initialize();
        // Initializing 
        liquidityPool.setMaxLeverage(Constants.MAX_LEVERAGE);
        liquidityPool.setMaintenanceMargin(Constants.MAINTENANCE_MARGIN);

        /** 
         * @dev Fees in Level:
         *           Position Fees: 1e8
         *           Liquidation Fees: 5e30
         *           Base Swap Fees: 0.25e8
         *           Tax Basis Point: 0.4e8
         *           Stable Coin Base Swap Fees: 1e6
         *           Stable Coin Tax Basis Point: 5e6
         *           DAO Fees: 0.55e10
         *           Interest Rate: 0.1e7
         *           Maintenance Margin: 1e8
         *           Max Leverage: 55
         * 
                Fees in RWAX:
         *           Position Fees: 1e8
         *           Liquidation Fees: 10e30
         *           Base Swap Fees: 1e8
         *           Tax Basis Point: 1e8
         *           Stable Coin Base Swap Fees: 1e8
         *           Stable Coin Tax Basis Point: 1e8
         *           DAO Fees: 1e10
         *           Interest Rate: 1e7
         *           Maintenance Margin: 5e8
         *           Max Leverage: 3
         * 
        */
        liquidityPool.setPositionFee(Constants.POSITION_FEE, Constants.LIQUIDATION_FEE);
        liquidityPool.setInterestRate(Constants.INTEREST_RATE, Constants.ACCRUAL_INTERVAL);
        liquidityPool.setSwapFee(Constants.BASE_SWAP_FEE,
            Constants.STABLE_BASE_SWAP_FEE,
            Constants.TAX_BASIS_POINT,
            Constants.STABLE_TAX_BASIS_POINT);
        
        ///@dev ADD REMOVE LIQUIDITY FEE in LEVEL: 20000000
        ///@dev ADD REMOVE LIQUIDITY FEE in RWAX : 10000000
        liquidityPool.setAddRemoveLiquidityFee(Constants.ADD_REMOVE_LIQUIDITY_FEE);
        liquidityPool.setDaoFee(Constants.DAO_FEE);

        // Linking
        liquidityPool.setOracle(address(rwaxOracle));
        liquidityPool.setOrderManager(address(orderManager));
        // Setting Tokens
        liquidityPool.addToken(address(usdc), true);
        
        /// @dev Skip This for stables
        //liquidityPool.setRiskFactor(Constant.USDC, address(usdc)_RISK_CONFIG);

        ///@dev set Risk factor for index Tokens, This is important for reserver asset calculations
        /// newAdd
        TokenWeight[] memory config = new TokenWeight[](1);
        config[0] = TokenWeight({token: address(usdc), weight: 1000});
        liquidityPool.setTargetWeight(config);

        // Setting Max Short Size and Max long size for an index
        liquidityPool.addToken(address(index1), false);
        liquidityPool.setMaxGlobalShortSize(address(index1), Constants.MAX_SHORT_SIZE_INDEX_1);
        liquidityPool.setMaxGlobalLongSizeRatio(address(index1), Constants.MAX_LONG_SIZE_RATIO_INDEX_1);

        orderManager.setPool(address(liquidityPool));
    }

    function __deployfeeDistributor() internal {

        feeDistributor = new FeeDistributor(address(liquidityPool));

        ///@dev Set tokens for fees distributor

        liquidityPool.setFeeDistributor(address(feeDistributor));
    }

    function __deployLiquidityPoolHook() internal {

        //Deploying Pool Hook
        poolHook = new PoolHook(address(liquidityPool));

        /** 
         * @dev Params in Level:
         *           Position Size Multiplier: 100
         *           Stable Swap Size Multiplier: 5
         *           Swap Size Multiplier: 100
         * 
                Params in RWAX:
         *           Position Size Multiplier: 500
         *           Stable Swap Size Multiplier: 100
         *           Swap Size Multiplier: 200
         * 
        */
        poolHook.setMultipliers(Constants.POSITION_SIZE_MULTIPLIER,
                                Constants.SWAP_SIZE_MULTIPLIER,
                                Constants.STABLE_SWAP_SIZE_MULTIPLIER);
        /// newAdd
        //poolHook.setReferralController(Constants.REFERRAL_CONTROLLER);

        //liquidityPool.setPoolHook(address(poolHook));

        ///@dev TODO Set LYToken here
        //poolHook.setLyRWAX(Constants.LOYALTY_TOKEN_RWAX);
    }

    function __deployLiquidityRouter() internal {
        router = new LiquidityRouter(address(liquidityPool), address(Constants.WETH));
    }

    function __deployTranches() internal {
        seniorTranch = new LPToken("RWAX_GOLD", "RWAX_GL", address(liquidityPool) );
        middleTranch = new LPToken("RWAX_SILVER", "RWAX_SL", address(liquidityPool));
        juniorTranch = new LPToken("RWAX_BRONZE", "RWAX_BR", address(liquidityPool));

        /// newAdd
        liquidityPool.addTranche(address(seniorTranch));
        liquidityPool.addTranche(address(middleTranch));
        liquidityPool.addTranche(address(juniorTranch));

        /// newAdd
        Pool.RiskConfig[] memory riskConfig = new Pool.RiskConfig[](1);
        riskConfig[0] = Pool.RiskConfig(address(seniorTranch), 1000);
        liquidityPool.setRiskFactor(address(index1), riskConfig);
    }

    function __deployKeepers() internal {

        priceReporter = new PriceReporter(address(rwaxOracle),address(orderManager));
        tradeExecutor = new TradeExecutor(address(liquidityPool), address(priceReporter));
        /// newAdd
        priceReporter.addReporter(eoaReporter);

        address[] memory feeTokens = new address[](1);
        feeTokens[0] = address(usdc);

        tradeExecutor.updateFeeTokens(feeTokens);
        orderManager.setExecutor(address(priceReporter));
        rwaxOracle.addReporter(address(priceReporter));
    }

    function __initTokenPrices() internal {

        address[] memory tokens = new address[](2);
        tokens[0] =  address(usdc);
        tokens[1] =  address(index1);

        uint256[] memory prices = new uint256[](2);
        prices[0] =  1e6;
        prices[1] =  2e6; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, prices, new uint256[](0));
    }
}