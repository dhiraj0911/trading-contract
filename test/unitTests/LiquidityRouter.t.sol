pragma solidity 0.8.15;

import {Base} from "../Base.t.sol";
import "forge-std/Test.sol";
import "../../src/orders/OrderManager.sol";
import {Constants} from '../../script/Utils/Constants.arbitrum.goerli.sol';

contract LiquidityRouterTest is Test, Base {

    function setUp() public virtual override {
        super.setUp();
    }

    function testAddLiquidity() public {
        vm.startPrank(alice);
        usdc.mint(1000e6);
        usdc.approve(address(router), type(uint256).max);
        router.addLiquidity(address(seniorTranch), address(usdc), 100e6, 0, alice); // Add 100e6
        assertEq(usdc.balanceOf(alice), 900e6);
        assert(seniorTranch.balanceOf(alice) > 0);
    }
}