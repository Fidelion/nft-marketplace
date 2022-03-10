// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './ERC721.sol';
import './interfaces/IERC721Enummerable.sol';

abstract contract ERC721Enummerable is ERC721, IERC721Enummerable{
    constructor() {
        _registerInterface(bytes4(keccak256('totalSupply(bytes4)')^
        keccak256('tokenOfOwnerByIndex(bytes4)')^
        keccak256('tokenByIndex(bytes4)')));
    }
    uint256[] private _allTokens;

    // mapping from tokenId to position in _allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // mapping of owner to list of all owner ids
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _ownedTokensIndex;

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }
 
    //function tokenByIndex(uint256 _index) external view returns (uint256);

    //function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

    function _mint(address to, uint256 tokenId) internal override(ERC721) {
        super._mint(to, tokenId);

        _addTokenToAllTokenEnumeration(tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _addTokenToAllTokenEnumeration(uint256 tokenId) private {
        //Adding tokenId of the current index within allTokensIndex mapping to a length of all tokens array 
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        //1. add address and tokenId to the _ownedTokens
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function tokenByIndex(uint256 index) public view returns(uint256) {
        require(index < totalSupply(), 'Global index is out of bounds');
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint index) public view returns(uint256) {
        require(index < ERC721.balanceOf(owner), 'Owner index is out of bounds');
        return _ownedTokens[owner][index];
    }
} 