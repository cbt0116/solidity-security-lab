# Solidity Security Lab

A small Foundry-based learning repository demonstrating a classic Solidity withdrawal reentrancy vulnerability and a basic mitigation using the checks-effects-interactions (CEI) pattern.

The repository contains two withdrawal contracts in `src/UnsafeExamples.sol` and a local reentrancy attacker plus Foundry tests in `test/Reentrancy.t.sol`.

> **Local education only.** Do not deploy these examples or send real funds to them. This repository is not an audit, security tool, or production-ready vault.

## Learning objectives

- Understand why external calls can transfer control to another contract.
- Recognize the reentrancy risk created by updating accounting after an external call.
- Compare an unsafe withdrawal flow with a CEI-style state update.
- Write and run Solidity tests with Foundry.
- Observe how a malicious receiver can recursively call a withdrawal function.

## Contracts

### `UnsafeWithdraw`

This is an intentionally vulnerable teaching example. Its `withdraw()` function sends ETH to the caller before clearing the caller's recorded credit. A recipient contract can re-enter while that credit is still available.

### `SaferWithdraw`

This example checks that the caller has a positive credit, clears the credit, and only then makes the external call. If the transfer fails, the transaction reverts, including the state update.

This demonstrates CEI for this simple withdrawal path. It is not a complete security guarantee; real contracts need broader threat modeling, testing, and review. A reentrancy guard may also be appropriate depending on the full contract design and its external-call paths.

## Reentrancy demonstration

The test helper `ReentrantReceiver` deposits one ether and calls `withdraw()`. When it receives ETH, its `receive()` function attempts another withdrawal while the target has enough ETH for another one-ether payout.

The tests demonstrate the intended contrast:

- Against `UnsafeWithdraw`, the receiver can repeatedly withdraw using the uncleared credit and drain the target's five-ether test balance in addition to its own one-ether deposit.
- Against `SaferWithdraw`, the first withdrawal clears the receiver's credit before the callback. The recursive withdrawal therefore reverts, and the target's five-ether balance remains.

These are controlled local test scenarios, not instructions to attack a live contract.

## Requirements

- [Foundry](https://book.getfoundry.sh/) (Forge)
- Solidity 0.8.24, configured in `foundry.toml`

The test file uses the standard Foundry cheatcode address directly and does not require importing `forge-std`.

## Setup

Clone the repository:

```bash
git clone https://github.com/cbt0116/solidity-security-lab.git
cd solidity-security-lab
```

Build the contracts and tests:

```bash
forge build
```

Run the test suite:

```bash
forge test -vv
```

## Tests included

| Test | What it checks |
|---|---|
| `testUnsafeWithdrawCanBeDrainedByReentrancy` | The malicious receiver repeatedly withdraws from the intentionally vulnerable contract |
| `testSaferWithdrawBlocksReentrancy` | CEI prevents the receiver from withdrawing the same credit again |
| `testSaferWithdrawReturnsDepositedEther` | A normal deposit and withdrawal update balances as expected |
| `testSaferWithdrawRejectsEmptyCredit` | A caller with no credit cannot withdraw |

The tests use Foundry's local `vm.deal` cheatcode to fund the test contract. No live network or real funds are involved.

## Scope and limitations

The examples are deliberately minimal:

- They account only for ETH deposits and withdrawals.
- They do not include ownership, access control, pausing, or emergency recovery.
- `SaferWithdraw` uses CEI but does not include a dedicated reentrancy-guard modifier.
- The tests cover the specific withdrawal scenario shown here; they are not comprehensive fuzz, invariant, or formal verification.
- The repository does not include a static-analysis report or independent security review.
- Other topics such as access-control mistakes, oracle manipulation, accounting assumptions, signature replay, and denial of service are future learning topics, not implemented examples.

## Responsible use

The vulnerable contract is intentionally unsafe and must remain confined to local learning and testing environments. Do not deploy it to a public network or use it to hold real assets. Treat the safer example as a teaching aid, not as an audited template.

## Roadmap

- Add fuzz and invariant tests for withdrawal accounting
- Add separate, clearly labeled examples for access-control and signature-replay mistakes
- Explore oracle freshness and manipulation risks in isolated examples
- Add static-analysis output and document tool versions and findings

## License

The source file declares the MIT SPDX identifier. Add a repository-level LICENSE file to make the reuse terms clear.
