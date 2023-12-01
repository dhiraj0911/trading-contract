// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {IPriceFeed} from "../interfaces/IPriceFeed.sol";
import {IOrderManager} from "../interfaces/IOrderManager.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {SafeERC20, IERC20}  from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IPriceReporter} from "../interfaces/IPriceReporter.sol";
import {IPool, Side} from "../interfaces/IPool.sol";
import {Address} from "openzeppelin/utils/Address.sol";

contract TradeExecutor is Ownable {
    using SafeERC20 for IERC20;

    IPriceReporter private immutable _priceReporter;
    IPool private immutable _pool;

    address[] public feeTokens;

    constructor(address __pool, address __priceReporter) {
        require(__pool != address(0), "Invalid address");
        require(__priceReporter != address(0), "Invalid address");
        _pool = IPool(__pool);
        _priceReporter = IPriceReporter(__priceReporter);
    }

    // =============== USER FUNCTIONS ===============

    function executeOrders(uint256[] calldata _orderIds, uint256[] calldata _swapOrderIds) external {
        if (_orderIds.length != 0) {
            _priceReporter.postPriceAndExecuteOrders(new address[](0), new uint256[](0), _orderIds);
        }
        if (_swapOrderIds.length != 0) {
            _priceReporter.executeSwapOrders(_swapOrderIds);
        }
    }

    function liquidate(address _account, address _indexToken, address _collateralToken, Side _side) external {
        _pool.liquidatePosition(_account, _indexToken, _collateralToken, _side);
    }

    function withdrawFee(address _to) external onlyOwner {
        require(_to != address(0), "Invalid address");
        for (uint256 i = 0; i < feeTokens.length;) {
            IERC20 token = IERC20(feeTokens[i]);
            uint256 balance = token.balanceOf(address(this));
            if (balance != 0) {
                token.safeTransfer(_to, balance);
                emit TokenWithdrawn(address(token), _to, balance);
            }
            unchecked {
                ++i;
            }
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            Address.sendValue(payable(_to), ethBalance);
            emit ETHWithdrawn(_to, ethBalance);
        }
    }

    // =============== RESTRICTED ===============

    function updateFeeTokens(address[] memory _feeTokens) external onlyOwner {
        feeTokens = _feeTokens;
        emit FeeTokensUpdated();
    }

    receive() external payable {}

    /* ========== EVENTS ========== */
    event FeeTokensUpdated();
    event TokenWithdrawn(address indexed _token, address indexed _to, uint256 _amount);
    event ETHWithdrawn(address indexed _to, uint256 _amount);

}