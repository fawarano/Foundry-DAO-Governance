//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Box} from "../src/Box.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    Box box;
    GovToken govToken;
    TimeLock timeLock;

    address[] public proposers;
    address[] public executors;
    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // 1 hour in seconds, it's the dalay after a vote passes before execution
    uint256 public constant VOTING_DELAY = 1; // 1 block delay before a vote is active
    uint256 public constant VOTING_PERIOD = 50400; // 1 week in blocks (assuming 15s blocks)

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.prank(USER);
        govToken.delegate(USER);
        timeLock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timeLock);

        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.TIMELOCK_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(governor));
        timeLock.grantRole(executorRole, address(0));
        timeLock.revokeRole(adminRole, msg.sender);

        box = new Box();
        box.transferOwnership(address(timeLock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(42);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));
        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        console.log("Proposal State:", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 1); // Move time forward to allow voting
        vm.roll(block.number + VOTING_DELAY + 1);
        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 2. Vote on the proposal
        string memory reason = "I support this proposal";
        // note:  0 = Against, 1 = For, 2 = Abstain
        uint8 voteWay = 1; // voting yes for the proposal
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1); // Move time forward to allow proposal to pass
        vm.roll(block.number + VOTING_PERIOD + 1);
        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 3. Queue the TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1); // Move time forward to allow execution
        vm.roll(block.number + MIN_DELAY + 1);

        // 4. Execute the proposal
        governor.execute(targets, values, calldatas, descriptionHash);

        assert(box.getNumber() == valueToStore);
    }
}
