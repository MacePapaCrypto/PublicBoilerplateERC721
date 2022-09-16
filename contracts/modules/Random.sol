// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../lib/Randomness.sol";

abstract contract Random {

  uint16[] private ids;
  address public lpPair;
  uint16 public index = 0;

  function _initializeRandom(uint max, address _lpPair) internal {
    ids = new uint16[](max);
    lpPair = _lpPair;
  }

  /*
  * @dev Picks a random ID to mint based on an input random number
  * @param _random - Random number to use as seed for ID pick
  */
  function _pickRandomUniqueId(uint256 _random) internal returns (uint256 id) {
      uint256 len = ids.length - index++;
      require(len > 0, "no ids left");
      uint256 randomIndex = _random % len;
      id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
      ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
      ids[len - 1] = 0;
  }
}
