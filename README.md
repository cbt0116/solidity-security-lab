# Solidity Security Lab

A small Foundry-based learning repository demonstrating a classic Solidity withdrawal vulnerability and a basic mitigation using the checks-effects-interactions (CEI) pattern.

The current source contains two contracts in `src/UnsafeExamples.sol`:

- `UnsafeWithdraw`: intentionally vulnerable teaching example.
- `SaferWithdraw`: a basic CEI-style example that clears the caller's recorded credit before making the external call.

> **Local education only.** Do not deploy these examples or send real funds to them. This repository is not an audit, security tool, or production-ready vault.

## Learning objectives

- Understand why external calls can transfer control to another contract.
- Recognize the reentrancy risk created by updating accounting after an external call.
- Compare an unsafe withdrawal flow with a CEI-style state update.
- Practice reading and testing Solidity contracts with Foundry.

## The vulnerability: state update after external interaction

In `UnsafeWithdraw.withdraw()`, the contract:

1. Reads the caller's recorded credit.
2. Sends ETH to the caller using `call`.
3. Only after the external call succeeds, sets the caller's credit to zero.

Because the recipient receives control during the external call, a malicious contract can call back into `withdraw()` before its recorded credit has been cleared. This is the classic reentrancy pattern.

## The basic mitigation: checks-effects-interactions

`SaferWithdraw.withdraw()` follows this order:

1. **Checks:** reads the caller's credit and requires it to be greater than zero.
2. **Effects:** sets the caller's credit to zero.
3. **Interactions:** transfers ETH to the caller.

If the external transfer fails, the transaction reverts, including the earlier state update.

This is an educational illustration of CEI, not a complete security guarantee. Real contracts need broader threat modeling, tests, and review. A reentrancy guard may also be appropriate depending on the complete contract design and its external-call paths.

## Requirements

- [Foundry](https://book.getfoundry.sh/) (Forge)
- Solidity 0.8.24, configured in `foundry.toml`

## Setup

Clone the repository:

```bash
git clone https://github.com/cbt0116/solidity-security-lab.git
cd solidity-security-lab
```

Build the contracts:

```bash
forge build
```

## Tests

Run:

```bash
forge test
```

**Current status:** no Foundry test directory or test contract is currently included. The command is provided for when tests are added; it should not be interpreted as evidence that the examples have passed security tests.

Recommended tests:

- Deposit and credit accounting for both contracts
- Successful withdrawal and zeroed credit
- Revert when withdrawing with no credit
- A malicious receiver that attempts recursive withdrawals against `UnsafeWithdraw`
- The same attack attempt against `SaferWithdraw`, verifying that the recorded credit cannot be withdrawn repeatedly
- Revert behavior when a recipient rejects ETH
- Fuzz and invariant tests for accounting behavior

## Scope and limitations

The current examples are deliberately minimal:

- They account only for ETH deposits and withdrawals.
- They do not include ownership, access control, pausing, or emergency recovery.
- `SaferWithdraw` uses CEI but does not include a dedicated reentrancy-guard modifier.
- The repository currently has no automated Foundry tests or static-analysis report.
- The README's other proposed topics—access control, oracle manipulation, accounting assumptions, signature replay, and denial of service—are future learning topics, not implemented examples in the current source.

## Responsible use

The vulnerable contract is intentionally unsafe and must remain confined to local learning and testing environments. Do not deploy it to a public network or use it to hold real assets. Treat the safer example as a teaching aid, not as an audited template.

## Roadmap

- Add Foundry unit tests and a malicious reentrant receiver
- Add fuzz and invariant tests for withdrawal accounting
- Add separate, clearly labeled examples for access-control and signature-replay mistakes
- Explore oracle freshness and manipulation risks in isolated examples
- Add static-analysis output and document tool versions and findings

## License

The source file declares the MIT SPDX identifier. Add a repository-level LICENSE file to make the reuse terms clear to visitors.
