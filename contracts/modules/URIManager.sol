// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract URIManager is Ownable {
  string baseURI;
  string public baseExtension = ".json";

  function _initializeURIManager(string memory _initBaseURI) internal {
    _setBaseURI(_initBaseURI);
  }
  
  /*
  * @dev Set a new baseURI for the collection
  * @param _newBaseURI - string uri to set, generally an IPFS address
  */
  function _setBaseURI(string memory _newBaseURI) internal {
    baseURI = _newBaseURI;
  }

  /*
  * @dev Set a new baseURI for the collection
  * @param _newBaseURI - string uri to set, generally an IPFS address
  */
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  /*
  * @dev Set a new baseExtension for the collection
  * @param _newBaseExtension - string postfix for the metadata filetype, generally .json
  */
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
}