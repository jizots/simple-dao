// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleLogTest is Test 
{
    function testSimpleLog() public
    {
        console.log("Hello, Forge!");
        assertTrue(true);
    }
}
