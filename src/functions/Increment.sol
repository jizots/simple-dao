// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../simple-dao/storage/Schema.sol";
import "../simple-dao/storage/Storage.sol";

contract Increment {
    using Storage for Storage.Layout;

    // Event to be emitted when the global value is incremented
    event ValueIncremented(uint newValue);

    // Modifier to ensure the proposal is approved
    modifier onlyApproved(uint proposalId) {
        Schema.Proposal storage proposal = Storage.layout().proposals[proposalId];
        require(proposal.id == proposalId, "Increment: Proposal does not exist");
        require(proposal.status == Schema.ProposalStatus.Approved, "Increment: Proposal is not approved");
        _;
    }

    /**
     * @dev Increments the global value if the associated proposal is approved.
     * @param proposalId The ID of the approved proposal.
     */
    function incrementValue(uint proposalId) external onlyApproved(proposalId) {
        // Increment the global value
        Storage.layout().globalState.approvedProposals += 1;

        // Emit an event for the value increment
        emit ValueIncremented(Storage.layout().globalState.approvedProposals);
    }
}
