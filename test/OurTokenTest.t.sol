// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address public USER = makeAddr("user");
    address public RECIPIENT = makeAddr("recipient");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant TRANSFER_AMOUNT = 10 ether;
    uint256 public constant APPROVE_AMOUNT = 20 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowanceWorks() public {
        uint256 initialAllowance = 1000;

        //Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    // verifies the behavior of transferring zero tokens
    function testZeroValueTransfer() public {
        vm.prank(bob);
        bool success = ourToken.transfer(alice, 0);

        assertTrue(success, "Zero value transfer should be allowed");
        assertEq(
            ourToken.balanceOf(bob),
            STARTING_BALANCE,
            "Balance should remain unchanged"
        );
    }

    // checks the ability to set an unlimited spending allowance
    function testInfiniteApproval() public {
        vm.prank(bob);
        bool success = ourToken.approve(alice, type(uint256).max);

        assertTrue(success, "Infinite approval should work");
        assertEq(
            ourToken.allowance(bob, alice),
            type(uint256).max,
            "Allowance should be set to max"
        );
    }

    function testTransferToSelf() public {
        uint256 initialBalance = ourToken.balanceOf(bob);

        vm.prank(bob);
        bool success = ourToken.transfer(bob, TRANSFER_AMOUNT);

        assertTrue(success, "Transfer to self should be allowed");
        assertEq(
            ourToken.balanceOf(bob),
            initialBalance,
            "Balance should remain unchanged when transferring to self"
        );
    }
}
