pragma solidity 0.8.15;

import {Base} from "../Base.t.sol";
import "forge-std/Test.sol";
import "../../src/orders/OrderManager.sol";
import {Constants} from '../../script/Utils/Constants.arbitrum.goerli.sol';
import "forge-std/console.sol";

contract OrderManagerTest is Test, Base {

    function setUp() public virtual override {
        super.setUp();
        _dealUSDC(alice, 1000000e6); // Dealing 1000 USDC to Alice
        _dealUSDC(bob, 1000000e6 ); 
        _addLiquidity(alice, 1000000e6 );
        _addLiquidity(bob, 1000000e6);
        _dealUSDC(alice, 1000000e6); // Dealing 1000 USDC to Alice
        _dealUSDC(bob, 1000000e6 ); 
        _addIncreaseOrders();

    }

    function _dealUSDC(address addr, uint256 amount) internal {

        vm.startPrank(addr);
        usdc.mint(amount);
        vm.stopPrank();
    }

    function testAddOrder() public {

        /**
        (order.price, order.payToken, purchaseAmount, request.sizeChange, request.collateral, extradata) =
            abi.decode(_data, (uint256, address, uint256, uint256, uint256, bytes));
        */
        vm.startPrank(alice);
        
        usdc.approve(address(orderManager), type(uint256).max);
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.INCREASE,
            Side.LONG,
            address(index1),
            address(usdc),
            OrderType.MARKET,
            abi.encode(2e24, address(usdc), 2e7, 4e31, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );
        vm.stopPrank();
    }

    function _addLiquidity(address addr, uint256 amount) internal {

        vm.startPrank(addr);
        usdc.approve(address(router), type(uint256).max);
        router.addLiquidity(address(seniorTranch), address(usdc), amount, 0, alice); 
        vm.stopPrank();
    }

    function testExecuteIncreaseOrder() public {
        
        vm.roll(100);
        vm.startPrank(eoaReporter);

        uint256[] memory orders = new uint256[](2);
        orders[0] = 1;
        orders[1] = 3;

        address[] memory tokens = new address[](2);
        tokens[0] =  address(usdc);
        tokens[1] =  address(index1);

        uint256[] memory prices = new uint256[](2);
        prices[0] =  1e6;
        prices[1] =  2e6; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, prices, orders );

        uint256[] memory newOrders = new uint256[](2);
        newOrders[0] = 2;
        newOrders[1] = 4;

        uint256[] memory newPrices = new uint256[](2);
        newPrices[0] =  1e6;
        newPrices[1] =  21e5; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, newPrices, newOrders );

        vm.stopPrank();
    }

    function _addIncreaseOrders() internal {


        vm.startPrank(alice);
        
        usdc.approve(address(orderManager), type(uint256).max);
        // Alice puts Market Long Order
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.INCREASE,
            Side.LONG,
            address(index1),
            address(usdc),
            OrderType.MARKET,
            abi.encode(2e24, address(usdc), 2e7, 4e31, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );
        // ALICE Puts Limit Long Order
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.INCREASE,
            Side.LONG,
            address(index1),
            address(usdc),
            OrderType.LIMIT,
            abi.encode(21e23, address(usdc), 2e7, 42e30, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );
        vm.stopPrank();

        // Bob puts market short order
        vm.startPrank(bob);
        
        usdc.approve(address(orderManager), type(uint256).max);
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.INCREASE,
            Side.SHORT,
            address(index1),
            address(usdc),
            OrderType.MARKET,
            abi.encode(2e24, address(usdc), 2e7, 4e31, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );

        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.INCREASE,
            Side.SHORT,
            address(index1),
            address(usdc),
            OrderType.LIMIT,
            abi.encode(21e23, address(usdc), 2e7, 42e30, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );
        vm.stopPrank();
    }

    function testExecuteDecreaseOrders() public {
        testExecuteIncreaseOrder();

        _addDecreaseOrders();
        vm.roll(1000);
        vm.startPrank(eoaReporter);

        uint256[] memory orders = new uint256[](1);
        orders[0] = 5;

        address[] memory tokens = new address[](2);
        tokens[0] =  address(usdc);
        tokens[1] =  address(index1);

        uint256[] memory prices = new uint256[](2);
        prices[0] =  1e6;
        prices[1] =  2e6; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, prices, orders );

        uint256[] memory newOrders = new uint256[](1);
        newOrders[0] = 6;

        uint256[] memory newPrices = new uint256[](2);
        newPrices[0] =  1e6;
        newPrices[1] =  21e5; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, newPrices, newOrders );

        vm.stopPrank();
    }

    function _addDecreaseOrders() internal{

        vm.startPrank(alice);
        
        usdc.approve(address(orderManager), type(uint256).max);
        // Alice puts Market Long Order
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.DECREASE,
            Side.LONG,
            address(index1),
            address(usdc),
            OrderType.MARKET,
            abi.encode(2e24, address(usdc), 4e31, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );
        vm.stopPrank();

        vm.startPrank(bob);
        // ALICE Puts Limit Long Order
        orderManager.placeOrder{value: 1e17}(
            UpdatePositionType.DECREASE,
            Side.SHORT,
            address(index1),
            address(usdc),
            OrderType.LIMIT,
            abi.encode(21e23, true, address(usdc), 42e30, 2e7, bytes(""))
            // Normalized Price of 1 USDC = 1e24
            // Person is opening 1 Index Position, so USDC required = 20 as price of index = 2usdc
        );

        vm.stopPrank();
    }
}