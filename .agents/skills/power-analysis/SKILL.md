---
name: power-analysis
description: "Compute statistical power, required sample size, and minimum detectable effect (MDE) for a study design, then write a registry-ready power section. Handles two-arm RCTs (with clustering / ICC and unequal allocation), multiple-arm corrections, and a simulation-based power option for non-standard designs (DiD/event-study, IV, panel). Use when user says \"power analysis\", \"power calculation\", \"MDE\", \"minimum detectable effect\", \"how big a sample do I need\", \"is my study powered\", \"power for an RCT\", or when $preregister needs a power section for an experiment. Produces a power/MDE table, power curves, and a methods paragraph to paste into a preregistration."
---



# `$power-analysis` — Power / MDE for study design

Compute the three interlocking quantities of an ex-ante design calculation — **power**, **required N**, and **minimum detectable effect (MDE)** — and emit a power section the user can paste straight into a preregistration. Analytical for standard designs; simulation-based (reusing the `$simulation-study` harness pattern) for non-standard ones.

**Core principle:** a power calculation is a *design-time commitment made before the data exist*. Fix any two of {effect size, N, power} and solve for the third; never back out a "power" number from a realised estimate (that is post-hoc power, and it is uninformative — see "What this skill does NOT do").

## When to use

- **Before launching an RCT / field / survey experiment** — to choose N (or clusters) for a target MDE at 80–90% power.
- **Invoked by [`$preregister`](../preregister/SKILL.md) for RCTs** — the AEA RCT Registry and most IRBs require a power/MDE justification; `$preregister`'s `aea-rct` style calls this skill to fill that section.
- **During R&R** — when a referee asks "was this study adequately powered to detect the effect you claim?"
- **Designing a Monte Carlo** — to set `R` and sample sizes before handing off to `$simulation-study`.

## Inputs

`the arguments supplied with the invocation` may carry flags; missing pieces are elicited in Phase 0.

- `--mode mde|n|power` — solve for MDE given N+power, N given MDE+power, or power given N+MDE. Default `mde`.
- `--design rct|cluster|multiarm|sim` — two-arm RCT, clustered RCT (ICC), multiple arms, or simulation-based. Default inferred from the elicited design.
- `--input <path>` — a spec from [`$interview-me`](../interview-me/SKILL.md) (under `quality_reports/specs/`) to pull the RQ, outcome, and design from.

## Workflow

### Phase 0 — Elicit the design

Gather the design parameters; **ask once** for anything missing rather than fabricating. Required:

- **Estimand & test:** primary outcome, one- vs two-sided test, `alpha` (default 0.05), and whether the target is a difference in means, a proportion, or a regression coefficient.
- **Two of {effect size, N, power}:** the effect as a raw difference *and* in standardized units (Cohen's d = effect / SD) — record both; `power` default 0.80.
- **Baseline mean and SD** (or baseline proportion for a binary outcome) — needed to translate raw ↔ standardized effects.
- **Allocation:** treated:control ratio (default 1:1; unequal allocation costs power — note it).
- **Clustering:** if randomization is at a group level (village, school, clinic), the **ICC** (ρ), the average cluster size (m), and number of clusters. Compute the design effect `DEFF = 1 + (m − 1)·ρ` and the effective N.
- **Multiplicity:** number of arms / primary outcomes; the correction (Bonferroni, Holm, or none) and whether power is per-comparison or familywise.

Echo a **Pre-Flight Report** (design, the two fixed quantities, the one being solved for, alpha, power, allocation, ICC/clusters, multiplicity) before computing. If the estimand or the SD source is ambiguous, stop and ask.

### Phase 1 — Analytical power (standard designs)

For two-arm RCTs, clustered RCTs, and multi-arm comparisons, compute analytically. Prefer R `pwr` / `WebPower` (or a closed-form `power.t.test` / `power.prop.test`); for clustered designs inflate variance by `DEFF`, or use `pwr` on the effective N. Python users: `statsmodels.stats.power`. Emit a short script to `scripts/R/power_<slug>.R` (or `.py`) so the calc is reproducible, not a one-off console number.

- **MDE mode:** `MDE = (z_{1−α/2} + z_{1−β}) · SE(effect)`, where `SE` is built from the SD, N, allocation, and `DEFF`. Report MDE in raw and standardized units.
- **N mode:** invert the above for total N (and #clusters when clustered) given the target MDE.
- **Power mode:** given N and a hypothesized effect, return achieved power.
- **Multi-arm:** divide `alpha` by the **number of comparisons in the family** `m` (Bonferroni `alpha/m`): `m = K−1` for all-vs-control, `m = K(K−1)/2` for all-pairwise. Report per-comparison *and* familywise power.

Sweep a grid (N or #clusters × effect size) so Phase 3 can draw a power curve and an MDE-vs-N curve.

### Phase 2 — Simulation-based power (non-standard designs)

When the design is **not** a clean two-arm comparison — DiD / staggered event-study, IV / 2SLS, panel with serial correlation, a non-normal or censored outcome, or any estimator with no closed-form SE — switch to simulation. **Reuse the `$simulation-study` harness** exactly (see [`simulation-study`](../simulation-study/SKILL.md) and [`.codex/guidance/simulation-conventions.md`](../../../.codex/guidance/simulation-conventions.md)):

1. **Seeded, parameterized DGP** that embeds the hypothesized effect (and the null DGP for size). `set.seed(YYYYMMDD)` once; L'Ecuyer streams if parallel.
2. **Estimator** = the one you will actually use on the real data (e.g. `fixest::feols` two-way FE, `did::att_gt`, `AER::ivreg`), returning `est, se, ci, p, reject`.
3. **Power = share of reps rejecting H0** at `alpha`; **size = rejection rate under the null DGP** (verify it is near nominal before trusting power). Report each with its **Monte Carlo SE** = `sqrt(p(1−p)/R)`.
4. Sweep N (or #clusters / #periods) to trace the power curve; save the raw per-rep tibble via `saveRDS()` to `scripts/R/_outputs/`.

A simulated power number without an MCSE, or without a verified size check, is not yet an answer.

### Phase 3 — Write the power section

Produce the deliverables under `quality_reports/power/`:

- **`power_<slug>.md`** — a table and a methods paragraph (below).
- **`power_curve_<slug>.png`** — power vs N (and/or MDE vs N), with reference lines at the target power and the design's planned N.
- The reproducible script under `scripts/R/` (or `.py`).

```markdown
# Power Analysis: <study title>
**Date:** YYYY-MM-DD · **Design:** <rct|cluster|multiarm|sim> · **Method:** <analytical|simulation, R/Python>

| Quantity | Value |
|---|---|
| alpha (sided) | 0.05 (two-sided) |
| Target power | 0.80 |
| Baseline mean (SD) | <m0> (<sd>) |
| Allocation (T:C) | 1:1 |
| ICC / cluster size / #clusters | <ρ> / <m> / <J>  (DEFF = <…>) |
| Total N (analysis sample) | <N> |
| **MDE (raw / standardized)** | **<Δ> / <d>** |
| Achieved power at planned N | <…>  (± MCSE <…> if simulated) |

## Methods paragraph (paste into preregistration)
> Assuming a baseline outcome mean of <m0> (SD <sd>), 1:1 allocation, and a two-sided
> test at α = 0.05, a total sample of <N> [<J> clusters of <m>, ICC = <ρ>] yields 80%
> power to detect a minimum effect of <Δ> (<d> SD). [Simulation: under the hypothesized
> DGP, <P>% of <R> replications rejected H0 (MCSE <…>); size under the null was <…>.]
```

### Phase 4 — Handoff

If invoked by `$preregister`, return the methods paragraph + MDE row for the preregistration's power section. If standalone, print the save paths and remind the user the MDE is a *design commitment* to record before data collection.

## Exit behavior

- **Computation succeeds:** exit 0; print the MDE / N / power result, the save paths, and (for simulation mode) the size-check value next to power.
- **Under-identified design (only one of {effect, N, power} supplied) or ambiguous SD source:** halt in Phase 0 with a single specific question — never guess the SD or the ICC.
- **Simulation size check fails** (empirical size far from nominal under the null DGP): report power as **UNRELIABLE** and surface the size value; the estimator/DGP must be fixed before the power number is trustworthy.

## Flags

- `--mode` `<mde|n|power>` — What to solve for: minimum detectable effect, required N, or achieved power.
- `--design` `<rct|cluster|multiarm|sim>` — Design family — two-arm RCT, clustered/ICC, multi-arm with corrections, or simulation-based for non-standard designs.
- `--input` `<spec>` — Path to an `$interview-me` spec or preregistration draft to read design parameters from.

## Cross-references

- [`.agents/skills/preregister/SKILL.md`](../preregister/SKILL.md) — invokes this skill to fill the power/MDE section of an `aea-rct` (and OSF) preregistration; this skill returns the methods paragraph.
- [`.agents/skills/simulation-study/SKILL.md`](../simulation-study/SKILL.md) — the Monte Carlo harness Phase 2 reuses (seeded DGP, estimator grid, % rejecting H0).
- [`.codex/guidance/simulation-conventions.md`](../../../.codex/guidance/simulation-conventions.md) — the simulation contract (truth from DGP, MCSE, size-under-the-null) that Phase 2 must honor.
- [`.agents/skills/data-analysis/SKILL.md`](../data-analysis/SKILL.md) — where the realised analysis (and its actual estimator/SE) lives; the power calc should use the same estimator.
- [`.codex/guidance/confidential-data.md`](../../../.codex/guidance/confidential-data.md) — when baseline mean/SD/ICC are taken from restricted-access data, disclosure-avoidance limits apply; cite published or pilot moments rather than embedding raw confidential statistics in the (externally-uploaded) preregistration.

## What this skill does NOT do

- **Post-hoc / observed power.** It refuses to compute "the power we had to detect our estimate" from a realised result — that is a deterministic function of the p-value and tells you nothing. Power is ex-ante only.
- **Pick your effect size for you.** The MDE is *your* design commitment; the skill computes consequences of an assumed effect (from theory, a pilot, or a meta-analysis), it does not invent a plausible one.
- **Submit to a registry.** Like `$preregister`, it writes a document; the user uploads it.
- **Replace `$simulation-study`.** Phase 2 borrows the harness for a single power question; a full bias/RMSE/coverage study is `$simulation-study`'s job.

