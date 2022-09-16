// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IWETH9.sol";
import "./URIManager.sol";
import "./Random.sol";

abstract contract Base is Ownable, Random, URIManager {

  IWETH9 public WETH;
  uint public constant BASIS_POINTS = 10_000;

  uint public price;
  address public treasury;

  bool public publicPaused = true;

  function _initializeBase(uint _price, address _treasury, address payable _WETH) internal {
    price = _price;
    treasury = _treasury;
    WETH = IWETH9(_WETH);
  }

  function _getPrice(address _token, uint _amount, address _collection) internal virtual view returns (uint) {
    return price * _amount;
  }

  function _isAccepted(address _token) internal virtual view returns (bool) {
    return _token == address(WETH);
  }

  /*
  * @dev Accepts FTM deposits, then wraps and sends to contract
  */
  function _acceptAndWrap(uint expected) internal returns (uint) {
    //We can get around a potential bug here by checking for isAccepted(_token)
    //Before this function is called
    require(msg.value >= expected, "insufficient funds");
    WETH.deposit{ value: expected }();
    uint remaining = msg.value - expected;
    if (msg.value - expected > 0) {
      payable(msg.sender).transfer(remaining);
    }
    return msg.value;
  }

  function withdraw(address _token) external virtual onlyOwner {
    IERC20(_token).transfer(treasury, IERC20(_token).balanceOf(address(this)));
  }

  /*
  * @dev Pause/Unpause the mint
  * @param _state - Sets state of mint. True to paused; False to unpaused
  */
  function pausePublic(bool _state) public onlyOwner {
    publicPaused = _state;
  }

  /*
  * @dev Set new FTM price
  * @param _price - New FTM price to be set
  */
  function setPrice(uint _price) public onlyOwner {
    price = _price;
  }

}
