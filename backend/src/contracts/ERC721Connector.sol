// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './ERC721Enummerable.sol';

contract ERC721Connector is ERC721Enummerable{
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {

    }
}