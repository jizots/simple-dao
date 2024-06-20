// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../simple-dao/storage/Schema.sol";
import {Storage} from "../simple-dao/storage/Storage.sol";

import "forge-std/Test.sol";

contract Propose {
    using Storage for *;

    event ProposalCreated(uint indexed proposalId, address indexed proposer, string name, uint startTime, uint proposalDuration);

    function createProposal(string memory name, uint startTime, uint proposalDuration) external {
        require(startTime > block.timestamp, "Propose: Start time must be in the future");

        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        uint newProposalId = ps.globalState.proposals.length;

        console.log("Before Writing Proposal");
        console.log("Existing Proposal Count: ", ps.globalState.proposals.length);

        Schema.Proposal memory newProposal = Schema.Proposal({
            id: newProposalId,
            proposer: msg.sender,
            name: name,
            start_time: startTime,
            proposal_duration: proposalDuration,
            status: Schema.ProposalStatus.Ongoing
        });

        ps.proposals[newProposalId] = newProposal;
        ps.globalState.proposals.push(newProposalId);

        console.log("After Writing Proposal");
        Schema.Proposal storage writtenProposal = ps.proposals[newProposalId];
        console.log("Written Proposal ID: ", writtenProposal.id);
        console.log("Written Proposal Proposer: ", writtenProposal.proposer);
        console.log("Written Proposal Name: ", writtenProposal.name);
        console.log("Written Proposal Start Time: ", writtenProposal.start_time);
        console.log("Written Proposal Duration: ", writtenProposal.proposal_duration);
        console.log("Written Proposal Status: ", uint(writtenProposal.status));

        emit ProposalCreated(newProposalId, msg.sender, name, startTime, proposalDuration);
    }
}
