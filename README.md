# ANS / LRN Foundation

This repository is the governed registry for reusable operational knowledge.

**ANS** (Artificial Nervous System) perceives, reasons, executes, receives feedback, and learns. **LRN** (Learned Runtime Node) is *validated operational knowledge that can be reused by an ANS during runtime*. **ISA** is the integrity, audit, and governance framework around both.

`ANS = operational nervous system`  
`LRN = validated operational knowledge`  
`ISA = integrity / audit / governance`

> Intelligence can recommend. Authority must be granted. Execution must be controlled. Learning must be governed.

An LRN is not a prompt, simple memory, model, model weight, arbitrary instruction, or knowledge automatically true. Validation grants an operational status on available evidence; it never grants permanent truth.

## Foundation status

This repository contains no real LRNs. Its sole demonstration artifact is explicitly **EXAMPLE — NOT VALIDATED** and cannot be activated.

## START HERE

1. Become Creator → 2. Propose an LRN → 3. Structural validation → 4. Testing → 5. Request human validation → 6. Validator review → 7. Activation → 8. Monitoring → 9. Revalidation → 10. Audit → 11. Economic usage.

`Creator → LRN → Validator → Audit → Activation → Usage → Revenue`  
`User → Discovery → Usage → Metering → Economic Event`

Structural validation validates formats and governed references only. Human/operational validation is an independent, versioned decision event; no AI, prompt, creator, workflow, or script may grant operational authority.

Start with [the creation and validation guide](HOW_TO_CREATE_AND_VALIDATE_AN_LRN.md). The policy sources are [Governance](GOVERNANCE.md), [LRN specification](LRN_SPEC.md), and the [validation protocol](VALIDATION_PROTOCOL.md).

The planned commercial layer is specified in [Economic model](ECONOMIC_MODEL.md), [usage metering](ECONOMIC_USAGE.md), and [marketplace model](LRN_MARKETPLACE.md). It is data and governance only: no payment, wallet, token, cryptocurrency, or blockchain is implemented here.

## Layout

- `lrns/` — lifecycle-managed LRN JSON records; `lrns/examples/` is demonstration-only.
- `validation-events/` and `audits/` — append-only decision records.
- `schemas/` — machine-readable constraints.
- `.github/` — least-privilege checks and contribution forms.

Run `powershell -ExecutionPolicy Bypass -File scripts/validate.ps1` before opening a pull request.
