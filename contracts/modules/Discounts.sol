// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../lib/Math.sol";
import "./CurrencyManager.sol";

abstract contract NFTDiscounts is CurrencyManager {

  /*
  * Maps a collection address to a discount
  * Discounts must be (100-intendDiscount),
  * i.e. If expected discount is 30%, uint value must be 70
  */
  mapping(address => uint) public collectionsWithDiscounts;

  /*
  * @dev Evaluates the collection address passed and returns a percentDiscount based on the preset discounts, or gives no discount
  * @param _collection - Address of the NFT collection being used for a discount
  */
  function _getPrice(address _token, uint _amount, address _collection) internal view virtual override (CurrencyManager) returns(uint) {
    if(_collection == address(0)) {
      return acceptedCurrencies[_token] * _amount;
    }
    if (ERC721(_collection).balanceOf(msg.sender) != 0 &&
          collectionsWithDiscounts[_collection] > 0) {

      return acceptedCurrencies[_token] * _amount * (BASIS_POINTS - collectionsWithDiscounts[_collection]) / BASIS_POINTS;
    } else {
      return acceptedCurrencies[_token] * _amount;
    }
  }

  /*
  * @dev Sets the NFT collections that can apply a discount to the mint cost
  * @param _collectionAddress - Address of the collection to whitelist for discount
  * @param _discount          - Discount to be set. This number must be 100-expectedDiscountPercentage.
  */
  function setDiscount(address _collectionAddress, uint _discount) external {
    require(_collectionAddress != address(0), "Cannot set zero address as collection");
    collectionsWithDiscounts[_collectionAddress] = _discount;
  }

  /*
  * @dev Sets the NFT collections that can apply a discount to the mint cost
  * @param _collectionAddress - Address of the collection to whitelist for discount
  * @param _discount          - Discount to be set. This number must be 100-expectedDiscountPercentage.
  */
  function _setDiscount(address _collectionAddress, uint _discount) internal {
    require(_collectionAddress != address(0), "Cannot set zero address as collection");
    collectionsWithDiscounts[_collectionAddress] = _discount;
  }

  function setDiscounts(address[] calldata _collectionAddress, uint[] calldata _discounts) external {
    require(_collectionAddress.length == _discounts.length, "lengths do not match");
    for(uint i; i < _discounts.length; i++) {
      _setDiscount(_collectionAddress[i], _discounts[i]);
    }
  }
}
