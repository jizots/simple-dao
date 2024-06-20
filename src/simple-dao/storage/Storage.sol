// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Schema.sol";

library Storage {
    bytes32 internal constant STORAGE_SLOT = keccak256("proposalSystem.storage");

    struct Layout {
        Schema.GlobalState globalState;
        mapping(uint => Schema.Proposal) proposals;
        mapping(bytes32 => Schema.Vote) votes;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function getStorageSlot() external pure returns (bytes32) {
        return STORAGE_SLOT;
    }

    function writeProposal(uint proposalId, Schema.Proposal memory proposal) external {
        Layout storage l = layout();
        l.proposals[proposalId] = proposal;
    }

    function readProposal(uint proposalId) external view returns (Schema.Proposal memory) {
        Layout storage l = layout();
        return l.proposals[proposalId];
    }
}
