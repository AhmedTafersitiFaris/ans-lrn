# LRN Economic Model

This is a future-facing marketplace/API specification. It implements no real payment, financial account, wallet, token, cryptocurrency, or blockchain.

## Parties and separation

- **Creator** produces and maintains an LRN and may receive an LRN usage royalty.
- **User** is a person, software, ANS, organization, company, or API client that may use an LRN.
- **Validator** verifies an LRN; any compensation is for documented review work, never approval.
- **Auditor** performs later audits; any compensation is for documented audit work, never conclusion.
- **Platform** manages catalog, discovery, versions, metering, billing interfaces, distribution, and governance interfaces.

The creator never controls validation, buys validation, removes negative evidence, changes independent audits, or gains authority over an ANS. A royalty pays for creation and maintenance, not validity.

## Value is not validity

`market demand ≠ epistemic validity` · `payment ≠ authority` · `price ≠ quality` · `revenue ≠ correctness` · `popularity ≠ validation`

An LRN may be validated without high market value, or valuable without being validated. The marketplace presents verifiable status and evidence; it must never claim an LRN is true.

## States and eligibility

Governance state is controlled by the LRN lifecycle: `proposed`, `testing`, `validated`, `active`, `suspended`, `retired`. Commercial state is separate: `not_listed`, `listed`, `commercial`, `restricted`, `free`, `deprecated`, `unlisted`.

Commercial state cannot modify governance state. A `proposed` or `testing` LRN cannot be commercialized as operational. A commercial operational listing requires the policy-required governance state (at minimum `validated`; policy may require `active`). `suspended` and `retired` records cannot be sold for operational use.

## Pricing, distribution, versioning, and conflicts

Pricing models are `free`, `fixed`, `usage_based`, `subscription`, `enterprise`, and `custom`. A schedule can record currency, unit, price, effective_from, and effective_until; units may include `per_use`, `per_execution`, `per_1k_invocations`, `per_day`, `per_month`, `per_output`, or `per_validated_result`.

Revenue distribution is policy configuration, never hard-coded: `creator`, `platform`, `governance`, `review_pool`. Conceptually: user payment → total revenue → configured shares. Events are conceptual, not financial transactions.

Every listing references one exact LRN ID and LRN version. `economic_contract_version` versions price/distribution terms independently and cannot change the LRN. Review records declare `conflict_of_interest` (`declared`, `type`, `description`, `mitigation`); no real people or conflicts are implied.
