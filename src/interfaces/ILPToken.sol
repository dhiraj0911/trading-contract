// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

interface ILPToken {
    function mint(address to, uint amount) external;

    function burnFrom(address account, uint256 amount) external;

    function totalSupply() external view returns(uint256);
}
