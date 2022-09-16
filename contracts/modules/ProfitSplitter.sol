// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./base.sol";

abstract contract ProfitSplitter is Base {

  /*
  * @dev This struct holds information for the team member address and percent share
  * @item memberAddress - Address of team member (address)
  * @item memberShare   - Share of the team member (uint256)
  */
  struct TeamAndShare {
    address memberAddress;
    uint256 memberShare;
  }

  /*
  * Maps an index to a team member's information stored in a TeamAndShare struct
  */
  mapping(uint => TeamAndShare) public indexOfTeamMembers;
  uint public numberOfTeamMembers;

  /*
  * @dev Set the team and share by passing an index of that team member for payment after mint
  * @param _teamAddress - Address of team member to pay out
  * @param _percentShare - Percent out of 100 to pay out to _teamAddress
  * @param _teamIndex    - Index of team member, starting from 0 through N-1 (N = total team members).
  *                        This is the withdraw function will access each member, so remember the order.
  */
  function _setTeamAndShares(address _teamAddress, uint256 _percentShare, uint256 _teamIndex) internal {
    require(_teamAddress != address(0), "Can't send money to burn address");
    indexOfTeamMembers[_teamIndex] = TeamAndShare(_teamAddress, _percentShare);
    numberOfTeamMembers++;
  }

  /*
  * @dev Set the team and share by passing an index of that team member for payment after mint
  * @param _teamAddress - Address of team member to pay out
  * @param _percentShare - Percent out of 100 to pay out to _teamAddress
  * @param _teamIndex    - Index of team member, starting from 0 through N-1 (N = total team members).
  *                        This is the withdraw function will access each member, so remember the order.
  */
  function setTeamAndShares(address _teamAddress, uint256 _percentShare, uint256 _teamIndex) external onlyOwner {
    require(_teamAddress != address(0), "Can't send money to burn address");
    indexOfTeamMembers[_teamIndex] = TeamAndShare(_teamAddress, _percentShare);
    numberOfTeamMembers++;
  }

  /*
  * @dev Withdraws token from the contract and splits it among team members
  * @param _token - Token address corresponding to the token to be withdrawn from the contract
  */
  function withdraw(address _token) public virtual override (Base) {
    uint amount = IERC20(_token).balanceOf(address(this));
    require(amount > 0);
    uint len = numberOfTeamMembers;
    TeamAndShare memory memberToBePaid;
    for(uint i = 0; i < len; i++) {
      memberToBePaid = indexOfTeamMembers[i];
      IERC20(_token).transfer(memberToBePaid.memberAddress, amount * memberToBePaid.memberShare / 10000);
    }
  }
}
