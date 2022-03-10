// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './ERC721Connector.sol';

contract CryptoMonkey is ERC721Connector {

    string[] public cryptoMonkeyz;

    mapping(string => bool) _cryptoMonkeyzExists;

    function mint(string memory _cryptoMonkey) public {
        // Depricated (push no longer returns the length but the reference of the added element)
        // uint _id =  cryptoMonkeyz.push(_cryptoMonkey);

        require(!_cryptoMonkeyzExists[_cryptoMonkey], 'Error: cryptoMonkey already exists');
        cryptoMonkeyz.push(_cryptoMonkey);
        uint _id = cryptoMonkeyz.length - 1;        
        _mint(msg.sender, _id);

        _cryptoMonkeyzExists[_cryptoMonkey] = true;
    }

    constructor() ERC721Connector('CryptoMonkeyz', 'CMNKZ'){}
}