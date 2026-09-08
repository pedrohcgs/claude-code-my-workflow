---
name: blast-radius
description: "Before and after changing anything shared — a function's return value, a signature, a schema, a label set, a config default, a constant, a file format — find every consumer and actually run them. Catches the change that looks purely additive but silently breaks a contract in a file you never opened. Use when editing shared code, adding a field/column/return element, renaming, changing units or defaults, or touching a pipeline that produces reported numbers."
---




# Know the blast radius before you change it

The dangerous change is not the risky-looking one. It is the one that **looks purely additive** — adding a returned value, a column, an option — and quietly violates a contract three files away that nobody re-read. Compilation and type checks will not catch a positional or length contract; you get either a crash far from the edit, or worse, silently wrong output.

**Rule: if you change a shared interface, run its consumers. Reading them is not running them.**

## 1. Enumerate consumers before editing

Grep for every call site, import, and downstream reference — including tests, notebooks, scripts, docs, and anything that regenerates reported results. Note which ones produce numbers that appear in a paper, dashboard, or release: those are the ones where silent breakage is most costly.

If a consumer lives in another repo, another language, or a generated artifact, write it down now; you will not remember at verification time.

**A consumer in another repo pins this one by commit SHA.** Its verification receipt records the *revision* it was built against — not a branch, not a version string, both of which keep moving under it. So **a change here that moves a number the downstream reports is not finished when this repo goes green**: before/after evidence for what moved, regeneration of the downstream artifact, and the re-pin all belong to the *same round* as the change — [`release-engineering.md`](../../../.codex/references/release-engineering.md) §6 has the ordering within it. A downstream left pinned to the old SHA is an honest, inspectable state; one pointed at a moving reference silently inherits a number nobody re-verified.

## 2. Name the contract you are about to change

Ask explicitly what downstream code is entitled to assume:

- **Arity / length** — does anything index positionally, zip against a fixed list, or preallocate a matrix of known width? *Adding an element breaks all three.*
- **Names and order** — does anything match by name, by position, or pair your output against a separate parallel list of labels?
- **Types, units, scale** — dollars vs cents, rate vs percent, seconds vs ms, 0-indexed vs 1-indexed.
- **Nullability and sentinels** — new empty/NA cases a consumer will not expect.
- **Defaults** — changing a default silently changes every caller that relied on it.
- **Identity/ordering guarantees** — row order, sort stability, key uniqueness.

The classic failure: a returned vector grows from 6 to 7, while a consumer pairs it against a hard-coded list of 6 labels. Nothing errors at the edit site; the consumer either throws far away or, worse, recycles and mislabels every row.

## 3. Prefer changes that cannot break a contract

Additive-and-named beats additive-and-positional. Where you control the consumer, match by name rather than position. Where you cannot, version the interface rather than widening it in place.

Do **not** "fix" a mismatch by deriving labels/config from the new data if the old labels were deliberately different — deliberate relabeling exists (display names differing from internal names), and auto-deriving silently changes published output.

## 4. Run the consumers — end to end, on real inputs

A consumer that merely imports is not exercised. Run at least one full path per distinct consumer pattern, and prefer the one that regenerates reported numbers.

Then verify **both** directions:
- The new thing works.
- **The old things are unchanged.** Diff previously-reported outputs; anything that moved must have a reason you can state. If the change was supposed to be behavior-preserving, byte-identical or within a declared tolerance is the evidence — not "it ran".

## 5. Green is uninformative if nothing ran

Confirm the check actually executed and could have failed: a skipped test, a filtered-out case, an exception swallowed into a default, or a tolerance widened after the comparison are all indistinguishable from success in a log. Where the change is consequential, **seed a defect** and confirm the check goes red — a comparison that cannot fail is not evidence.

## 6. Record the contract change

If the interface genuinely changed, say so where consumers will look: a NEWS/CHANGELOG entry, a versioned interface note, or a comment at the definition naming what downstream code may assume. For anything reused or released, freeze inputs (versions, hashes, seeds) and record declared tolerances so the next comparison is reproducible rather than renegotiated.

## Minimum checklist

1. Grep all consumers, including tests, scripts, docs, other repos/languages.
2. Write down the contract: arity, names, order, types, units, defaults, ordering.
3. Make the change name-based/versioned where you can.
4. Run at least one full path per consumer pattern.
5. Diff previously-reported outputs; explain any movement.
6. Seed a defect to prove the check can fail.
7. Record the contract change where consumers will see it.
8. Re-pin every cross-repo consumer to the new SHA — regenerated and re-verified in this round, not the next one.

## Cross-references

- [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) — rung 2 (wiring)
- [`provenance-and-ground-truth.md`](../../../.codex/references/provenance-and-ground-truth.md) — never re-bless a baseline in the commit that moves it
- [`release-engineering.md`](../../../.codex/references/release-engineering.md) — pinning downstream consumers by SHA, and what a number-moving change owes them in the same round

