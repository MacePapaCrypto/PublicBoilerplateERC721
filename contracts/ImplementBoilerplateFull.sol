// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./BoilerplateERC721Full.sol";
import "./modules/Discounts.sol";

contract TestBoilerplateFull is BoilerplateERC721Full {

  constructor()BoilerplateERC721Full() {}

  /*
  * Overriding Functions
  */
  function _isAccepted(address _token) internal view override(BoilerplateERC721Full) returns (bool) {
    return super._isAccepted(_token);
  }

  function _getPrice(address _token, uint _amount, address _collection) internal view override(BoilerplateERC721Full) returns (uint) {
    return super._getPrice(_token, _amount, _collection);
  }

  function withdraw(address _token) public override (BoilerplateERC721Full) {
    super.withdraw(_token);
  }
}