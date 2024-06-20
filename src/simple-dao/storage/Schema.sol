// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Schema {
    struct GlobalState {
        uint[] proposals;
        uint approvedProposals;
        uint tally_frequency;
        uint nextProposalId;
    }

    struct Proposal {
        uint id;
        address proposer;
        string name;
        uint start_time;
        uint proposal_duration;
        ProposalStatus status;
    }

    enum ProposalStatus { Ongoing, Approved, Rejected }

    struct Vote {
        uint proposal_id;
        address voter;
        bool support;
        uint timestamp;
    }

    struct ProposalSystem {
        GlobalState globalState;
        mapping(uint => Proposal) proposals;
        mapping(bytes32 => Vote) votes;
    }
}
