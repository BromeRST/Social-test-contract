// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./Social.sol";

contract LikeDislikeComments is Social {
    function addLike(uint256 _postId, address _postOwner) external payable {
        lotrtoken.transferFrom(msg.sender, _postOwner, 10);
        addressToPost[_postOwner][_postId].likeRecived++;
    }

    function addDislike(uint256 _postId, address _postOwner) external payable {
        lotrtoken.transferFrom(msg.sender, address(this), 10);
        addressToPost[_postOwner][_postId].dislikeRecived++;
    }

    function addComment(
        uint256 _postId,
        address _postOwner,
        string memory _comment
    ) external payable {
        lotrtoken.transferFrom(msg.sender, _postOwner, 10);
        addressToPost[_postOwner][_postId].comments.push(_comment);
    }
}

//likes and dislike should have an array for every address that liked and disliked?

//comments should be a struct with address sender and string comment probably
