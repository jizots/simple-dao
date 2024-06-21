// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SimpleDAOFacade {
    function createProposal(string memory name, uint256 startTime, uint256 duration) external {}
    
    function castVote(uint proposalId, bool support) external {}
}