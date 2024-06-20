// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../simple-dao/storage/Schema.sol";
import "../simple-dao/storage/Storage.sol";
import "./Execute.sol";

contract Tally {
    using Storage for Storage.Layout;

    event ProposalTallied(uint indexed proposalId, bool approved, uint supportVotes, uint againstVotes);

    Execute private executeContract;

    constructor(address executeAddress) {
        require(executeAddress != address(0), "Tally: Execute address is required");
        executeContract = Execute(executeAddress);
    }

    function tallyVotesOnCompletion(uint proposalId) external {
        Schema.Proposal storage proposal = Storage.layout().proposals[proposalId];
        require(proposal.id == proposalId, "Tally: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Ongoing, "Tally: Proposal is not ongoing");
        require(block.timestamp >= proposal.start_time + proposal.proposal_duration, "Tally: Proposal duration not yet completed");

        _tallyVotes(proposalId);
    }

    function tallyVotesPeriodically() external {
        uint frequency = Storage.layout().globalState.tally_frequency;
        require(frequency > 0, "Tally: Tally frequency is not set");

        for (uint i = 0; i < Storage.layout().globalState.proposals.length; i++) {
            uint proposalId = Storage.layout().globalState.proposals[i];
            Schema.Proposal storage proposal = Storage.layout().proposals[proposalId];

            if (proposal.status == Schema.ProposalStatus.Ongoing && block.timestamp >= proposal.start_time + frequency) {
                _tallyVotes(proposalId);
            }
        }
    }

    function _tallyVotes(uint proposalId) internal {
        Schema.Proposal storage proposal = Storage.layout().proposals[proposalId];

        uint supportVotes = 0;
        uint againstVotes = 0;

        for (uint i = 0; i < Storage.layout().globalState.proposals.length; i++) {
            bytes32 voteKey = keccak256(abi.encodePacked(proposalId, Storage.layout().globalState.proposals[i]));
            Schema.Vote storage vote = Storage.layout().votes[voteKey];

            if (vote.proposal_id == proposalId) {
                if (vote.support) {
                    supportVotes++;
                } else {
                    againstVotes++;
                }
            }
        }

        bool approved = supportVotes > againstVotes;
        proposal.status = approved ? Schema.ProposalStatus.Approved : Schema.ProposalStatus.Rejected;

        emit ProposalTallied(proposalId, approved, supportVotes, againstVotes);

        if (approved) {
            executeContract.executeProposal(proposalId);
        }
    }
}
