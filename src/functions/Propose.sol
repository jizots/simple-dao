// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../simple-dao/storage/Schema.sol";
import "../simple-dao/storage/Storage.sol";

import "forge-std/Test.sol";
contract Propose {
    using Storage for Storage.Layout;

    event ProposalCreated(uint indexed proposalId, address indexed proposer, string name, uint startTime, uint proposalDuration);

    function createProposal(string memory name, uint startTime, uint proposalDuration) external {
        require(startTime > block.timestamp, "Propose: Start time must be in the future");

        uint newProposalId = Storage.layout().globalState.proposals.length;

        Schema.Proposal memory newProposal = Schema.Proposal({
            id: newProposalId,
            proposer: msg.sender,
            name: name,
            start_time: startTime,
            proposal_duration: proposalDuration,
            status: Schema.ProposalStatus.Ongoing
        });

        Storage.writeProposal(newProposalId, newProposal);
        Storage.layout().globalState.proposals.push(newProposalId);

        emit ProposalCreated(newProposalId, msg.sender, name, startTime, proposalDuration);

        // デバッグログを追加
        Schema.Proposal memory proposal = Storage.readProposal(newProposalId);
        console.log("Debug - Proposal ID: ", proposal.id);
        console.log("Debug - Proposal Proposer: ", proposal.proposer);
        console.log("Debug - Proposal Name: ", proposal.name);
        console.log("Debug - Proposal Start Time: ", proposal.start_time);
        console.log("Debug - Proposal Duration: ", proposal.proposal_duration);
        console.log("Debug - Proposal Status: ", uint(proposal.status));
    }

    function getProposal(uint proposalId) external view returns (
        uint id,
        address proposer,
        string memory name,
        uint start_time,
        uint proposal_duration,
        Schema.ProposalStatus status
    ) {
        Schema.Proposal memory proposal = Storage.readProposal(proposalId);
        return (
            proposal.id,
            proposal.proposer,
            proposal.name,
            proposal.start_time,
            proposal.proposal_duration,
            proposal.status
        );
    }
}
