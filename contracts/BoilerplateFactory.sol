// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IBoilerplateERC721.sol";

//Want to be able to manage all NFTs deployed
contract BoilerplateFactory {

    using Clones for address;

    event NewContractDeployed(address contractAddress);

    address[2] public boilerplateAddresses;
    uint public nonceForCreate = 0;

    //Nonce to an implementation address
    mapping(uint => address) public nonceToImplementation;

    //Enumerable Mappings
    //first address -> userAddress
    //Maps to uint -> index for list of deployed contracts
    //Which maps to address -> deployedContract
    mapping(address => mapping(uint => address)) public deployedContractsByUser;

    //Deployed address mapped to index in user list
    mapping(address => uint) public deployedContractsIndex;

    //User address mapped to number of contracts deployed
    mapping(address => uint) public numberOfContractsByUser;

    constructor(
        address[2] memory _boilerplateAddresses
    ) {
        boilerplateAddresses = _boilerplateAddresses;
    }

    function _createClone(uint _boilerplateIndex, InitializeParams memory _params) internal returns (address instance) {
        uint nonce = nonceForCreate;
        instance = boilerplateAddresses[_boilerplateIndex].clone();
        _addCloneToEnumeration(msg.sender, instance);
        nonceToImplementation[nonce] = instance;
        nonceForCreate++;
        IBoilerplateERC721(instance).initialize(_params);
        emit NewContractDeployed(instance);
    }

    function createClone(uint _boilerplateIndex, InitializeParams memory _params) external returns (address instance) {
        instance = _createClone(_boilerplateIndex, _params);
    }

    function _addCloneToEnumeration(address userAddress, address cloneAddress) internal {
        uint index = numberOfContractsByUser[userAddress];
        deployedContractsByUser[userAddress][index] = cloneAddress;
        deployedContractsIndex[cloneAddress] = index;
        numberOfContractsByUser[userAddress]++;
    }

    function getContractsByUser(address userAddress, uint index) external view returns (address deployedContract) {
        require(index < numberOfContractsByUser[userAddress], "Index out of bounds");
        return deployedContractsByUser[userAddress][index];
    }

}