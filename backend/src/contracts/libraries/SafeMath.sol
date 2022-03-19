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

    function multiply(uint x, uint y) internal pure returns(uint256) {
        //gas optimization
        if(x == 0) {
            return 0;
        }
        uint r = x * y;
        require(r / x == y, "SafeMath: Multiplication Overflow");
        return r;
    }

    function divide(uint x, uint y) internal pure returns(uint256) {
        require(y > 0, "SafeMath: Multiplication Division");
        uint r = x / y;
        return r;
    }

    function modulo(uint x, uint y) internal pure returns(uint256) {
        require(y != 0, "SafeMath: Multiplication Modulo");       
        return x % y;
    }
}