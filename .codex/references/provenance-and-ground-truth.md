# Provenance and Ground Truth

**The question this answers:** when you say "the numbers match", *match what*? An estimate is
only as good as the thing you compared it against. This file is how you name that thing,
pin it, and decide who wins when two sources disagree.

Applies to: porting an estimator to another language, replicating a published paper,
reimplementing a method, upgrading a package version, or adopting externally-sourced material.

---

## 1. Name your oracles, with roles and pinned commits

Not "we compared against R." A table, in a `PROVENANCE.md` at the repo root:

| Reference | Role | Observed ref |
|---|---|---|
| `owner/canonical-pkg` | **primary statistical and API oracle** | HEAD `9aba07d…`; version 2.5.1 |
| `owner/other-impl` | deeper-test source | HEAD `555f28b…` |
| `owner/legacy` | legacy-behaviour source | HEAD `fdbae25…` |
| `owner/published-paper` | empirical acceptance suite | HEAD `50f4f18…` |
| `owner/eng-ref` | engineering reference (style/architecture only) | HEAD `f8e303d…` |

**A pinned commit SHA, not a version string.** Versions get re-tagged; commits do not. Where
practical, keep the oracle as a **physical checkout** beside the work — a directory literally
named for the pinned release makes "compared against what?" unambiguous.

Record **per-reference licence notes**, including honest ambiguity:
*"classifiers mention Apache while `setup.py` says MIT — treat MIT as binding until clarified."*

---

## 2. Declare precedence *before* you measure

Two oracles will eventually disagree. Decide who governs **in advance**, or you will decide
it after seeing which answer you prefer.

> `impl-B` raises where `impl-A` warns — **`impl-A` governs parity decisions.**
> `impl-B` expects finite SEs where `impl-A` returns missing — **`impl-A` governs.**

State the general rule too: *R is the benchmark; Python ports must match R, not
the reverse.*

---

## 3. Not every difference is a bug — classify divergence

Give each divergence a **stable ID** and a **kind**, in a tracked `divergence-kinds.csv`:

| Kind | Meaning |
|---|---|
| `behavioral-default` | both are correct; the defaults differ (e.g. a small-sample correction applied by default in one implementation; a different default bandwidth selector) |
| `language-surface` | the construct has no analogue in the target language |
| `language-surface` / `api-surface` | the source exposes something the port deliberately does not |
| `internal-api` | a non-exported internal, out of scope for parity |
| `test-placement` | covered by a different fixture, not missing |
| `upstream-conflict` | the references disagree with each other → precedence rule decides |

```csv
divergence_id,divergence_kind,summary
F051-DIV001,behavioral-default,port applies HC1 small-sample correction by default; reference defaults to HC3
F051-DIV002,behavioral-default,port defaults to analytic SEs; reference defaults to bootstrap
PY010-DIV002,upstream-conflict,Python raises where R warns; R governs parity decisions
```

A `behavioral-default` divergence is **recorded, not fixed**. This is the cross-implementation
form of the `EXPLAINED` disposition: a named, defensible alternative is not a failure.

---

## 4. Coverage is a manifest, not a sample

Do not let a reviewer — human or model — pick what to check. Enumerate the surface and track
coverage across rounds: the upstream package's **own test suite** as a CSV, a feature matrix,
fixture schemas, and declared performance budgets. Then each round *assigns* what to cover.

---

## 5. Tolerances are declared, not discovered

Keep a **tolerance registry**: per comparison, the tolerance and why. Fix tolerances *before*
comparing, or you will tune them until the answer is the one you wanted.

> **The `all.equal` scale trap (R).** `all.equal` computes the mean magnitude over **only the
> elements that differ**; when that mean falls below `tolerance`, the comparison silently
> becomes **absolute** — so the trap fires even in a large, mostly-well-scaled vector whenever
> the differing cells happen to be small (exactly where SEs live). Pass an explicit
> `scale = max(mean(abs(target)), .Machine$double.eps)`, and close every parity file with a
> `tested-set == registered-set` assertion so a silently skipped comparison cannot read as a
> pass.

---

## 6. Never re-bless a baseline in the commit that moves it

Land the change with the **old** pins in place so the gate **reports** the drift. Re-bless in
a **follow-up commit that cites the measurement**. Run the gate green *before* the re-bless
commit, not after.

Re-blessing inside the causing commit leaves an artifact that **cannot distinguish
"measured, then re-blessed" from "re-blessed without measuring."** That ambiguity is the
defect, even when the numbers were fine.

**Attribute before repairing.** When a number moves, establish *whose* change caused it —
re-run the identical check on the unchanged baseline. And *"nothing moved"* is only evidence
if the detector demonstrably fires on a known-affected case (**positive control**).

**Track both sides of every comparison.** A pinned manifest that was never version-controlled
is a comparison whose right-hand side lives in one working tree — not reproducible.

---

## 7. Clean-room boundary (using someone else's work legally)

| Artifact class | Source allowed | Copy policy |
|---|---|---|
| Contract documents | original synthesis from observed behaviour | owned by this repo |
| Reference locks | commit/version metadata from public repos | owned by this repo |
| Fixture inputs | generated here | owned; generator logged |
| Reference expected outputs | generated from the pinned oracle | **allowed as a test oracle** |
| Implementation code | new, written here | **no copying** unless a ledger entry records source path, commit, licence, copied lines, justification, and a licence-compatible decision |

Reference code may be **read** to understand public behaviour, tests, architecture, and
style. **Generated numerical outputs, manifests, behavioural descriptions, and public docs
may be used as test oracles.** Implementation code may not be copied.

**Licence compatibility is a gate, not a footnote.** Copying copyleft-licensed text or code
into a permissively-licensed repo without honouring the copyleft terms is a violation
regardless of how useful it is (LGPL's linking allowances do not cover copying source into
an MIT tree). Reimplement the *idea* independently
and credit it as prior art, or obtain permission and record it in the ledger.

---

## 8. Evidence contracts — make a good report the only kind you can file

Encode the bar as an issue template, so an incomplete report is incomplete *by construction*.
For a numerical discrepancy, require: package version · platform · the exact command · **the
reference command and its output** · design details (panel vs repeated cross-section, groups,
periods, covariates, weights, clustering, bootstrap, aggregation) · the difference observed
**and the expected tolerance** · a reproducible fixture.

State the policy: *reports without a reproducer, a data description, and a reference
comparison may be closed as incomplete.*

---

## Cross-references

- [`verification-ladder.md`](verification-ladder.md) · [`external-oracle-process.md`](external-oracle-process.md)
- [`.codex/guidance/replication-protocol.md`](../guidance/replication-protocol.md) — the tolerance contract
