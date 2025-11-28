// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title BlockMint — simple mint + transfer example
/// @notice Minimal contract demonstrating minting, transferring and querying ownership
contract Project {
    string public constant PROJECT_NAME = "BlockMint";
    address public owner;
    uint256 private _nextTokenId = 1;

    // tokenId => owner address
    mapping(uint256 => address) private _tokenOwner;
    // owner => list of tokenIds owned (helps simple enumeration)
    mapping(address => uint256[]) private _ownedTokens;

    event Mint(address indexed to, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Mint a new token to `to`. Anyone can call this in the minimal example.
    /// @param to recipient address
    /// @return tokenId the minted token id
    function mint(address to) external returns (uint256 tokenId) {
        require(to != address(0), "Cannot mint to zero address");

        tokenId = _nextTokenId;
        _nextTokenId += 1;

        _tokenOwner[tokenId] = to;
        _ownedTokens[to].push(tokenId);

        emit Mint(to, tokenId);
    }

    /// @notice Transfer `tokenId` from sender to `to`.
    /// @dev Sender must be current owner of the token.
    /// @param tokenId the token to transfer
    /// @param to recipient address
    function transfer(uint256 tokenId, address to) external {
        address from = _tokenOwner[tokenId];
        require(from != address(0), "Token does not exist");
        require(msg.sender == from, "Only token owner can transfer");
        require(to != address(0), "Cannot transfer to zero address");

        // remove token from previous owner's list
        _removeTokenFromOwnerEnumeration(from, tokenId);

        // assign to new owner
        _tokenOwner[tokenId] = to;
        _ownedTokens[to].push(tokenId);

        emit Transfer(from, to, tokenId);
    }

    /// @notice Get owner of a token id
    /// @param tokenId token id
    /// @return tokenOwner address
    function ownerOf(uint256 tokenId) external view returns (address tokenOwner) {
        tokenOwner = _tokenOwner[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
    }

    /// @notice Returns token ids owned by an address (simple enumeration)
    /// @param account address to query
    /// @return tokens array of token ids
    function tokensOfOwner(address account) external view returns (uint256[] memory tokens) {
        return _ownedTokens[account];
    }

    /* ---------- Internal helpers ---------- */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {
        uint256[] storage list = _ownedTokens[from];
        uint256 length = list.length;
        for (uint256 i = 0; i < length; ++i) {
            if (list[i] == tokenId) {
                // swap with last and pop
                if (i != length - 1) {
                    list[i] = list[length - 1];
                }
                list.pop();
                break;
            }
        }
    }
}

