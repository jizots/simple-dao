// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/simple-dao/functions/Propose.sol";
import "../src/simple-dao/storage/Schema.sol";
import "../src/simple-dao/storage/Storage.sol";

import {MCTest} from "@mc/devkit/Flattened.sol";
import {stdError} from "forge-std/StdError.sol";
import {SimpleDAOFacade} from "../src/simple-dao/interfaces/SimpleDAOFacade.sol";

import {Storage} from "../src/simple-dao/storage/Storage.sol";
import {Propose} from "../src/simple-dao/functions/Propose.sol";

contract ProposeTest is MCTest {
    SimpleDAOFacade public _SimpleDAO = SimpleDAOFacade(target);

    receive() external payable {}

    function setUp() public {
        _use(_SimpleDAO.createProposal.selector, address(new Propose()));
    }

    function testCreateProposal() public {
        string memory proposalName = "Test Proposal";
        uint startTime = block.timestamp + 10;
        uint proposalDuration = 10000;

        _SimpleDAO.createProposal(proposalName, startTime, proposalDuration);

        // モックコントラクトでストレージにアクセス
        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage storedProposal = ps.proposals[0];
        
        // デバッグログを追加
        console.log("Direct Storage Access - Proposal ID: ", storedProposal.id);
        console.log("Direct Storage Access - Proposal Proposer: ", storedProposal.proposer);
        console.log("Direct Storage Access - Proposal Name: ", storedProposal.name);
        console.log("Direct Storage Access - Proposal Start Time: ", storedProposal.start_time);
        console.log("Direct Storage Access - Proposal Duration: ", storedProposal.proposal_duration);
        console.log("Direct Storage Access - Proposal Status: ", uint(storedProposal.status));

        // アサーション
        assertEq(storedProposal.id, 0);
        assertEq(storedProposal.proposer, address(this));
        assertEq(storedProposal.name, proposalName);
        assertEq(storedProposal.start_time, startTime);
        assertEq(storedProposal.proposal_duration, proposalDuration);
        assertEq(uint(storedProposal.status), uint(Schema.ProposalStatus.Ongoing));
    }
}
