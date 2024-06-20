// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "./Schema.sol";

library Storage {
    function ProposalSystemStorage() internal pure returns (Schema.ProposalSystem storage ps) {
        assembly {
            ps.slot := 0xdaf58ca28ede8a45c64a220d53624f87f5a5273327b1f02abfb8bc2b898b8800
        }
    }
}
