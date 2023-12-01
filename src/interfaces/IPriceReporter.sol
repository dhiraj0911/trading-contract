// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IPriceReporter {
    function postPriceAndExecuteOrders(address[] calldata tokens, uint256[] calldata prices, uint256[] calldata orders)
        external;

    function executeSwapOrders(uint256[] calldata orders) external;
}