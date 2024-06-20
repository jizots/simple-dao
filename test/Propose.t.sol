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

    function testStorageSlot() public {
        bytes32 expectedSlot = Storage.getStorageSlot();
        console.logBytes32(expectedSlot);
        // スクリプトの出力と一致するか確認
        assertEq(expectedSlot, 0x29e83060e8be5db436e9eb1e087b0814968a5cf4bd1625a4880b33d04591de00);
    }

    function testCreateProposal() public {
        propose.createProposal("Test Proposal", block.timestamp + 10, 10000);

        (
            uint id,
            address proposer,
            string memory name,
            uint start_time,
            uint proposal_duration,
            Schema.ProposalStatus status
        ) = propose.getProposal(0);

        console.log("getProposal - Proposal ID: ", id);
        console.log("getProposal - Proposal Proposer: ", proposer);
        console.log("getProposal - Proposal Name: ", name);
        console.log("getProposal - Proposal Start Time: ", start_time);
        console.log("getProposal - Proposal Duration: ", proposal_duration);
        console.log("getProposal - Proposal Status: ", uint(status));

        Schema.Proposal memory proposal = Storage.readProposal(0);

        console.log("Direct Storage Access - Proposal ID: ", proposal.id);
        console.log("Direct Storage Access - Proposal Proposer: ", proposal.proposer);
        console.log("Direct Storage Access - Proposal Name: ", proposal.name);
        console.log("Direct Storage Access - Proposal Start Time: ", proposal.start_time);
        console.log("Direct Storage Access - Proposal Duration: ", proposal.proposal_duration);
        console.log("Direct Storage Access - Proposal Status: ", uint(proposal.status));

        assertEq(proposal.id, id);
        assertEq(proposal.proposer, proposer);
        assertEq(proposal.name, name);
        assertEq(proposal.start_time, start_time);
        assertEq(proposal.proposal_duration, proposal_duration);
        assertEq(uint(proposal.status), uint(status));
    }
}
