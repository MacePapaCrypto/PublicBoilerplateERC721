// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../interfaces/IWrappedFantom.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./base.sol";

/*
*
*
*
*/
abstract contract CurrencyManager is Base {
  using SafeERC20 for IERC20;

  /*
  * Maps an ERC20 address to a price
  * Prices are set in ether
  * To set in ethers.js, use ethers.utils.parseUnits(priceToSet, 'ether')
  */
  //@audit cost too low?
  mapping(address => uint) public acceptedCurrencies;

  function _isAccepted(address _token) internal view virtual override (Base) returns (bool) {
    return acceptedCurrencies[_token] != 0;
  }

  function _getPrice(address _token, uint _amount, address _collection) internal view virtual override (Base) returns (uint) {
    require(acceptedCurrencies[_token] > 0,"Token not authorized, cannot get price");
    return acceptedCurrencies[_token] * _amount;
  }

  /*
  * @dev This function adds a currency address at an input price, and allows for the mint to be done
  *      in multiple currencies.
  *      Prices are set in ether
  *      To set in ethers.js, use ethers.utils.parseUnits(priceToSet, 'ether');
  *
  * @param _acceptedCurrencyInput - Address of currency to be accepted for payment
  * @param _price                 - Price for payment mapped to address of _acceptedCurrencyInput
  */
  function _addCurrency(address _acceptedCurrencyInput, uint256 _price) internal {
    require(_acceptedCurrencyInput != address(0), "Cannot set zero address as currency");
    acceptedCurrencies[_acceptedCurrencyInput] = _price;
  }

  /*
  * @dev This function adds a currency address at an input price, and allows for the mint to be done
  *      in multiple currencies.
  *      Prices are set in ether
  *      To set in ethers.js, use ethers.utils.parseUnits(priceToSet, 'ether');
  *
  * @param _acceptedCurrencyInput - Address of currency to be accepted for payment
  * @param _price                 - Price for payment mapped to address of _acceptedCurrencyInput
  */
  function addCurrency(address _acceptedCurrencyInput, uint256 _price) external onlyOwner {
    require(_acceptedCurrencyInput != address(0), "Cannot set zero address as currency");
    acceptedCurrencies[_acceptedCurrencyInput] = _price;
  }

}
