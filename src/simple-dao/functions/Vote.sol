// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storage/Schema.sol";
import {Storage} from "../storage/Storage.sol";

import "forge-std/Test.sol";

contract Vote {
    using Storage for *;

    event VoteCast(uint indexed proposalId, address indexed voter, bool support, uint timestamp);

    function castVote(uint proposalId, bool support) external {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage proposal = ps.proposals[proposalId];

        // デバッグ用ログ出力
        // console.log("Fetching Proposal ID in Vote: ", proposalId);
        // console.log("Stored Proposal Start Time: ", proposal.start_time);
        // console.log("Stored Proposal Duration: ", proposal.proposal_duration);

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

        emit VoteCast(proposalId, msg.sender, support, block.timestamp);
    }
}
