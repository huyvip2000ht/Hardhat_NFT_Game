//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MooMooNFT.sol";

contract MisteryBox is Ownable {
    MooMooNFT mooMooNFT;

    enum Rarety {
        BRONZE,
        SILVER,
        GOLD
    }

    constructor(address nft) {
        mooMooNFT = MooMooNFT(nft);
    }

    function buyMisteryBox() public {}

    function openMisteryBox() public {}
}
