// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '../interfaces/IERC721Receiver.sol';

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}