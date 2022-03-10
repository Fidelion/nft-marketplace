// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721TokenConnector {
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}