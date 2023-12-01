// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

interface IRwaxOracle {
    function getPrice(address token, bool max) external view returns (uint256);
    function getIndexPrice(address token, bool max) external view returns(uint256);
    function getMultiplePrices(address[] calldata tokens, bool max) external view returns (uint256[] memory);
}
