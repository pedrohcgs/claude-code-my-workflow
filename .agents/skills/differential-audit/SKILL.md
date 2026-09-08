---
name: differential-audit
description: "Compare two implementations of the same thing — a port (R↔Python), a reimplementation, a replication package, a refactor, or a new version against the old — so that agreement means something. Freeze inputs first, inventory every expected output, test the comparator itself, compare every channel (not just the headline number), and give each divergence a stable ID and a smallest witness. Use for cross-language parity, replication, upgrade/regression gates, or whenever \"the numbers match\" is about to license a claim."
---




# Make agreement mean something

Two implementations agreeing proves they satisfy a **prespecified contract**. It does not prove either is correct, and it never validates the method or its assumptions. Both can be wrong in the same way — especially when one was written by reading the other. Design the comparison so that agreement is informative and disagreement is legible.

**Rule: freeze before you compare; test the comparator before you trust it.**

## 1. State the claim and the reference

Write down: what is being compared, which side is the reference, and **what agreement would and would not establish**. "Matches the R package" is a conformance claim, not a correctness claim. Say so explicitly, so nobody later reads parity as validation.

## 2. Freeze the inputs before inspecting anything

Record and fix: data versions or hashes, code and package versions, random seeds or realized sample splits, options and defaults, the outputs to be compared, and the acceptance thresholds. Freezing *after* a first look invites tolerance drift toward whatever the run produced.

Do **not** compare defaults across systems as if only the language changed. Map the choices explicitly — a "default" is a substantive modeling decision that usually differs between implementations.

## 3. Declare tolerance classes, and make them binding

Do not carry a single fuzzy epsilon. Classify each output:
- **EXACT** — names, ordering, sample masks, counts, statuses, return/error codes, warning classes, option defaults. Byte-equal after documented normalization.
- **Scalar numeric** — deterministic estimates, standard errors, p-values, critical values. State absolute and relative tolerances and the justification.
- **Matrix/vector** — covariance matrices, influence summaries, weight vectors, plot data.
- **Stochastic** — must meet a prespecified error-rate criterion with uncertainty reported.

A looser tolerance may be used **only through a recorded approved divergence** with a reason. Silent widening is the most common way a parity gate stops testing anything.

## 4. Crosswalk and output inventory

Write the mapping between the two implementations, plus an inventory of every expected output with expected row/cell counts. Every declared object must have a **live comparison or an explicit out-of-scope reason**. Without an inventory, both sides can silently omit the same result and the comparison reports success.

## 5. Build cases that isolate mechanisms

Not just the happy path:
- analytically solvable or known-truth cases;
- relevant data problems (missing, unbalanced, near-collinear, extreme-but-valid weights, shuffled row order, ties);
- **compound** cases combining several problems;
- published examples;
- randomized valid designs across the supported surface, not a handful of fixtures.

Fixed fixtures are necessary but not sufficient — they test what the author already thought of.

## 6. Test the comparator itself

Before trusting a green result, feed the comparison a wrong value, a missing result, a misaligned row, and an empty result. **It must fail, not skip.** A comparator that silently passes over what it cannot reconcile turns every subsequent green into noise. (See `vaccinate`.)

## 7. Compare every declared channel

Not only the headline coefficient: estimates, uncertainty measures, sample counts, labels and ordering, diagnostics, warnings, and failure statuses. Divergent warnings and differing error behavior are real defects — they change what a user does next.

## 8. Give every divergence an ID and a smallest witness

For each difference: a stable identifier, the smallest reproducible case, and a classification — **defect / intentional difference / limitation of the reference / unresolved**. Unresolved stays red; it is not averaged away or waived. A fix must turn its witness green **and** survive a rerun of the full audit, so a local patch does not break something else.

## 9. Adversarial expansion by someone else

Fixtures written by the implementer test the implementer's mental model. Have an independent reviewer add designs **not shared in advance**, and preserve any that reveal bugs or materially increase coverage as permanent fixtures. This is the cheapest defense against a suite that passes because it was written to pass.

## 10. Close with separate reviews and an honest scope statement

End with distinct scientific and implementation sign-off, recording: checks run, open findings, accepted differences, explicit non-claims, and who approved release. State plainly that the audit establishes conformance to the frozen contract — not the truth of the method.

## Minimum checklist

1. Name the reference; state what agreement would and would not establish.
2. Freeze versions, hashes, seeds, options, outputs, tolerances.
3. Declare binding tolerance classes; record any approved divergence.
4. Crosswalk + expected-output inventory with counts.
5. Known-truth, dirty, compound, and randomized cases.
6. Seed comparator faults — it must fail, not skip.
7. Compare all channels, including warnings and failures.
8. Stable ID + smallest witness + classification per divergence; unresolved stays red.
9. Independent reviewer adds unseen designs.
10. Separate sign-offs; state the non-claims.

## Cross-references

- [`provenance-and-ground-truth.md`](../../../.codex/references/provenance-and-ground-truth.md) — ranked oracles, declared precedence, the divergence taxonomy
- [`.codex/guidance/replication-protocol.md`](../../../.codex/guidance/replication-protocol.md) — the tolerance contract

