// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./token/LOTRToken.sol";
import "./ProfileNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* is ProfileNFT, */
contract Social is Ownable {
    uint256 totalPosts;
    uint256 private seed; //for generate random number

    LOTRToken lotrtoken;

    event NewPost(
        address indexed from,
        uint256 postId,
        uint256 timestamp,
        string msg,
        string img
    );

    struct Post {
        address owner;
        string message;
        string image;
        uint256 timestamp;
        uint16 likeRecived;
        uint16 dislikeRecived;
        string[] comments;
    }

    Post[] public posts;

    mapping(address => bool) public isUser;
    mapping(uint256 => address) public postToOwner;
    mapping(address => uint256) public lastPostedAt;
    mapping(address => uint256) public addressTotalPost;

    constructor() {
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function register(address _newUser) external {
        require(!isUser[_newUser]);
        isUser[_newUser] = true;
    }

    function post(string calldata _message, string calldata _imageURI)
        external
        OnlyUsers
    {
        lotrtoken.transferFrom(msg.sender, address(this), 50);
        require(
            lastPostedAt[msg.sender] + 1 minutes < block.timestamp,
            "Wait 1m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastPostedAt[msg.sender] = block.timestamp;

        totalPosts += 1;
        console.log("%s has post!", msg.sender);

        posts.push(
            Post(
                msg.sender,
                _message,
                _imageURI,
                block.timestamp,
                0,
                0,
                new string[](0)
            )
        );

        uint256 postId = posts.length - 1;

        postToOwner[postId] = msg.sender;

        addressTotalPost[msg.sender]++;

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 10% chance that the user wins the prize.
         */
        if (seed <= 10) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewPost(msg.sender, postId, block.timestamp, _message, _imageURI);
    }

    function getAllPosts() external view returns (Post[] memory) {
        return posts;
    }

    function getTotalPosts() external view returns (uint256) {
        return totalPosts;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success);
    }

    function lotraddress(LOTRToken _lotrContractAddress) external onlyOwner {
        lotrtoken = _lotrContractAddress;
    }

    function getPostsByOwner(address _owner)
        external
        view
        OnlyUsers
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](addressTotalPost[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < posts.length; i++) {
            if (postToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    modifier OnlyUsers() {
        require(isUser[msg.sender]);
        _;
    }

    receive() external payable {}
}
