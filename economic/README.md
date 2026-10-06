# Economic simulation registry

This directory records append-only economic simulations and operational cost profiles. It implements no payment, invoice, payout, wallet, entitlement, or governance decision.

`SIMULATION` events are conceptual accounting tests only. They may reference an ineligible LRN, but always have zero payable creator balance and cannot alter governance state. `REAL` events require a commercially eligible LRN in the policy-allowed governance state.

Cost profiles describe resource requirements only. They do not measure quality, correctness, validation, or authority. Simulation fixture profiles may describe hypothetical identifiers without creating an LRN.

Run `scripts/validate-economic.ps1` for registry validation and `scripts/test-economic-firewall.ps1` for executable negative firewall checks.
