// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./lib/Randomness.sol";
import "./modules/Discounts.sol";
import "./modules/ProfitSplitter.sol";
import "./modules/CurrencyManager.sol";
import "./interfaces/IBoilerplateERC721.sol";

/* Custom Error Section - Use with ethers.js for custom errors */
/*
* @dev Public Mint is Paused
*/
error MintPaused();

/*
* @dev Cannot mint zero NFTs
*/
error AmountLessThanOne();

/*
* @dev Cannot mint more than maxMintAmount
* @param amtMint - Amount the user is attempting to mint
* @param maxMint - Maximum amount allowed to be minted by user per transaction
*/
error AmountOverMax(uint256 amtMint, uint256 maxMint);

/*
* @dev Token not in Auth List
*/
error TokenNotAuthorized();

/*
* @dev Not enough mints left for mint amount
* @param supplyLeft - Number of tokens left to be minted
* @param amtMint    - Number of tokens user is attempting to mint
*/
error NotEnoughMintsLeft(uint256 supplyLeft, uint256 amtMint);

/*
* @dev Not enough ftm sent to mint
* @param totalCost - Cost of the NFTs to be minted
* @param amtFTM    - Amount being sent by the user
*/
error InsufficientFTM(uint256 totalCost, uint256 amtFTM);

//Do we need Base here if all of our modules implement Base?
abstract contract BoilerplateERC721Full is ERC721Enumerable, ERC2981, ProfitSplitter, NFTDiscounts, Initializable {
  using Strings for uint256;

  uint256 public maxSupply;
  uint256 public maxMintAmount;
  string public __name;
  string public __symbol;

  constructor() ERC721("", "") {}

  function initialize(
    InitializeParams memory params
  ) external initializer {
    __name = params._name;
    __symbol = params._symbol;
    _initializeBase(params._price, params._treasury, params._WETH);
    _initializeURIManager(params._initBaseURI);
    _initializeRandom(params._maxSupply, params._lpPair);
    maxSupply = params._maxSupply;
    maxMintAmount = params._maxMintAmount;
    _setDefaultRoyalty(params._royaltyAddress, params._royaltiesPercentage);
    _transferOwnership(params._caller);
  }

  function name() public view virtual override returns (string memory) {
      return __name;
  }

  function symbol() public view virtual override returns (string memory) {
      return __symbol;
  }

  /*
  * Overriding Functions
  */
  function _isAccepted(address _token) internal view virtual override(Base, CurrencyManager) returns (bool) {
    return super._isAccepted(_token);
  }

  function _getPrice(address _token, uint _amount, address _collection) internal view virtual override(Base, NFTDiscounts) returns (uint) {
    return super._getPrice(_token, _amount, _collection);
  }

  function withdraw(address _token) public virtual override (Base, ProfitSplitter) {
    super.withdraw(_token);
  }

  /**** Functions used during mint/after setup ****/
  /*
  * @dev Mint one or many NFTs with a specific token and potential discount
  * @param _token      - Token address to be used for payment
  * @param _amount     - Amount of tokens to be minted
  * @param _collection - NFT collection address used for potential discount.
  *                      If no discount, set to zero address
  */
  function mint(address _token, uint _amount, address _collection) external payable {
    _validateMint(_token,_amount);
    uint price = _getPrice(_token, _amount, _collection);
    //If wFTM is not accepted, but msg.value is sent, there could be unwanted results
    //Must check for value and accepted token again, even though its checked in validate mint
    //The reason for this is because they could pass the token address if mint is 10 USDC, but with msg.value of 10 FTM.
    //If we are not accepting FTM, this if statement will still be hit. Though this will likely still fail, we can
    //Keep accidental sends of FTM to our contract by checking for both in this conditional
    if (msg.value > 0 && _isAccepted(_token)) {
      _acceptAndWrap(price);
    } else {
      require(IERC20(_token).transferFrom(msg.sender, address(this), price), "Token did not send");
    }
    _mintInternal(_amount);
  }

  function _validateMint(address _token, uint _amount) internal view {
    //mint is closed
    if(publicPaused)
      revert MintPaused();
    if(_amount <= 0)
      revert AmountLessThanOne();
    //require(amount > 0, 'Cannot mint 0');
    if(_amount > maxMintAmount) {
      revert AmountOverMax({
        amtMint: _amount,
        maxMint: maxMintAmount
      });
    }
    if(!_isAccepted(_token))
      revert TokenNotAuthorized();
    //require(acceptedCurrencies[token] > 0, "token not authorized");

    uint256 supply = totalSupply();
    if(supply + _amount > maxSupply) {
      revert NotEnoughMintsLeft({
        supplyLeft: maxSupply - supply,
        amtMint: _amount
      });
    }
  }

  /*
  * @dev Very basic, mostly unomptimized batchTransfer function - could maybe add unchecked to save some gas.
  * @param _from - Address that NFTs will be transfered from
  * @param _to - Address that NFTs will be transfered to
  * @param _tokenIds - Array of token IDs to be received by to
  */
  function batchTransfer(address _from, address _to, uint256[] calldata _tokenIds) external {
    uint len = _tokenIds.length;
    for(uint i = 0; i < len; i++) {
      safeTransferFrom(_from, _to, _tokenIds[i]);
    }
  }

  /*
  * @dev Allow batch send to multiple addresses
  *      If you want to send to fewer addresses than tokenIds, just use the same addresses multiple times for the token Ids you want send send
  *      For example:
  *      tokenIds = [1, 3, 4, 6, 7]
  *      You need a to array length of 5 for the function to work. If you want to send to two people, you just use those two addresses in the correct tokenId locations.
  *      to = [0x0, 0x0, 0x1, 0x1, 0x0]
  *
  * @param _from     - Address that NFTs will be transfered from
  * @param _to       - Array of addresses that NFTs will be transfered to
  * @param _tokenIds - Array of token IDs to be received by to
  */
  function batchTransferManyAddresses(address _from, address[] calldata _to, uint256[] calldata _tokenIds) external {
    require(_to.length == _tokenIds.length, "Tokens not being sent to enough addresses");
    uint len = _tokenIds.length;
    for(uint i = 0; i < len; i++) {
      safeTransferFrom(_from, _to[i], _tokenIds[i]);
    }
  }

  /*
  * @dev Returns the supported interfaces
  * @param _interfaceID - bytes4 value which represents a contract type
  */
  function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
    return super.supportsInterface(_interfaceId);
  }

  /**** End Exteral/Public Functions ****/

  /**** Internal function calls ****/


  /*
  * @dev Internal mint function that handles the random ID check by calling _getRandom from library contracts.
  *      To increase randomization, we pass supply and lpPair. All external mints go through this function.
  *
  * @param _amount - Amount of NFTs to be minted
  */
  function _mintInternal(uint _amount) internal {
    uint supply = totalSupply();
    for (uint256 i = 1; i <= _amount; ++i) {
        _safeMint(msg.sender, _pickRandomUniqueId(Randomness._getRandom(supply, lpPair)) +1);
    }
  }

  /*
  * @dev Returns the token IDs owned by _owner
  * @param _owner - Address of NFT owner
  */
  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }
  
  /*
  * @dev Returns the baseURI for the collection
  */
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  /*
  * @dev Returns the URI based on tokenID
  * @param tokenID - Token ID to query for URI value
  */
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
}
