// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProfileNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIds;
    mapping(address => User) public addressToUser;

    struct User {
        address userAddress; // instead of to (Lens Protocol)
        string nickname; // instead of handle (Lens Protocol)
        string imageURI;
        bool isUser; // added
        address followModule; // to check Lens Protocol or change
        bytes followModuleData; // to check Lens Protocol or change
        string followNFTURI; // to check Lens Protocol or change
    }

    constructor() ERC721("ProfileNFT", "PRF") {}

    function awardProfileNFT(string memory tokenURI) public returns (uint256) {
        require(!addressToUser[msg.sender].isUser);
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function setNickname(string memory _nickname) external OnlyUsers {
        addressToUser[msg.sender].nickname = _nickname;
    }

    function setImageURI(string memory _imageURI) external OnlyUsers {
        addressToUser[msg.sender].imageURI = _imageURI;
    }

    function setFollowNFTURI(string memory _followNFTURI) external OnlyUsers {
        addressToUser[msg.sender].followNFTURI = _followNFTURI;
    }

    modifier OnlyUsers() {
        require(addressToUser[msg.sender].isUser);
        _;
    }
}
