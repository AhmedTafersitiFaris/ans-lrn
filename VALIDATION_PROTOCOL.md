# Validation Protocol

Validation checks structural coherence, evidence traceability, defined scope, reproducibility where feasible, limitations, and counterexamples. It does not establish truth.

## Two distinct layers

Structural validation checks JSON, IDs, versions, timestamps, allowed states, references, and event relationships. It cannot assess evidence sufficiency, world correctness, epistemic quality, or operational authority. Human/operational validation is the separately versioned decision recorded in `validation-events/`; only governance may apply a resulting state transition.

## Independent review

A validator must not be the creator or a conflicted reviewer. The validation event records identities, conflicts/recusal, reviewed evidence, tests, negative evidence, decision, limits, and timestamp. The required form is `schemas/validation-event.schema.json`.

For activation, an approved event must reference the exact LRN ID and version, and the LRN must list that event. Structural checks enforce this; human review evaluates substance.

## Decision and challenge

Decisions are `approved`, `changes_requested`, `rejected`, or `suspended`. Audits and counter-audits create new records rather than rewrite old decisions. New credible evidence triggers revalidation; serious risk can suspend first and investigate next. Auditors are themselves auditable.
