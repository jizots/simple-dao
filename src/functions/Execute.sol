// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../simple-dao/storage/Schema.sol";
import "../simple-dao/storage/Storage.sol";
import "./Increment.sol";

contract Execute {
    using Storage for Storage.Layout;

    event ProposalExecuted(uint indexed proposalId);

    Increment private incrementContract;

    constructor(address incrementAddress) {
        require(incrementAddress != address(0), "Execute: Increment address is required");
        incrementContract = Increment(incrementAddress);
    }

    function executeProposal(uint proposalId) external {
        Schema.Proposal storage proposal = Storage.layout().proposals[proposalId];
        require(proposal.id == proposalId, "Execute: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Approved, "Execute: Proposal is not approved");

        _execute(proposalId);

        emit ProposalExecuted(proposalId);
    }

    function _execute(uint proposalId) internal {
        incrementContract.incrementValue(proposalId);
    }
}
