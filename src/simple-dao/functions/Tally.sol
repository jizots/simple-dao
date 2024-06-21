// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storage/Schema.sol";
import {Storage} from "../storage/Storage.sol";
import "./Execute.sol";

contract Tally {
    using Storage for *;

    event ProposalTallied(uint indexed proposalId, bool approved, uint supportVotes, uint againstVotes);

    Execute private executeContract;

    constructor(address executeAddress) {
        require(executeAddress != address(0), "Tally: Execute address is required");
        executeContract = Execute(executeAddress);
    }

    function tallyVotesOnCompletion(uint proposalId) external {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage proposal = ps.proposals[proposalId];
        require(proposal.id == proposalId, "Tally: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Ongoing, "Tally: Proposal is not ongoing");
        require(block.timestamp >= proposal.start_time + proposal.proposal_duration, "Tally: Proposal duration not yet completed");

        _tallyVotes(proposalId);
    }

    function tallyVotesPeriodically() external {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        uint frequency = ps.globalState.tally_frequency;
        require(frequency > 0, "Tally: Tally frequency is not set");

        for (uint i = 0; i < ps.globalState.proposalIds.length; i++) {
            uint proposalId = ps.globalState.proposalIds[i];
            Schema.Proposal storage proposal = ps.proposals[proposalId];

            if (proposal.status == Schema.ProposalStatus.Ongoing && block.timestamp >= proposal.start_time + frequency) {
                _tallyVotes(proposalId);
            }
        }
    }

    function _tallyVotes(uint proposalId) internal {
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage proposal = ps.proposals[proposalId];

        uint supportVotes = 0;
        uint againstVotes = 0;

        for (uint i = 0; i < ps.globalState.proposalIds.length; i++) {
            bytes32 voteKey = keccak256(abi.encodePacked(proposalId, ps.globalState.proposalIds[i]));
            Schema.Vote storage vote = ps.votes[voteKey];

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
