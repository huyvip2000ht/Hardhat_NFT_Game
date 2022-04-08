//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MooMooNFT.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/utils/Context.sol";

contract MisteryBox is ERC721, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    MooMooNFT mooMooNFT;
    IERC20 grassToken;
    enum TypeBox {
        BRONZE,
        SILVER,
        GOLD
    }

    mapping(TypeBox => uint256) typeToPrice;
    mapping(uint256 => TypeBox) boxIdToType;

    constructor(address nft, address token) ERC721("MisteryBox", "MBOX") {
        mooMooNFT = MooMooNFT(nft);
        grassToken = IERC20(token);
        typeToPrice[TypeBox.BRONZE] = 300;
        typeToPrice[TypeBox.SILVER] = 1000;
        typeToPrice[TypeBox.GOLD] = 3000;

        //console.log(TypeBox.BRONZE);
    }

    function buyMisteryBox(TypeBox typebox) public {
        require(
            grassToken.balanceOf(msg.sender) >= typeToPrice[typebox],
            "MisteryBox: Not enought token to buy box"
        );

        console.log(typeToPrice[typebox]);
        grassToken.transferFrom(msg.sender, owner(), typeToPrice[typebox]);

        // superior solution
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        boxIdToType[tokenId] = typebox;
    }

    function openMisteryBox(uint256 boxId) public onlyBoxOwner(boxId) {
        burn(boxId);
        mooMooNFT.mintOrigin(_msgSender());
    }

    function getBoxPrice(TypeBox typebox) public view returns (uint256 price) {
        return typeToPrice[typebox];
    }

    function getBoxType(uint256 boxId) public view returns (TypeBox typebox) {
        return boxIdToType[boxId];
    }

    modifier onlyBoxOwner(uint256 boxId) {
        require(ownerOf(boxId) == msg.sender, "MisteryBox: not the owner");
        _;
    }
}
