// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/functions/Propose.sol";
import "../src/simple-dao/storage/Schema.sol";
import "../src/simple-dao/storage/Storage.sol";

contract ProposeTest is Test {
    Propose propose;

    function setUp() public {
        propose = new Propose();
    }

    function testCreateProposal() public {
        string memory proposalName = "Test Proposal";
        uint startTime = block.timestamp + 10;
        uint proposalDuration = 10000;

        propose.createProposal(proposalName, startTime, proposalDuration);

        Schema.ProposalSystem storage ps = Storage.ProposalSystemStorage();
        Schema.Proposal storage storedProposal = ps.proposals[0];

        // テストログの出力
        console.log("Direct Storage Access - Proposal ID: ", storedProposal.id);
        console.log("Direct Storage Access - Proposal Proposer: ", storedProposal.proposer);
        console.log("Direct Storage Access - Proposal Name: ", storedProposal.name);
        console.log("Direct Storage Access - Proposal Start Time: ", storedProposal.start_time);
        console.log("Direct Storage Access - Proposal Duration: ", storedProposal.proposal_duration);
        console.log("Direct Storage Access - Proposal Status: ", uint(storedProposal.status));

        // 直接ストレージから読み取り
        assertEq(storedProposal.id, 0);
        assertEq(storedProposal.proposer, address(this));
        assertEq(storedProposal.name, proposalName);
        assertEq(storedProposal.start_time, startTime);
        assertEq(storedProposal.proposal_duration, proposalDuration);
        assertEq(uint(storedProposal.status), uint(Schema.ProposalStatus.Ongoing));
    }
}
