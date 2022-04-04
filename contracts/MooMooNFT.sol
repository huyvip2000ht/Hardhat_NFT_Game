//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MooMooNFT is ERC721URIStorage, Ownable {
    struct MooMoo {
        string name;
        uint16 eye;
        uint16 ear;
        uint16 mouth;
        uint16 tail;
        uint16 star;
        uint16 breed;
        uint256 winCount;
        uint256 lossCount;
    }
    uint256 maxBreed;
    MooMoo[] public moomoos;
    mapping(uint256 => address) moomooToOwner;
    //mapping(uint256 => MooMoo) idToMooMoo;
    uint256 tokenCounter;

    constructor() ERC721("MooMoo", "MOO") {
        tokenCounter = 0;
        maxBreed = 5;
    }

    function mintOrigin(address to) public {
        moomoos.push(MooMoo("NoName", 0, 0, 0, 0, 1, 0, 0, 0));

        moomooToOwner[tokenCounter] = to;

        _mint(to, tokenCounter);

        tokenCounter++;
    }

    function breed(uint256 mooMoo1Id, uint256 mooMoo2Id) public {
        //require(); moomoo1,moomoo2 belong to msg.sender
        require(
            moomoos[mooMoo1Id].breed < maxBreed ||
                moomoos[mooMoo2Id].breed < maxBreed
        );

        moomoos.push(MooMoo("NoName", 0, 0, 0, 0, 1, 0, 0, 0));

        moomooToOwner[tokenCounter] = msg.sender;
        moomoos[mooMoo1Id].breed++;
        moomoos[mooMoo2Id].breed++;
        _mint(msg.sender, tokenCounter);

        tokenCounter++;
    }

    function fight(uint256 mooMoo1Id, uint256 mooMoo2Id) public {
        if (moomoos[mooMoo1Id].star > moomoos[mooMoo1Id].star) {
            // 70%
        } else if (moomoos[mooMoo1Id].star == moomoos[mooMoo1Id].star) {
            // 50%
        } else {
            // 30%
        }
        // moomoo1 win scenario:
        moomoos[mooMoo1Id].winCount++;
        moomoos[mooMoo2Id].lossCount++;
    }

    function getStats(uint256 mooMooId)
        public
        view
        returns (
            string memory name,
            uint16 eye,
            uint16 ear,
            uint16 mouth,
            uint16 tail,
            uint16 star,
            uint16 breed,
            uint256 winCount,
            uint256 lossCount
        )
    {
        MooMoo storage mooMoo = moomoos[mooMooId];
        return (
            mooMoo.name,
            mooMoo.eye,
            mooMoo.ear,
            mooMoo.mouth,
            mooMoo.tail,
            mooMoo.star,
            mooMoo.breed,
            mooMoo.winCount,
            mooMoo.lossCount
        );
    }
}
