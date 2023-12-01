// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {IPriceFeed} from "../interfaces/IPriceFeed.sol";
import {IOrderManager} from "../interfaces/IOrderManager.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
/**
 * @title PriceReporter
 * @notice Utility contract to call post prices and execute orders on a single transaction. Used on
 * testnet only
 */
contract PriceReporter is Ownable {
    IPriceFeed private immutable _oracle;
    IOrderManager private immutable _orderManager;
    mapping(address => bool) public isReporter;
    address[] public reporters;

    constructor(address __oracle, address __orderManager) {
        require(__oracle != address(0), "PriceReporter:invalidOracle");
        require(__orderManager != address(0), "PriceReporter:invalidPositionManager");
        _oracle = IPriceFeed(__oracle);
        _orderManager = IOrderManager(__orderManager);
    }

    function postPriceAndExecuteOrders(address[] calldata tokens, uint256[] calldata prices, uint256[] calldata orders)
        external
    {
        require(isReporter[msg.sender], "PriceReporter:unauthorized");
        _oracle.postPrices(tokens, prices);

        for (uint256 i = 0; i < orders.length;) {
            _orderManager.executeOrder(orders[i], payable(msg.sender));
            unchecked {
                ++i;
            }
        }
    }

    function executeSwapOrders(uint256[] calldata orders) external {
        require(isReporter[msg.sender], "PriceReporter:unauthorized");
        if (orders.length > 0) {
            for (uint256 i = 0; i < orders.length; i++) {
                try _orderManager.executeSwapOrder(orders[i], payable(msg.sender)) {} catch {}
            }
        }
    }

    function addReporter(address reporter) external onlyOwner {
        require(reporter != address(0), "PriceReporter:invalidAddress");
        require(!isReporter[reporter], "PriceReporter:reporterAlreadyAdded");
        isReporter[reporter] = true;
        reporters.push(reporter);
    }

    function removeReporter(address reporter) external onlyOwner {
        require(isReporter[reporter], "PriceReporter:reporterNotExists");
        isReporter[reporter] = false;
        for (uint256 i = 0; i < reporters.length; i++) {
            if (reporters[i] == reporter) {
                reporters[i] = reporters[reporters.length - 1];
                break;
            }
        }
        reporters.pop();
    }
}