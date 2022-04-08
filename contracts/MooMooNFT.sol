//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract MooMooNFT is ERC721URIStorage, Ownable {
    IERC20 GrassToken;
    struct MooMoo {
        string name; //
        uint16 eye; //ipfs
        uint16 ear; //ipfs
        uint16 mouth; //ipfs
        uint16 tail; //ipfs
        uint16 star;
        uint16 breed;
        uint256 winCount;
        uint256 lossCount;
        uint256 parent1Id;
        uint256 parent2Id;

        //TODO battleTimeReady, breedingTimeReady
    }
    uint256 mintFee;
    uint256 breedFee;
    uint256 maxBreed;
    uint256 coolDownBattle;
    uint256 coolDownBreed;

    MooMoo[] public moomoos;
    uint256 public tokenCounter;

    constructor(address token) ERC721("MooMoo", "MOO") {
        tokenCounter = 0;
        maxBreed = 5;
        coolDownBattle = 1 minutes;
        coolDownBreed = 1 hours;
        GrassToken = IERC20(token);
        mintFee = 1000;
        breedFee = 1000;
    }

    function mintOrigin(address to) public {
        require(
            GrassToken.balanceOf(to) >= mintFee,
            "MooMooNFT: Not enough balance to mint origin"
        );
        console.log("transferFrom", to, "to", owner());
        GrassToken.transferFrom(to, owner(), mintFee);
        _mint(to, tokenCounter);

        uint256 random = _getRandom();
        uint16 eye = uint16(random % 100);
        uint16 ear = uint16((random / 100) % 100);
        uint16 mouth = uint16((random / 10000) % 100);
        uint16 tail = uint16((random / 1000000) % 100);
        moomoos.push(MooMoo("NoName", eye, ear, mouth, tail, 1, 0, 0, 0, 0, 0));

        // TODO setTokenURI
        console.log(
            "A origin is mint with id = %s to account %s",
            tokenCounter,
            to
        );
        console.log("eye %s ear %s mouth %s ", eye, ear, mouth);
        console.log("tail %s", tail);
        tokenCounter++;
    }

    function breed(uint256 mooMoo1Id, uint256 mooMoo2Id)
        public
        isOwner(mooMoo1Id)
        isOwner(mooMoo2Id)
    {
        require(
            GrassToken.balanceOf(msg.sender) > breedFee,
            "MooMooNFT: Not enough balance to breed"
        );

        require(
            moomoos[mooMoo1Id].breed < maxBreed ||
                moomoos[mooMoo2Id].breed < maxBreed,
            "MooMooNFT: Maximum breeding"
        );
        // TODO require(); not time to breed

        GrassToken.transferFrom(msg.sender, owner(), mintFee);
        _mint(msg.sender, tokenCounter);

        //50% from mom, 50% from dad
        uint256 random = _getRandom();
        uint16 randomEye = uint16(random % 2);
        uint16 randomEar = uint16((random / 4) % 2);
        uint16 randomMouth = uint16((random / 8) % 2);
        uint16 randomTail = uint16((random / 16) % 2);
        uint16 eye = moomoos[mooMoo1Id].eye *
            randomEye +
            moomoos[mooMoo2Id].eye *
            (1 - randomEye);
        uint16 ear = moomoos[mooMoo1Id].ear *
            randomEar +
            moomoos[mooMoo2Id].ear *
            (1 - randomEar);
        uint16 mouth = moomoos[mooMoo1Id].mouth *
            randomMouth +
            moomoos[mooMoo2Id].mouth *
            (1 - randomMouth);
        uint16 tail = moomoos[mooMoo1Id].tail *
            randomTail +
            moomoos[mooMoo2Id].tail *
            (1 - randomTail);
        moomoos.push(
            MooMoo(
                "NoName",
                eye,
                ear,
                mouth,
                tail,
                1,
                0,
                0,
                0,
                mooMoo1Id,
                mooMoo2Id
            )
        );

        moomoos[mooMoo1Id].breed++;
        moomoos[mooMoo2Id].breed++;

        // TODO setTokenURI
        console.log("A new born MooMoo with id = %s", tokenCounter);
        console.log("eye %s ear %s mouth %s", eye, ear, mouth);
        console.log("tail %s", tail);
        tokenCounter++;
    }

    function _getRandom() internal view returns (uint256) {
        //TODO chainlinkRandom
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            );
    }

    function fight(uint256 myMooMooId, uint256 oppMooMooId)
        public
        isOwner(myMooMooId)
    {
        // TODO require(); not time to fight
        uint256 random = _getRandom() % 10;
        uint256 winner;
        if (moomoos[myMooMooId].star > moomoos[oppMooMooId].star) {
            if (random < 7) {
                winner = myMooMooId;
            } else {
                winner = oppMooMooId;
            }
        } else if (moomoos[myMooMooId].star == moomoos[oppMooMooId].star) {
            if (random < 5) {
                winner = myMooMooId;
            } else {
                winner = oppMooMooId;
            }
        } else {
            if (random < 3) {
                winner = myMooMooId;
            } else {
                winner = oppMooMooId;
            }
        }
        if (winner == myMooMooId) {
            moomoos[myMooMooId].winCount++;
            moomoos[oppMooMooId].lossCount++;
        } else if (winner == oppMooMooId) {
            moomoos[myMooMooId].lossCount++;
            moomoos[oppMooMooId].winCount++;
        }
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
            uint256 lossCount,
            uint256 parent1Id,
            uint256 parent2Id
        )
    {
        MooMoo memory mooMoo = moomoos[mooMooId];
        return (
            mooMoo.name,
            mooMoo.eye,
            mooMoo.ear,
            mooMoo.mouth,
            mooMoo.tail,
            mooMoo.star,
            mooMoo.breed,
            mooMoo.winCount,
            mooMoo.lossCount,
            mooMoo.parent1Id,
            mooMoo.parent2Id
        );
    }

    modifier isOwner(uint256 mooMooId) {
        require(
            ownerOf(mooMooId) == msg.sender,
            "MooMooNFT: Not owner of this MooMoo"
        );
        _;
    }
}
