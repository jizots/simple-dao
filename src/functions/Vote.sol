// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../simple-dao/storage/Schema.sol";
import "../simple-dao/storage/Storage.sol";

import "forge-std/Test.sol";

contract Vote {
    using Storage for Storage.Layout;

    event VoteCast(uint indexed proposalId, address indexed voter, bool support, uint timestamp);

    function castVote(uint proposalId, bool support) external {
        Storage.Layout storage layout = Storage.layout();
        Schema.Proposal storage proposal = layout.proposals[proposalId];

        // デバッグ用ログ出力
        console.log("Fetching Proposal ID in Vote: ", proposalId);
        console.log("Stored Proposal Start Time: ", proposal.start_time);
        console.log("Stored Proposal Duration: ", proposal.proposal_duration);

        require(proposal.id == proposalId, "Vote: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Ongoing, "Vote: Proposal is not ongoing");
        require(block.timestamp >= proposal.start_time, "Vote: Voting has not started yet");
        require(block.timestamp <= proposal.start_time + proposal.proposal_duration, "Vote: Voting has ended");

        bytes32 voteKey = keccak256(abi.encodePacked(proposalId, msg.sender));
        require(layout.votes[voteKey].voter == address(0), "Vote: Voter has already voted");

        layout.votes[voteKey] = Schema.Vote({
            proposal_id: proposalId,
            voter: msg.sender,
            support: support,
            timestamp: block.timestamp
        });

        emit VoteCast(proposalId, msg.sender, support, block.timestamp);
    }

    function getVote(uint proposalId, address voter) external view returns (Schema.Vote memory) {
        bytes32 voteKey = keccak256(abi.encodePacked(proposalId, voter));
        return Storage.layout().votes[voteKey];
    }
}
