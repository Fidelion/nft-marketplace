// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './ERC165.sol';
import './interfaces/IERC721.sol';
import './interfaces/IERC721Receiver.sol';
import './utils/Strings.sol';
import './interfaces/IERC721Metadata.sol';
import './libraries/Counters.sol';

contract ERC721 is IERC721, ERC165, IERC721Metadata {
    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    constructor(string memory name_, string memory symbol_) {
        _registerInterface(bytes4(keccak256('balanceOf(bytes4)')^keccak256('ownerOf(bytes4)')^
        keccak256('safeTransferFrom(bytes4)')^keccak256('safeTrasnferFrom(bytes4)')^
        keccak256('transferFrom(bytes4)')^keccak256('approve(bytes4)')^
        keccak256('setApprovalForAll(bytes4)')^keccak256('getApproved(bytes4)')^
        keccak256('isApprovedForAll(bytes4)')));
        
        _name = name_;
        _symbol = symbol_;
    }

    string private _name;
    string private _symbol;

    mapping(uint => address) private _tokenOwner;
    mapping(address => Counters.Counter) private _ownedTokens;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    function name() external view override returns(string memory) {
        return _name;
    }

    function symbol() external view override returns(string memory) {
        return _symbol;
    }

    function _exists(uint tokenId) internal view returns(bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0); 
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _mint(address to, uint tokenId) internal virtual{
        require(to != address(0), 'ERC721: minting to zero address');
        require(!_exists(tokenId), 'ERC721: token already exists');
        _tokenOwner[tokenId] = to;
        _ownedTokens[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0), 'Address receiving token does not exist or is not correct');
        require(_tokenOwner[_tokenId] == _from, 'Sender address does not own this token');
        // require(ownerOf(_tokenId) == _from, 'Sender address does not own this token');
        //add tokenId to the address receiving the token
        _tokenOwner[_tokenId] = _to;

        //update the balance of the address _from
        _ownedTokens[_from].decrement();

        //update the balance of the address _to
        _ownedTokens[_to].increment();

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(address(0), _to, _tokenId);
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _transferFrom(_from, _to, _tokenId);
    }

    function balanceOf(address _owner) public view override returns(uint256) {
        require(_owner != address(0), 'ERC721: NFT assigned to zero address');
        return _ownedTokens[_owner].current();
    }

    function ownerOf(uint256 _tokenId) public view override returns(address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'ERC721: Token at this address does not exist');
        return owner;
    }

    function approve(address _to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        //require that the user approving is the owner
        require(msg.sender == owner, 'Current caller is not the owner of the contract');

        // require that the owner is not approving token to himself
        require(_to != owner, 'Approval of tokens to current owner is not allowed');

        //approve the tokenId and address
        _tokenApprovals[tokenId] = _to;

        emit Approval(owner, _to, tokenId);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        require(_exists(tokenId), 'Token does not exist');
        address owner = ownerOf(tokenId);
        return(spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        // return the address of the tokenId within the mapping
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address to) public view override returns (bool) {
        return _operatorApprovals[owner][to];
    }

     function setApprovalForAll(address to, bool approved) public virtual override{
        require(to != msg.sender, "ERC721: approve to caller");

        // set the mapping to the sender approving the transfer and the future owner to approved
        _operatorApprovals[msg.sender][to] = approved;

        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public virtual override {
        require(isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        approve(address(0), tokenId);

        _ownedTokens[owner].decrement();
        delete _tokenOwner[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}