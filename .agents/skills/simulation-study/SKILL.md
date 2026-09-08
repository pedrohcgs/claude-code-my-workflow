---
name: simulation-study
description: "Scaffold and run a reproducible Monte Carlo simulation study in R — a declared assumption regime, a parameterized DGP, an estimator grid, a seeded replication loop, and a summary of bias, RMSE, empirical SE, coverage, size/power with Monte Carlo standard errors. Use when the user says \"run a Monte Carlo simulation\", \"simulation study\", \"check the bias/coverage of an estimator\", \"compare estimators in simulation\", \"size and power simulation\", \"Monte Carlo experiment\", or wants to demonstrate an estimator's finite-sample properties. Produces a numbered R script in `scripts/R/` and saves per-replication raw results + a summary table to `scripts/R/_outputs/`."
---



# `$simulation-study` — Monte Carlo Simulation Study

Design and run a Monte Carlo experiment that characterizes an estimator's finite-sample behavior, then review it for the bugs that quietly invalidate simulation evidence.

**Input:** `the arguments supplied with the invocation` — a description of the estimator(s) and DGP to study (e.g., "compare 2SLS vs LIML under weak instruments with heteroskedasticity"), or a pointer to an existing script/paper whose simulation you want to reproduce or extend.

---

## Constraints

- **Follow [`.codex/guidance/simulation-conventions.md`](../../../.codex/guidance/simulation-conventions.md)** — the simulation contract (DGP, truth, estimand, MCSE, assumption regime) is non-negotiable.
- **Declare the assumption regime in the script header** and respect the firewall — an out-of-assumption run never supports a within-assumption claim ([`simulation-conventions.md`](../../../.codex/guidance/simulation-conventions.md) §2).
- **Follow [`.codex/guidance/r-code-conventions.md`](../../../.codex/guidance/r-code-conventions.md)** for general R standards (header, `library()` at top, relative paths, numerical discipline).
- **Save the script** to `scripts/R/` with a numbered, descriptive name (e.g., `scripts/R/sim_2sls_vs_liml.R`).
- **Save outputs** (per-rep raw tibble, summary table, figures) to `scripts/R/_outputs/`.
- **`saveRDS()` the per-replication raw results**, not just the summary — re-aggregation and the review pass need them.
- **Run the `sim-reviewer` agent** on the generated script before presenting results, then address Critical/High findings.

---

## Workflow Phases

### Phase 0: Pre-Flight Report

**Before writing any code, produce a Pre-Flight Report** showing you have pinned down the experiment. This prevents the most common failure mode — a beautiful results table built on a mismatched estimand or a coverage-against-the-estimate bug.

```markdown
## Pre-Flight Report — Simulation Design

**Research question:** [what finite-sample property is being demonstrated]
**Target estimand:** [ATT / ATE / coefficient θ — and how its TRUE value is computed from the DGP params]
**Maintained assumptions:** [the FULL list the estimator(s) under study require — A1 … An, every one]
**Regime:** [IN-ASSUMPTION — all hold | OUT-OF-ASSUMPTION — relaxes A[k] only, severity grid {…}, targeting pseudo-estimand …]
**Verification:** [per assumption, the checkable property of the DGP that establishes it — by construction or by an assertion]
**DGP:** [structure + the parameters that define it; what is held fixed vs. varied]
**Estimator grid:** [list each estimator + which estimand it targets + how it returns est/se/CI]
**Design grid:** [sample sizes, parameter values, scenarios to sweep]
**Replications R:** [value] → implied MCSE on coverage ≈ sqrt(0.95·0.05/R) = [value]
**Metrics:** bias, empirical SE, RMSE, coverage, size/power — each with MCSE
**Conventions read:** simulation-conventions.md, r-code-conventions.md
```

If the estimand or its true value is ambiguous, **stop and ask** before writing code.

If an assumption cannot be verified — you cannot name the property of the DGP that establishes it — the run is **not** `IN-ASSUMPTION`, and per the firewall no within-assumption claim may rest on it. Say so in the Pre-Flight Report rather than letting the header assert what was never checked.

### Phase 1: The DGP

Write **one** parameterized function that returns a dataset. Compute and return (or store) the **true** target value from the parameters.

```r
generate_data <- function(n, params) {
  # ... generate covariates, treatment, outcome from params ...
  list(data = df, truth = compute_truth(params))   # truth from params, never from an estimate
}
```

The header's **Verified** lines are earned here: every assumption the regime block claims holds *by a check* gets that check written into the script (a large-draw assertion, a condition number, a `stopifnot()` on the parameter bounds), run once at setup. An assumption whose verification exists only in the comment is asserted, not verified.

### Phase 2: Estimator Grid

Each estimator is a function `data -> list(est, se, ci_lo, ci_hi, converged)`. State the estimand each one targets; an estimator scored against a mismatched truth is a bug, not a finding.

### Phase 3: Replication Engine

- `set.seed(YYYYMMDD)` **once**. For parallel reps use `RNGkind("L'Ecuyer-CMRG")` and `furrr::furrr_options(seed = TRUE)`.
- One run = generate data → run every estimator → record a row per estimator with `est, se, ci_lo, ci_hi, converged`.
- Pre-allocate / bind results into a tibble of `R × (#estimators)` rows. Track non-convergence; never silently drop.

### Phase 4: Metrics & Summary

Per estimator × scenario, against **truth**:

- **Bias** = `mean(est) - truth` (+ MCSE = `sd(est)/sqrt(R)`)
- **Empirical SE** = `sd(est)`; **RMSE** = `sqrt(mean((est - truth)^2))`
- **Coverage** = `mean(ci_lo <= truth & truth <= ci_hi)` (+ MCSE = `sqrt(p(1-p)/R)`)
- **Size / power** = rejection rate under the null / alternative DGP
- **Failures** = count of non-converged reps

Build a tidy summary table; report MCSE next to every headline metric.

### Phase 5: Figures

Use `ggplot2` with the project theme: bias / coverage vs. sample size (or scenario), with reference lines (0 bias, nominal coverage). Transparent background, explicit dimensions (per `r-code-conventions.md` §4).

### Phase 6: Save & Review

1. `saveRDS()` the **raw per-rep tibble** and the **summary table** to `scripts/R/_outputs/`; also write the summary as `.csv`/`.tex`.
2. Run the review:

   ```
   Delegate to the sim-reviewer agent:
   "Review the simulation script at scripts/R/[name].R"
   ```

3. Address Critical/High findings (coverage-vs-truth, estimand mismatch, missing MCSE, dropped reps, an unstated or unverified regime) before presenting.
4. **Apply the firewall to the presentation itself.** Every claim you are about to make must cite a run whose regime can bear it — consistency, valid analytic standard errors, nominal coverage, and shipping a default require an `IN-ASSUMPTION` run and nothing else ([`simulation-conventions.md`](../../../.codex/guidance/simulation-conventions.md) §2). Carry the regime in every caption — and per row wherever a severity grid mixes the two.

---

## Script Structure

```r
# ============================================================
# [Title] — Monte Carlo simulation
# Author: [project context]
# Purpose: [property being demonstrated]
# Estimand: [target + how truth is computed]
# Maintained assumptions: [A1 ... An — the FULL list the estimator requires]
# Regime: [IN-ASSUMPTION | OUT-OF-ASSUMPTION: relaxes A[k] only, severity ...,
#          targeting pseudo-estimand ...]
# Verified: [per assumption, the property that was actually checked, not asserted]
# Outputs: scripts/R/_outputs/[name]_raw.rds, [name]_summary.{rds,csv}
# ============================================================

# 0. Setup ----
library(tidyverse)
library(furrr)            # parallel reps (optional)
plan(multisession)        # enable parallel workers; omit this line to run sequentially
RNGkind("L'Ecuyer-CMRG")
set.seed(20260531)        # once, YYYYMMDD (simulation-conventions.md §3)
R   <- 2000L              # MCSE on coverage near .95 ≈ 0.005
dir.create("scripts/R/_outputs", recursive = TRUE, showWarnings = FALSE)

# 1. DGP ----
generate_data <- function(n, params) { ... }     # returns list(data, truth)

# 2. Estimators ----
estimators <- list(tsls = est_tsls, liml = est_liml)    # each -> est, se, ci, converged

# 3. Run one replication ----
run_one_rep <- function(rep_id, n, params) { ... }      # -> tibble rows (one per estimator)

# 4. Replicate ----
raw <- future_map_dfr(seq_len(R), run_one_rep, n = n, params = params,
                      .options = furrr_options(seed = TRUE))

# 5. Summarize (vs truth, with MCSE) ----
# Group by EVERY design-grid dimension you sweep (estimator, n, scenario, ...) so
# each group has a single true value. Use per-row `truth` — never `truth[1]` — so a
# truth that varies across the grid can't be silently mis-scored. Score only the
# converged reps; report failures separately.
summary_tbl <- raw |>
  filter(converged) |>
  group_by(estimator) |>                       # add n, scenario, ... as needed
  summarise(
    R_eff    = n(),
    bias     = mean(est - truth),
    emp_se   = sd(est),
    rmse     = sqrt(mean((est - truth)^2)),
    coverage = mean(ci_lo <= truth & truth <= ci_hi),
    .groups  = "drop"
  ) |>
  mutate(
    bias_mcse = emp_se / sqrt(R_eff),
    cov_mcse  = sqrt(coverage * (1 - coverage) / R_eff)
  )

failures <- raw |> group_by(estimator) |> summarise(n_fail = sum(!converged), .groups = "drop")

# Size/power: add `power = mean(reject)` (+ `sp_mcse = sqrt(power*(1-power)/R_eff)`)
# to the summary above — each estimator must emit a per-rep `reject = p_value < alpha`
# column. Size = rejection rate under the null DGP; power = under the alternative.

# 6. Export ----
saveRDS(raw, "scripts/R/_outputs/[name]_raw.rds")
saveRDS(summary_tbl, "scripts/R/_outputs/[name]_summary.rds")
write_csv(summary_tbl, "scripts/R/_outputs/[name]_summary.csv")
```

---

## Important

- **State the regime, then respect the firewall.** A DGP that violates a maintained assumption produces a table on which every other check here passes — and a within-assumption claim built on it is unsupported however clean the numbers look.
- **The truth comes from the DGP, never from an estimate.** Coverage is the CI containing the *true* parameter.
- **No result without an MCSE.** If two estimators differ by less than ~2× MCSE, say so.
- **Save raw, not just summary.** A number that exists only in the console cannot be audited or put on a slide.
- **Count your failures.** Silently dropped non-converged reps bias every metric.

## Long-running simulations: use the Monitor tool

Large grids (many scenarios × large `R`) can run for many minutes. Background-launch via Bash with `run_in_background: true`, capture the `bash_id`, and use the running-process interface to stream R stdout (e.g., a `progressr` milestone or process exit) instead of polling with `sleep`. See [`data-analysis/SKILL.md`](../data-analysis/SKILL.md) and the guide's Cost-Conscious Parallelism section.

