# LRN Specification

An LRN is validated operational knowledge reusable by an ANS during runtime. It describes a bounded operational pattern, not authority to act.

Every `*.json` record in `lrns/` must conform to `schemas/lrn.schema.json` and include a stable ID, semantic version, lifecycle status, creator, scope, trigger, procedure, evidence, limitations, negative evidence, and rollback or stop conditions.

The directory is part of the status control: proposals belong in `lrns/proposed`; active records require a linked independent validation event. `lrns/examples/` is reserved for **EXAMPLE — NOT VALIDATED** records and is never a source of runtime knowledge.

LRNs must be explicit about applicable conditions, known failure modes, dependencies, and limits. An LRN cannot self-authorize execution, change governance, or claim truth merely by being stored here. Commercial attributes live in a separate, versioned commercial listing: an LRN version and its economic contract version are different identifiers, and a listing cannot alter governance.
