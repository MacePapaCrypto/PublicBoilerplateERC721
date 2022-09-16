// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

struct InitializeParams {
    string _name;
    string _symbol;
    string _initBaseURI;
    address _royaltyAddress;
    uint96 _royaltiesPercentage;
    uint _maxSupply;
    uint _maxMintAmount;
    address _treasury;
    address _lpPair;
    uint _price;
    address payable _WETH;
    address _caller;
}

interface IBoilerplateERC721 is IERC721Enumerable {
    /* External Functions */
    function setBaseURI(string memory _newBaseURI) external;
    function pausePublic(bool _state) external;
    function mint(address token, uint amount, address collection) external payable;
    function batchTransfer(address from, address to, uint256[] calldata tokenIds) external;
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function initialize(
        InitializeParams memory params
    ) external;
}