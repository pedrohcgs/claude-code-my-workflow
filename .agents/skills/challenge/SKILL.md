---
name: challenge
description: "Stress-test a finding against the choices you did not make. Enumerates the discrete forks a competent analyst could have taken (measure definition, sample filter, control set, clustering level, weighting, functional form), runs the specification grid, and reports the distribution rather than a point estimate — then attacks the identifying assumption with named, computable sensitivity statistics. Use when the user says \"is this robust\", \"challenge this result\", \"specification curve\", \"multiverse\", \"how sensitive is this\", \"what if I'd used a different measure\", \"stress-test my estimate\", or before a result becomes a headline claim. NOT a reviewer of prose or code — it challenges the CLAIM."
---



# Challenge — does the result survive the choices you didn't make?

A single specification is one draw from a distribution you never looked at.

**Why this exists, measured rather than asserted.** In a controlled study, 150 autonomous
agents were given the same data and the same questions. Effect-size interquartile ranges
reached **~10.7 %/yr**, and the spread concentrated in **discrete measure-choice forks** — not
in estimation noise. *Within* a measure family, agents agreed to ~0.25 %/yr. Two findings from
that study shape this skill:

- **AI peer review left the spread essentially unchanged.** Review catches errors; it does
  **not** reduce analytical-choice variance. A clean referee report is not robustness.
- Exposure to exemplar papers collapsed the spread by 80–99 % — **convergence by imitation, not
  by correctness.** Herding is not agreement.

So the spread has to be *measured*, not reviewed away.

## Preconditions

- A working baseline specification that runs and produces the headline estimate.
- The estimate's **estimand stated in words** — "the ATT for units treated in 2015, over
  2013–2019, on the treated population". If you cannot state it, stop: you cannot challenge a
  claim you have not defined.
- A **fork budget** (`--forks`, default 64). Grid size is the product of your choices; it grows
  faster than intuition.

## Step 1 — Enumerate the forks, before running anything

List every point where a competent, honest analyst could have chosen differently. Do this
**before** seeing any alternative result, and write it down — the list is the pre-registration
of the challenge.

| Fork | Typical alternatives |
|---|---|
| **Measure definition** | level vs rate vs share; dollar vs count; stock vs flow |
| **Sample filter** | balanced vs unbalanced; trimming rules; inclusion windows |
| **Control set** | none / baseline / baseline+trends / interacted |
| **Clustering level** | unit / treatment-assignment / two-way |
| **Weighting** | unweighted / population / inverse-propensity |
| **Functional form** | levels / logs / IHS / Poisson |
| **Winsorization** | none / 1% / 5% |

> Some forks change the **estimand**, not just the estimate — averaging over them is
> meaningless. [`references/fork-catalog.md`](references/fork-catalog.md) labels every fork;
> record estimand forks separately and say so in the report.

**Ship `--dry-run` first.** Print the grid size and an estimated runtime before executing
anything. A 6-fork grid with 3 options each is 729 fits.

## Step 2 — Run the grid

One fit per cell, same seed, same data build. Persist every cell — **including failures**. A
specification that does not converge is information about fragility, not a cell to drop.

Record per cell: the fork coordinates, the point estimate, the standard error, N, and the
convergence status.

## Step 3 — Report the distribution, not the winner

- **Specification curve**: estimates sorted, with the fork coordinates shown underneath so a
  reader can see *which* choices move the result.
- **The share of specifications** with the same sign, and the share significant at conventional
  levels. Report both; they answer different questions.
- **Which fork drives the spread.** This is the payload. "The result is robust except to the
  choice between dollar and share volume" is a far more useful sentence than a robustness
  paragraph.
- **Your baseline's percentile** in its own distribution. If the headline sits at the 97th
  percentile of specifications you yourself called defensible, say so.

> The descriptive curve is not a test — read it as a description of fragility. If you need
> inference over the whole curve, use specification-curve analysis's **joint permutation test**
> (Simonsohn, Simmons & Nelson 2020), which supplies the sharp null the picture alone lacks.

## Step 4 — Attack the identifying assumption

The grid varies what you *can* vary. The identifying assumption is what you cannot test — so
bound it instead, with a **named, computable statistic**.
See [`references/sensitivity-statistics.md`](references/sensitivity-statistics.md).

| Concern | Statistic |
|---|---|
| Unobserved confounding | **E-value**; **Cinelli–Hazlett robustness value** |
| Selection on observables → unobservables | **Oster δ** (with a stated R²max) |

> Rows for the causal-identification designs are **deliberately absent** (unvetted-methods
> veto): populate them from your field's canonical sources after vetting.

**Label every statistic `executable-here` or `describe-and-cite`.** Honesty about what your
environment can actually run is itself a verification step; a cited-but-unrun statistic is not
evidence.

## Step 5 — Placebo and falsification

Where a falsification test exists, run it: a negative-control outcome that *should* show
nothing, a negative-control exposure, a timing placebo. A passed placebo is weak positive
evidence; a **failed** placebo is strong negative evidence. Report both with equal prominence.

## Step 6 — Write the ledger entry

Append to the specification-search ledger ([`verification-ladder.md`](../../../.codex/references/verification-ladder.md)
rung 5): the fork list, the grid size, the distribution summary, which forks moved the result,
the sensitivity statistics with their values, and **every attempt including the failures**.

> **Pre-commit the interpretation.** Before running the grid, write down what result would
> SUPPORT and what would WEAKEN the claim. The ledger is the arbiter. A robustness exercise
> interpreted after the fact is not a robustness exercise.

## Anti-patterns

- **Running until something interesting appears.** That is the pathology this skill exists to
  prevent. Fixed fork list, fixed budget, stated stopping rule.
- **Reporting only the specifications that agree** — a curve showing only supporting cells is a
  fishing expedition with better graphics.
- **Treating a wide curve as failure.** Wide is a finding. Publish it and say what drives it.
- **Adding forks nobody would defend** to pad the denominator and dilute the fragile cells.

## Reference files

| File | Read when |
|---|---|
| [`references/sensitivity-statistics.md`](references/sensitivity-statistics.md) | a challenge rests on an untestable identifying assumption and needs a computable bound |
| [`references/fork-catalog.md`](references/fork-catalog.md) | enumerating forks for a design you have not challenged before |

## Cross-references

- [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) — rung 4 (analytic verification) and rung 5 (the ledger)
- [`$simulation-study`](../simulation-study/SKILL.md) — when the question is finite-sample performance, not robustness
- [`$preregister`](../preregister/SKILL.md) — reserve a holdout before the search, not after

