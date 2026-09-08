# The Verification Ladder — how we check, and how we loop

**The premise:** producing the work is no longer the slow part. **Checking it is.** Every
rung below exists because a cheaper rung let something through.

> **The incident this file exists for.** Twenty bugs were deliberately planted in a working
> codebase, and the review agents were asked to check it again. **They reported everything
> was fine.** Recall: 0/20. The fix was not a better prompt — it was to start *measuring the
> checkers*. Think of it as a vaccine: a small, controlled dose of error that strengthens the
> whole system.
>
> **Consequence, and it is the load-bearing rule here: an unqualified check is not weak
> evidence. It is none.**

---

## Rung 0 — Qualify the checker (before trusting any green)

Before a test, gate, comparator, or AI reviewer is allowed to clear anything:

1. **Name the failure** it targets.
2. **Seed that failure** and confirm it goes **red**.
3. **Run a clean control** and count false alarms — a finding on clean work counts only if it
   is *factually false*, not merely unwelcome.
4. **Compare against a simpler baseline.** More agents is not presumed better than grep.
5. **Confirm it actually ran** on the current object.

Record a ledger row: date · artifact · seeded classes · **recall** · **false-positive rate** ·
verdict `PASS / FAIL / BLOCKED`.

**A bad seed reads exactly like a broken gate.** If you seed a defect into an artifact that
already permits the thing you seeded, "all checks pass" is *correct* and you have learned
nothing. Verify the seed creates a real violation first.

**A null needs two controls, not one.** The seeded case (the **positive control**) proves the
checker can fire; it says nothing about how much the checker moves when nothing happened. So an
invariance check — the claim *"this change moved nothing"* — also carries a **noise floor**: a
**same-kind no-op** put through the identical measurement (re-run the unchanged input, apply an
identity transformation, edit the same files without changing semantics), whose observed effect
is the largest movement that still counts as *nothing*. **Fires on the known-affected case and
stays quiet on the no-op** — that pair is what makes a null informative, and either one alone
is decoration. Report the floor next to the null: a "no difference" with no floor under it has
a threshold too — unstated, and chosen after the fact. *Attribute before repairing*
([`provenance-and-ground-truth.md`](provenance-and-ground-truth.md) §6) needs both.

---

## Rung 1 — Deterministic gates (no model in the loop)

Classes that are decidable belong in a script, never in an agent prompt. Agents miss them
because the prompt lists them among many checks and attention drifts. **The script never
drifts.**

- `check-surface-sync.py` — counts and enumerative tables match disk
- `check-skill-integrity.py` — frontmatter ↔ body tool parity, anchors, flag parity
- the model-routing staleness check — superseded model versions presented as current (internal
  consistency against the model SSoT)
- `check-staleness.py` — the **expiry** on that SSoT (`Expires:` fails the gate when past),
  stale recommendations, and source-vs-render divergence. The *external oracle* is the human
  re-verification step in the SSoT's update protocol — no script fetches the docs
- `.githooks/pre-commit` — runs the above on every commit (live only after `install-hooks.sh`)

**A gate that proves internal consistency is not a currency gate.** Surfaces agreeing *with
each other* is compatible with all of them being wrong. Any currency claim needs an external
source **and** a `verified_on` expiry that fails the gate when stale.

---

## Rung 2 — Artifact verification: four layers, in order

| Layer | Question | Typical miss |
|---|---|---|
| **Existence** | is the artifact there? | — |
| **Substantiveness** | is it *real*, or a stub? | placeholder values, hardcoded constants, TODO markers, functions that return the input |
| **Wiring** | is it actually connected? | a figure regenerated but never `\input`, a script whose output nothing reads |
| **Coherence** | do the pieces tell one story that answers the question? | every part passes, the whole is still wrong |

Only the fourth catches "all the checks passed and the paper is still wrong."

**Measure at the level where the quantity is computed — and name that level in the claim.**
Configuration (what was asked for), design (how the run was arranged), and the realized/fitted
result (what the computation actually produced) are three different levels, and evidence at one
does **not** transfer to another: a setting present in a config file is not a design that used
it, and a design is not a result that reflects it. So say which one you inspected — *"the
fitted output reports X"*, not the level-ambiguous *"the analysis uses X"*. Checking the
convenient level instead of the computed one is how an artifact passes all four layers above
while the claim resting on it was never measured at all; the executable form of the same rule
is [`research-agent-laws.md`](research-agent-laws.md) law 6, dispatch on the realized
computation rather than on labels.

---

## Rung 3 — Independence (the fresh-context fork)

A reviewer that has seen the draft cannot un-see it. Three ways to enforce independence, and
they are **not** interchangeable:

| Mechanism | Independence via | Best for |
|---|---|---|
| **Critic + fixer** | role tension (critic cannot fix; fixer cannot approve) | presentation and structural defects |
| **Cross-artifact traversal** | the dependency graph (paper → table → output → script) | paper ↔ code consistency |
| **CoVe fresh-context fork** | context isolation — the verifier never sees the draft | fabricated citations, wrong numbers, misattribution |

Two practices that cost nothing and change outcomes:

- **Independent assessment before reading the plan.** Have the verifier decide what *should*
  exist before it learns what was promised. Otherwise it grades conformance, not adequacy.
- **Blind the judge.** Strip revision markers before a comparison, or it grades the diff.

All three mechanisms operate on the **context**. None fences the **environment**: a forked
reviewer with a spotless context still holds the repository checkout — and with it the prior
round's verdicts and every committed answer key. When the reviewer's output will be compared
against something, fence the filesystem too:
[`review-fencing.md`](../guidance/review-fencing.md).

---

## Rung 4 — Analytic verification (does the *claim* survive?)

Rungs 1–3 check **artifacts**. This rung checks the **claim** — whether the result survives
choices a competent, honest analyst could have made differently.

Why it is separate: in a controlled study, **150 autonomous agents** given the same data and
question produced effect-size interquartile ranges up to **~10.7 %/yr**, and the divergence
concentrated in **discrete measure-choice forks** (dollar vs share volume; trade-level vs
Amihud), not estimation noise. Two results matter here:

- **AI peer review left that spread essentially unchanged.** Review catches errors; it does
  not reduce analytical-choice variance. Do not claim otherwise.
- Exposure to exemplar papers collapsed the spread by 80–99 % — **convergence by imitation,
  not by correctness.** Herding is not agreement.

So: enumerate the forks and report the distribution.

- **Specification curve / multiverse** over measure definition, sample filter, control set,
  clustering level, weighting, winsorization.
- **Named computable sensitivity statistics** — turn "challenge the assumption" into a number:
  the named sensitivity statistics canonical in your design's literature, with their canonical
  implementations — chosen and vetted by you.
- **Placebo and falsification** — negative outcomes, negative exposures, timing placebos.
- Label each statistic **executable here** vs **describe-and-cite** — honesty about what your
  environment can actually run is itself a verification step.

---

## Rung 5 — The ledger (make adaptive search inspectable)

Agentic tooling makes specification search fast and cheap, which widens hidden researcher
degrees of freedom. The answer is not to forbid search — it is to **record** it.

Four artifacts:

1. **An instruction contract** — objective, admissible modifications, and a **search budget**.
2. **An immutable evaluator** — the scoring harness, never edited during the search.
3. **A single editable surface** — the one file the agent may change.
4. **An append-only ledger** — every attempt: identifier, **label** (below), score, outcome
   (`keep / discard / crash`), and a one-line description of the strategy.

Then: **pre-commit the interpretation before running the test** — write what result would
SUPPORT versus WEAKEN the claim *first*. The ledger is the arbiter. This closes the
garden-of-forking-paths gap that hypothesis-only preregistration leaves open.

**Label each run when it is queued, never when it lands.** Three labels, and the label is part
of the append-only row, so it cannot be revised in the direction of the result:

- **pre-specified** — named in the instruction contract before the search began.
- **confirmatory** — committed before this particular run, as a test of a claim the search has
  already produced.
- **exploratory** — everything else: a look, a variant, a hunch.

**Only pre-specified and confirmatory runs can support a headline claim.** An exploratory run
produces a **hypothesis for the next pre-specification** — it is a reason to write a contract,
not evidence for the current one. Relabelling after the fact is precisely the forking path this
rung exists to close ([`$preregister`](../../.agents/skills/preregister/SKILL.md) is where the
pre-specified set gets written down).

**Record every attempt, including nulls and failures.** A ledger showing only supporting
tests is a fishing expedition with good PR.

**Reserve a holdout and evaluate it only after the search.** In-sample improvement does not
generalize: published runs of this protocol show relative RMSE going 0.510 → 0.811 and
0.808 → **1.089** out of sample.

Two elements worth carrying over from practice:

- **A fixed budget** makes runs comparable by construction.
- **A simplicity criterion.** A gain that adds twenty lines of hacky code is probably not
  worth it; an *equal* result from deleting code is a win. A robustness result that survives
  with **fewer** controls is a stronger result — the ledger should say so.

---

## The withdraw disposition — when the number misses its bound

Rung 5 pre-commits the interpretation and records the search. This is the other half of that
sentence: **what you owe everyone when the recorded number misses the bound you wrote down
first.**

When a capability, a default, or an automatic behaviour fails the numeric bound it
preregistered, the disposition is **WITHDRAW** — demote it to **explicit opt-in**. **Never
widen the bound.** A bound moved after seeing the number is not a bound; it is a description of
the result, and every claim that later cites it is circular. Demote rather than delete: opt-in
keeps the thing usable by someone who has read the number and accepted it, while deletion
destroys the trail and re-opens the question from scratch next release.

**A single noisy estimate does not fire a disposition.** Three conditions gate the trigger, and
all three belong in the preregistration, written before the number lands:

1. **The bound carries its uncertainty.** A bound is a number *and* the Monte Carlo or sampling
   error of the measurement that will be compared against it. *"Coverage ≥ 0.93"* is not a bound
   you can miss; *"coverage ≥ 0.93, at `R` chosen for MCSE ≈ 0.005, missed when the estimate
   falls below the bound by more than 2 MCSE"* is. Without the second half, every borderline draw
   is a disposition and the rule fires on noise
   ([`../guidance/simulation-conventions.md`](../guidance/simulation-conventions.md) §4).
2. **A re-measurement precedes the disposition.** Re-run the campaign on fresh seeds, same budget
   and same bound, and demote only if it misses again. Where a re-measurement is genuinely
   impossible — a one-shot measurement, an external service that changed underneath you, a
   campaign nobody will fund twice — **state that reason in the verdict artifact** and record
   that the disposition rests on one draw. Obligation 2 below is not in tension with this: the
   confirming re-run is pre-committed and happens *before* the withdrawal; what that obligation
   forbids is re-rolling a failed campaign *afterwards* until it passes.
3. **The withdrawal names its own scope.** Exactly one of: the **default** (the capability stays,
   reachable by explicit opt-in), the **guarantee** (the numeric claim is retracted; the
   capability ships without it), or the **method** (the procedure itself is withdrawn from
   recommendation). A bare *"WITHDRAW"* leaves every reader to infer which, and they infer the
   cheapest one.

Three obligations, and the withdrawal is not finished until all three are discharged:

1. **Publish it where users read.** The failing number, the bound it missed, and the
   disposition, together, in the release notes (`NEWS` / `CHANGELOG`) — *and* recorded in the
   verdict artifact. The two are not substitutes: the artifact serves the replicator, the
   release notes serve the person deciding whether to switch it back on.
2. **Preserve the failing campaign as negative calibration evidence.** Never deleted, and
   **never re-run until the underlying thing changes.** A re-run against unchanged inputs is a
   second draw, and the second draw is the one that gets published.
3. **Enumerate the impact.** Every adjacent surface listed and dispositioned — affected, or
   explicitly *not* affected and why. A withdrawal naming only the surface that failed leaves
   readers to guess at the rest, and they guess low.

**The bound is the promise; the default is the endorsement.** Shipping something on by default
asserts its bound holds for a user who never looked. Once the measurement says otherwise, the
honest options are to fix the thing or to stop asserting it — *widen the bound to match what we
measured* is neither, and it is the single most tempting move on this page.

---

## Rung 6 — The external oracle (advisory, last)

See [`external-oracle-process.md`](external-oracle-process.md). It is last for a reason:
run exhaustive in-house coverage first so the oracle is **confirmation, not discovery**.

---

## How we loop

```
implement → verify (rung 1–2) → review (rung 3) → adjudicate → fix → re-verify
```

**Adjudicate, never ingest.** Every finding from anyone you did not write yourself — an AI
reviewer, a referee, a linter, a second model — is a **CANDIDATE** until checked against the
source. Verdicts: **CONFIRMED / REFUTED / DOWNGRADED**. Check the proposed *fix* too: a
reviewer can be right that something reads badly and wrong about why, and its patch can
introduce a real defect.

**Batch, do not drip.** Apply all confirmed fixes in one pass, re-verify, then run **at most
one** confirmation round. One-finding-per-round converges linearly and burns rounds.

**Stopping rule.** Stop when a round adds **no new CONFIRMED** defect — only held items and
exposition taste. Guards: a fallback round cap; a *two-strikes* rule (the same finding
surviving two rounds escalates to the human rather than being patched a third time); and a
spend ceiling.

**Carry a HELD list** of standing decisions so settled questions are not re-litigated every
round.

**Expect false positives by construction.** A reviewer prompted to find gaps will report some
even when the work is sound. Chasing every finding produces over-engineering. Tell reviewers
to flag only what affects correctness or the stated requirements — and treat "no new
confirmed defect" as a valid, useful answer.

---

## What is *not* automatic

No daemon. No post-plan-approval trigger. Every loop is started by a human or by a skill a
human invoked. An unattended multi-agent fix loop pointed at a submission, shared data, or a
co-author's draft is the failure mode this template refuses. **Documented non-goal, not a
missing feature.**

---

## Cross-references

- [`external-oracle-process.md`](external-oracle-process.md) · [`provenance-and-ground-truth.md`](provenance-and-ground-truth.md)
- [`orchestration-schemas.md`](orchestration-schemas.md) — FINDING / SCORECARD / RUN_CONFIG
- [`.codex/guidance/orchestrator-protocol.md`](../guidance/orchestrator-protocol.md) · [`.codex/guidance/verification-protocol.md`](../guidance/verification-protocol.md)
