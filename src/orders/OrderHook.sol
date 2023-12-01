// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {IOrderHook} from "../interfaces/IOrderHook.sol";
import {IReferralController} from "../interfaces/IReferralController.sol";
import {IOrderManager, Order, SwapOrder} from "../interfaces/IOrderManager.sol";

contract OrderHook is IOrderHook {
    address public immutable orderManager;
    IReferralController public referralController;

    modifier onlyOrderManager() {
        _requireOrderManager();
        _;
    }

    constructor(address _orderManager, address _referralController) {
        require(_orderManager != address(0), "invalid address");
        //require(_referralController != address(0), "invalid address");
        orderManager = _orderManager;
        referralController = IReferralController(_referralController);
    }

    function postPlaceOrder(uint256 _orderId, bytes calldata _extradata) external onlyOrderManager {
        if (_extradata.length == 0) {
            return;
        }
        Order memory order = IOrderManager(orderManager).orders(_orderId);
        address referrer = abi.decode(_extradata, (address));
        _setReferrer(order.owner, referrer);
    }

    function postSwap(address _trader, bytes calldata _extradata) external onlyOrderManager {
        if (_extradata.length == 0) {
            return;
        }
        address referrer = abi.decode(_extradata, (address));
        _setReferrer(_trader, referrer);
    }

    function postPlaceSwapOrder(uint256 _swapOrderId, bytes calldata _extradata) external onlyOrderManager {
        if (_extradata.length == 0) {
            return;
        }
        SwapOrder memory order = IOrderManager(orderManager).swapOrders(_swapOrderId);
        address trader = order.owner;
        address referrer = abi.decode(_extradata, (address));
        _setReferrer(trader, referrer);
    }

    function setReferral(address _newReferral) external onlyOrderManager {
        referralController =  IReferralController(_newReferral);
    }

    function _setReferrer(address _trader, address _referrer) internal {
        if (_referrer != address(0)) {
            referralController.setReferrer(_trader, _referrer);
        }
    }

    function _requireOrderManager() internal view {
        require(msg.sender == orderManager, "!orderManager");
    }
}