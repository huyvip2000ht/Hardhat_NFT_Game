// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
///dsadasdsa
import "@openzeppelin/contracts/utils/Context.sol";

contract RandomNumberConsumerV2 is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface immutable COORDINATOR;
  LinkTokenInterface immutable LINKTOKEN;
  uint64 immutable s_subscriptionId;
  bytes32 immutable s_keyHash;
  uint32 immutable s_callbackGasLimit = 100000;
  uint16 immutable s_requestConfirmations = 3;
  uint32 immutable s_numWords = 2;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address public s_owner;
  event ReturnedRandomness(uint256[] randomWords);
  constructor(
    uint64 subscriptionId,
    address vrfCoordinator,
    address link,
    bytes32 keyHash
  ) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link);
    s_keyHash = keyHash;
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }
  function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      s_keyHash,
      s_subscriptionId,
      s_requestConfirmations,
      s_callbackGasLimit,
      s_numWords
    );
  }
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    s_randomWords = randomWords;
    emit ReturnedRandomness(randomWords);
  }
  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}
