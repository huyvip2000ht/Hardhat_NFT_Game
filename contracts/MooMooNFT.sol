//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

        //TODO battleTimeReady, breedingTimeReady
    }
    uint256 mintFee;
    uint256 breedFee;
    uint256 maxBreed;
    uint256 coolDownBattle;
    uint256 coolDownBreed;

    MooMoo[] public moomoos;
    mapping(uint256 => address) moomooToOwner;
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
        require(GrassToken.balanceOf(msg.sender) > mintFee);
        console.log("transferFrom", msg.sender, "to", address(this));
        // TODO approve on-chain
        GrassToken.transferFrom(msg.sender, owner(), mintFee);
        moomoos.push(MooMoo("NoName", 0, 0, 0, 0, 1, 0, 0, 0));

        moomooToOwner[tokenCounter] = to;
        //TODO mint random stat MooMoo

        _mint(to, tokenCounter);
        //console.log("balanceOf", to,":",balanceOf(to));
        // TODO setTokenURI
        console.log(
            "A origin is mint with id = %s to account %s",
            tokenCounter,
            to , ownerOf(tokenCounter)
        );

        tokenCounter++;
    }

    function breed(uint256 mooMoo1Id, uint256 mooMoo2Id)
        public
        isOwner(mooMoo1Id)
        isOwner(mooMoo2Id)
    {
        require(GrassToken.balanceOf(msg.sender) > breedFee);

        require(
            moomoos[mooMoo1Id].breed < maxBreed ||
                moomoos[mooMoo2Id].breed < maxBreed,
            "Maximum breeding"
        );
        // TODO require(); not time to breed

        moomoos.push(MooMoo("NoName", 0, 0, 0, 0, 1, 0, 0, 0));

        moomooToOwner[tokenCounter] = msg.sender;
        moomoos[mooMoo1Id].breed++;
        moomoos[mooMoo2Id].breed++;
        //TODO mint MooMoo based on parent's stat
        _mint(msg.sender, tokenCounter);
        // TODO setTokenURI
        console.log("A new born MooMoo with id = %s", tokenCounter);

        GrassToken.transferFrom(msg.sender, owner(), mintFee);
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
            uint256 lossCount
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
            mooMoo.lossCount
        );
    }

    modifier isOwner(uint256 mooMooId) {
        require(
            ownerOf(mooMooId) == msg.sender,
            "Not owner of this MooMoo"
        );
        _;
    }
}
