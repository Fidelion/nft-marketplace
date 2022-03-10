// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './interfaces/IERC165.sol';

contract ERC165 is IERC165 {
    constructor() {
        _registerInterface(bytes4(keccak256('supportsInterface(bytes4)')));
    }

    mapping (bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) external view override returns(bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        _supportedInterfaces[interfaceId] = true;
    }

    // function calcKeccak() public view returns(bytes4) {
    //     return bytes4(keccak256('supportsInterface(bytes4)'));
    // }
}