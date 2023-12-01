
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IPriceFeed {
    function postPrices(address[] calldata tokens, uint256[] calldata prices) external;
}