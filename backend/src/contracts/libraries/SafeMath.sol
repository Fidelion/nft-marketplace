// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeMath {
    
    function add(uint x, uint y) internal pure returns (uint256) {
        uint256 r = x + y;
        require(r >= x, "SafeMath: Addition Overflow");
        return r;
    }

    function subtract(uint x, uint y) internal pure returns(uint256) {
        uint r = x - y;
        require(y <= x, "SafeMath: Subtraction Overflow");
        return r;
    }
}