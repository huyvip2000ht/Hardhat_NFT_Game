//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract GrassToken is ERC20, Ownable {
    constructor() ERC20("Grass", "GRS") {
        _mint(msg.sender, 10000 * (10**18));//cxczx
    }
}
