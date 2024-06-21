// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storage/Schema.sol";
import {Storage} from "../storage/Storage.sol";

contract Vote {
    using Storage for *;

    event VoteCast(uint indexed proposalId, address indexed voter, bool support, uint timestamp);

    function castVote(uint proposalId, bool support) external {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();

        require(proposalId < ps.globalState.nextProposalId, "Vote: Proposal ID is invalid");
        
        Schema.Proposal storage proposal = ps.proposals[proposalId];

        require(proposal.id == proposalId, "Vote: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Ongoing, "Vote: Proposal is not ongoing");
        require(block.timestamp >= proposal.start_time, "Vote: Voting has not started yet");
        require(block.timestamp <= proposal.start_time + proposal.proposal_duration, "Vote: Voting has ended");

        bytes32 voteKey = keccak256(abi.encodePacked(proposalId, msg.sender));
        require(ps.votes[voteKey].voter == address(0), "Vote: Voter has already voted");

        ps.votes[voteKey] = Schema.Vote({
            proposal_id: proposalId,
            voter: msg.sender,
            support: support,
            timestamp: block.timestamp
        });

        ps.voters[msg.sender] = true;

        emit VoteCast(proposalId, msg.sender, support, block.timestamp);
    }
}
