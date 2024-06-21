// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storage/Schema.sol";
import {Storage} from "../storage/Storage.sol";
import "./Increment.sol";

contract Execute {
    using Storage for *;

    event ProposalExecuted(uint indexed proposalId);

    Increment private incrementContract;

    constructor(address incrementAddress) {
        require(incrementAddress != address(0), "Execute: Increment address is required");
        incrementContract = Increment(incrementAddress);
    }

    function executeProposal(uint proposalId) external {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage proposal = ps.proposals[proposalId];
        require(proposal.id == proposalId, "Execute: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Approved, "Execute: Proposal is not approved");

        _execute(proposalId);

        emit ProposalExecuted(proposalId);
    }

    function _execute(uint proposalId) internal {
        incrementContract.incrementValue(proposalId);
    }
}
