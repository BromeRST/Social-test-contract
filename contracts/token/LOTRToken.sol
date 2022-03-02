// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LOTRToken is ERC20, Ownable {
    uint256 public token;
    address public social;

    constructor(address _social) ERC20("Lord of the Rings", "LOTR") {
        social = _social;
    }

    function mint() external payable {
        require(msg.value >= 0.0001 ether, "not enough ethers");
        _mint(msg.sender, msg.value * 2000000);
        (bool success, ) = social.call{value: msg.value}("");
        require(success);
    }
}
