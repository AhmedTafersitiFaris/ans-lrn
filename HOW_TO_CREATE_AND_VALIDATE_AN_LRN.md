# How to Create and Validate an LRN

1. Observe a recurring, bounded operational pattern; record it as a proposal, not knowledge.
2. Create JSON from `templates/lrn.template.json` in `lrns/proposed/`, including evidence, negative evidence, limits, and stop conditions.
3. Open a pull request and run the structural validator.
4. Have an independent validator review evidence, reproduce where feasible, seek counterexamples, and record a validation event.
5. Have an independent auditor review the decision path when required by risk or policy. Conflicts and recusals are recorded.
6. Only after the applicable review, move through lifecycle states with linked event records. Monitor it; revalidate, correct, suspend, or retire when evidence changes.

The example in this repository is not a model: it is **EXAMPLE — NOT VALIDATED** and cannot be activated.
