// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/simple-dao/functions/Propose.sol";
import "../src/simple-dao/functions/Vote.sol";

import "../src/simple-dao/storage/Schema.sol";
import "../src/simple-dao/storage/Storage.sol";

import {MCTest} from "@mc/devkit/Flattened.sol";
import {stdError} from "forge-std/StdError.sol";
import {SimpleDAOFacade} from "../src/simple-dao/interfaces/SimpleDAOFacade.sol";

import {Storage} from "../src/simple-dao/storage/Storage.sol";
import {Propose} from "../src/simple-dao/functions/Propose.sol";
import {Vote} from "../src/simple-dao/functions/Vote.sol";

contract VoteTest is MCTest {
    SimpleDAOFacade public _SimpleDAO = SimpleDAOFacade(target);

    receive() external payable {}

    function setUp() public {
        _use(_SimpleDAO.createProposal.selector, address(new Propose()));
        _use(_SimpleDAO.castVote.selector, address(new Vote()));
    }

    function testVote() public
    {
        string memory proposalName = "Test Proposal";
        uint startTime = block.timestamp + 10;
        uint proposalDuration = 10000;

        _SimpleDAO.createProposal(proposalName, startTime, proposalDuration);

        vm.warp(startTime + 10);

        _SimpleDAO.castVote(Storage.ProposalSystemStorage().globalState.nextProposalId - 1, true);
        // _SimpleDAO.castVote(Storage.ProposalSystemStorage().globalState.nextProposalId - 1, false);
        // _SimpleDAO.castVote(Storage.ProposalSystemStorage().globalState.nextProposalId, true);

        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage storedProposal = ps.proposals[0];
        Schema.Vote storage storedVote = ps.votes[keccak256(abi.encodePacked(uint256(0), address(this)))];

        assertEq(storedProposal.id, 0);
        assertEq(storedProposal.proposer, address(this));
        assertEq(storedProposal.name, proposalName);
        assertEq(storedProposal.start_time, startTime);
        assertEq(storedProposal.proposal_duration, proposalDuration);
        assertEq(uint(storedProposal.status), uint(Schema.ProposalStatus.Ongoing));

        /* for debugging */
        console.log("Direct Storage Access - Proposal ID: ", storedVote.proposal_id);
        console.log("Direct Storage Access - Voter: ", storedVote.voter);
        console.log("Direct Storage Access - Support: ", storedVote.support);
        console.log("Direct Storage Access - Timestamp: ", storedVote.timestamp);
        
        assertEq(storedVote.proposal_id, 0);
        assertEq(storedVote.voter, address(this));
        assertEq(storedVote.support, true);
        assert(storedVote.timestamp <= block.timestamp);
    }
}