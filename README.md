# Solidity Security Lab

A small, intentionally limited teaching lab.

## Topics to expand
- Reentrancy and checks-effects-interactions
- Access-control mistakes
- Oracle manipulation and stale prices
- Integer/accounting assumptions
- Signature replay and domain separation
- Denial of service from unbounded loops

The `UnsafeWithdraw` contract is deliberately vulnerable and must only be used in local educational tests. The safer example is not a complete audited pattern. Add Foundry tests and static-analysis results before presenting this as a security portfolio.
