// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/functions/Propose.sol";
import "../src/functions/Vote.sol";
import "../src/simple-dao/storage/Schema.sol";
import "../src/simple-dao/storage/Storage.sol";

contract VoteTest is Test {
    Propose propose;
    Vote vote;

    function setUp() public {
        propose = new Propose();
        vote = new Vote();

        propose.createProposal("Test2 Proposal", block.timestamp + 10, 10000);
    }

    function testCastVote() public {
        // Storage.layout()を直接使用して提案の詳細を取得
        Storage.Layout storage layout = Storage.layout();
        Schema.Proposal storage proposal = layout.proposals[0];
        
        console.log("Direct Storage Access - Proposal ID: ", proposal.id);
        console.log("Direct Storage Access - Proposal Start Time: ", proposal.start_time);
        console.log("Direct Storage Access - Proposal Duration: ", proposal.proposal_duration);

        console.log("Block Timestamp Before Warp: ", block.timestamp);

        // タイムスタンプを進める
        vm.warp(block.timestamp + 60);

        console.log("Block Timestamp After Warp: ", block.timestamp);

        // 投票をキャスト
        vote.castVote(0, true);

        // 投票が成功したかを確認
        Schema.Vote memory castedVote = vote.getVote(0, address(this));
        assertTrue(castedVote.support);
    }
}
