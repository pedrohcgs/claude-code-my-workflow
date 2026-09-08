---
name: diagnose
description: "Root-cause a failing or wrong empirical result with a disciplined reproduce → minimise → hypothesise → instrument → fix loop, instead of guessing-and-poking. Use when the user says \"why is my regression wrong\", \"this number changed\", \"my script errors out\", \"the result won't reproduce\", \"debug this\", \"this estimate looks wrong\", or \"it worked yesterday\". Tuned for research code (R/Python): type coercion, NA/merge blow-ups, factor levels, clustering/SE choices, weighting, collinearity/convergence, seeds, package-version drift. Use `--no-fix` to localize the root cause without editing shared or load-bearing files."
---



# $diagnose — Root-Cause a Wrong or Failing Result

Find *why* an analysis errors, returns the wrong number, or won't reconcile — with a structured debugging loop rather than scattershot edits. Adapted from the `diagnose` pattern in [mattpocock/skills](https://github.com/mattpocock/skills), reshaped for empirical research code where the bug is usually a *silent* wrong number, not a crash.

The discipline: **never edit before you can reproduce, and never fix before you can explain.** A guessed fix that makes the symptom disappear without a named root cause is how a wrong number gets *laundered* into a published table.

## When to use

- A regression / estimate returns a value you can't explain, or one that changed when nothing should have.
- A script errors out and the stack trace doesn't point at the real cause.
- A result "won't reproduce" — different number on re-run, on another machine, or after a package update.
- A replication claim fails `$audit-reproducibility` and you need to localize *which* step drifted.

**Diagnose is symptom-driven and single-target: ONE wrong number / ONE failing run.** Use a sibling instead when the job is different:

- [`$audit-reproducibility`](../audit-reproducibility/SKILL.md) — verify *all* numeric claims in a manuscript against current code (claim-driven, whole-paper). If you have one FAILing claim and want to localize which pipeline step produced it, `$audit-reproducibility` hands off *to* `$diagnose`; if you want to re-check every table number, start there.
- [`$review-r`](../review-r/SKILL.md) — code-quality review with **no specific symptom**.
- [`$capture-environment`](../capture-environment/SKILL.md) — snapshot the environment when version/seed drift is the suspect.

## Phases

### Phase 0 — Pin the symptom (expected vs. actual)

State the bug as a falsifiable gap before touching anything:

- **Expected:** the value/behaviour you believe is correct, and *why* (a prior run, a paper table, a hand calculation, a theoretical sign).
- **Actual:** the value/error observed now, copied verbatim (full message, not a paraphrase).
- **Tolerance:** the threshold that separates "same" from "different", keyed to the source of *expected* — prior run on the same machine → machine-epsilon + display rounding; a published table → rounding + small slack (~1e-3); a hand calculation → ~0.01; a theoretical prediction → an economic-significance band, not a decimal. Don't chase 1e-12 floating-point noise; don't wave away a 5% gap. (See [`replication-protocol.md`](../../../.codex/guidance/replication-protocol.md).)

If expected/actual can't be stated, the task is *understanding*, not diagnosis — stop and clarify first.

### Phase 1 — Reproduce deterministically (get a reliable red)

A bug you can't reproduce on demand can't be fixed, only hidden.

1. Fix every source of nondeterminism: set the seed, pin the working directory, record `sessionInfo()` / `pip freeze` / Python `version` (lean on [`$capture-environment`](../capture-environment/SKILL.md)).
2. Re-run the smallest unit that exhibits the bug and confirm it fails **every time**. An intermittent failure is its own hypothesis (uninitialised RNG, order-dependent merge, race in parallel code) — note it and carry it into Phase 3.

### Phase 2 — Minimise to an MWE

Shrink until the bug sits in the open:

- **Data:** subset to the smallest rows/columns that still reproduce (often one group, one period, a handful of rows).
- **Code:** strip the pipeline to the shortest path from input to wrong output; comment out everything the symptom survives without.
- Each removal that *keeps* the bug is information; each that *kills* it is a stronger signal — record which.

The MWE is the deliverable even if the fix is later trivial: it's what makes the root cause undeniable.

### Phase 3 — Hypothesise (enumerate, then rank)

List candidate causes *before* testing any — a written list beats poking because it prevents fixating on the first idea. For research code, walk the usual suspects (all of these run cleanly with **no error message** — they are silent-wrong-number bugs):

- **Types & coercion** — a numeric read as character/factor; integer overflow; date parsed wrong; `TRUE/FALSE` ↔ `1/0`.
- **Missingness** — `NA` dropped silently, `na.rm` flipping a mean, listwise deletion changing the sample mid-pipeline.
- **Joins & shape** — a many-to-many merge inflating rows; duplicate keys; an unbalanced panel where balance was assumed.
- **Specification** — wrong clustering level, fixed effects absorbed twice, a lag/lead off by one.
- **Bad controls & colliders** — a control that is post-treatment, a mediator on the causal path, or a descendant of treatment (adding it *induces* bias, invisibly). The tell: a coefficient that moves the "wrong way" or shrinks implausibly when a control enters.
- **Numerical stability & convergence** — an optimizer that didn't converge (check the convergence code, not just the estimates), a singular/near-singular Hessian, collinearity (high VIF, a dropped column), tolerance set too loose, under/overflow with very small/large weights or coefficients.
- **Weighting & aggregation** — weights silently dropped/truncated, weights renormalised wrong, frequency vs. probability vs. analytic weights confused, a weight applied *after* rather than *before* a transform.
- **Sample** — a filter that runs before vs. after a transform; an outlier rule applied inconsistently.
- **Environment** — a package/Python version bump that changed a default; a seed that moved; locale/encoding.

For a genuinely ambiguous bug, fan out the top competing hypotheses to parallel `Agent` subagents (one per hypothesis, `context: fork`), each instructed to *try to confirm its own cause on the MWE* and report back — the loop-first analogue of asking three colleagues at once (see [`orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md)).

### Phase 3b — Reduce the hypotheses (so you don't launder a guess)

Each hypothesis (whether tested by hand or by a delegated subagent) returns `{hypothesis, evidence for, evidence against, confidence, one-line conclusion}`. Then:

- **One clear winner** (high confidence, others refuted) → proceed to Phase 4 to confirm the mechanism.
- **A near-tie** (top two within ~20 percentage points) → do *not* pick one; go to Phase 4 instrumentation to discriminate.
- **None above ~50%** → report ambiguity and ask the user; do not edit on a coin-flip.

### Phase 4 — Instrument & localize (bisect, don't stare)

Test the ranked hypotheses cheaply:

- **Bisect the pipeline** — check the intermediate value at the midpoint of the data flow; the bug is upstream or downstream of it. Repeat. Binary search finds the offending line in `log2(n)` steps, not `n`.
- **Bisect history** — if it "worked yesterday", compare against the last-good commit/output to pin the change that introduced it. (`git bisect` is fine here — it never discards work; the destructive git commands are blocked by `git-guardrails.py`, this is not one of them.)
- **Instrument with diagnostic primitives**, not guesses — at each stage inspect: `str()` / `summary()` for types & NA patterns; row & column counts *before and after* every transform; `table(factor)` to catch a silently dropped level; `cor()` / VIF for unexpected collinearity; weight diagnostics `range(w)`, `sum(w)`, `table(is.na(w))`; and the regression's convergence flag. **The stage where a count drops unexpectedly, a factor level vanishes, correlation jumps, or weights go sparse is the culprit stage.**

End Phase 4 with a one-sentence root cause naming the exact line/step and mechanism.

### Phase 5 — Fix & verify (then guard against regression)

**Confidence gate (the anti-laundering rule):** do not apply a fix unless the root cause is named **and** its mechanism is explicit. If Phase 3b left a near-tie, behave as `--no-fix`: report the candidates and ask. Editing research code on an unproven hypothesis is exactly the laundering this skill exists to prevent.

Unless `--no-fix` is set:

1. Apply the **minimal** fix at the root cause — not a downstream patch that masks it (prefer fixing the bad merge over filtering its duplicate rows afterward).
2. Re-run the MWE → confirm `actual == expected` within the Phase-0 tolerance.
3. Re-run the **full** unit and any dependent step → confirm the fix didn't move another number. If the result feeds a manuscript claim, re-check it (cross-ref the passport in [`$audit-reproducibility`](../audit-reproducibility/SKILL.md)).
4. Note a **prevention** — the assertion/check that would have caught this earlier. One concrete guard per bug class:

   | Bug class | One-line guard |
   |---|---|
   | Types & coercion | `stopifnot(is.numeric(x))` after read |
   | Missingness | explicit `na.rm = FALSE`; `stopifnot(sum(is.na(x)) == 0)` |
   | Joins & shape | record `nrow` pre-merge; `stopifnot(nrow(out) == nrow(left))` for a 1:1 join |
   | Weighting | `stopifnot(abs(sum(w) - 1) < 1e-8)` or `!anyNA(w)` |
   | Convergence | assert the optimizer/model convergence flag is OK before using estimates |
   | Sample | one explicit `filter()` with a stated reason, not a mid-pipe drop |
   | Environment | pin versions in `renv.lock`; `set.seed()` at the top of each script |

   Propose the guard; don't silently install a test suite.

With `--no-fix`, stop after the root cause is named and report it for the user to fix by hand.

## Worked example

A demand-forecasting model's held-out `MAE` jumped from `0.043` to `0.071` after a data refresh; nothing in the spec changed.

```r
# Phase 1 — reproduce: set.seed(1); same script, same number every run. Red is stable.

# Phase 2 — MWE: one region, two horizons still shows the jump.
#           Strip to: read panel -> merge features -> lm(). Bug survives the merge step.

# Phase 4 — instrument: row counts before/after each step
nrow(panel)                          # 12,400  (expected)
nrow(merge(panel, feats, by="id"))   # 12,933  <-- inflated! a many-to-many merge

# Root cause: the refresh left duplicate feats rows for a subset of ids; the
# join fans those ids out, 12,400 -> 12,933 (+533 rows), re-weighting the MAE
# toward the duplicated units.

# Phase 5 — minimal fix at the root (dedup the key), NOT a downstream row filter:
feats <- feats[!duplicated(feats$id), ]
# re-run: MAE back to 0.043 within tolerance; full pipeline re-checked, no other number moved.

# Prevention (Joins & shape guard):
stopifnot(nrow(merge(panel, feats, by = "id")) == nrow(panel))
```

## Output / report format

Write a short diagnosis to `quality_reports/diagnoses/YYYY-MM-DD_<slug>.md` (create the directory first: `mkdir -p quality_reports/diagnoses`). These reports may contain **real data values and file paths — they are project-internal and gitignored**, like session logs. Include:

- **Symptom:** expected vs. actual (+ tolerance).
- **MWE:** the minimal input/code that reproduces it.
- **Root cause:** the exact line/step and mechanism.
- **Fix:** the diff applied (or, with `--no-fix`, the recommended change).
- **Verification:** MWE + full-run re-check results.
- **Prevention:** the guard that would have caught it.

Plus a chat summary leading with the one-line root cause.

## Cross-language notes

The usual-suspects model is illustrated in R but the bug *classes* are language-neutral; the diagnostic idioms differ:

- **R** — `anyNA()` / `table(is.na(x))`; factors silently drop unused levels; `set.seed()`; `sessionInfo()`.
- **Python** — `tab v, missing` and explicit `.`/`.a–.z` extended missing; `set seed`; `version`; weights as `[fw=]` vs `[pw=]` vs `[aw=]` is a frequent silent bug.
- **Python** — `df.isnull().sum()`; `numpy.nan` ≠ `None`; pandas vs numpy NaN handling differ; `np.random.seed()` / a passed `random_state`; `pip freeze`.

(Forkers in other fields: the five structural classes — Types, Missingness, Joins, Sample, Environment — are discipline-neutral; the econometric suspects above are the worked instance.)

## Exit behavior

| Outcome | Action |
|---|---|
| Root cause **NAMED** (high confidence), fix applied, re-verified | report root cause + diff + prevention |
| `--no-fix` | stop at a named root cause; write the report, make **no** edit to source |
| **Phase 0 blocked** (no pythonble expected/actual) | halt, ask for the expected value — diagnosis needs a target |
| **Phase 1 blocked** (cannot reproduce / nondeterminism) | report the nondeterminism *as* the finding (it is the bug class) + how to make the analysis deterministic; do not edit blindly |
| Phase 3b **near-tie / <50%** | report the competing hypotheses and ask the user; do not apply a fix |

## Flags

- `--no-fix` — Diagnose only: run through naming the root cause (Phases 0–4) and write the report, but make **no** edit to source. Use when you want to apply the fix yourself, or when the file is shared/load-bearing and an automated edit is inappropriate.

## Step 0 — State the contract before touching anything

Before proposing or writing **any** fix, state in 3–5 bullets and **stop for confirmation**:

1. What the function's or pipeline's **documented contract** is.
2. What the reporter claims is broken.
3. Whether the reported scenario is even **in contract** — a caller violating the contract is
   not a bug in the callee.
4. What the **correct behaviour** would be.
5. What evidence would settle it.

This costs thirty seconds and prevents the most expensive class of wasted work: a confident fix
to a misunderstood contract. In one logged case the same semantic point had to be corrected
**twice** before a fix was scoped right, because the agent asserted a stance on the contract
rather than restating it and asking.

> **Severity follows the contract.** A scenario outside the documented contract is at most a
> documentation or validation issue, never a high-severity correctness bug. Inflating it
> because it *looks* wrong is how a fix ends up changing behaviour users depend on.

## Separate the audit pass from the repair pass

The strongest outcomes in the logged sessions began as **investigations**, not fix requests.
The messier ones mixed auditing with editing.

**Audit pass — read-only.** Produce a findings table: `severity | file:line | claim | evidence I
actually ran | proposed fix`. Mark anything not verified by execution as **UNVERIFIED**. Edit
nothing.

**Repair pass — on approved rows only.** The user picks which findings get fixed. This is
what makes declining a finding cheap, and declining findings is how scope stays bounded.

`--no-fix` runs the audit pass alone.

## Cross-references

- [`.agents/skills/review-r/SKILL.md`](../review-r/SKILL.md) — code-quality review with no specific symptom (diagnose is symptom-driven).
- [`.agents/skills/audit-reproducibility/SKILL.md`](../audit-reproducibility/SKILL.md) — verify all numeric claims against code; diagnose localizes a *single* failing one (and is the natural hand-off from a FAIL).
- [`.agents/skills/capture-environment/SKILL.md`](../capture-environment/SKILL.md) — snapshot the environment when version/seed drift is the suspect.
- [`.codex/guidance/replication-protocol.md`](../../../.codex/guidance/replication-protocol.md) — the tolerance contract that defines "same number", and the "If Mismatch" hand-off to this skill.
- [`.codex/guidance/orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md) — the fan-out primitive used for competing-hypothesis testing in Phase 3.

## What this skill does NOT do

- **Review code with no symptom** — that is [`$review-r`](../review-r/SKILL.md). Diagnose needs an expected-vs-actual gap to chase.
- **Re-audit every claim in a paper** — that is [`$audit-reproducibility`](../audit-reproducibility/SKILL.md). Diagnose fixes one bug deeply.
- **Build a test suite** — it proposes the single guard that would have caught *this* bug; standing test infrastructure is separate dev work.
- **Commit the fix** — branching / committing is [`$commit`](../commit/SKILL.md)'s job.

