---
paths:
  - "**/*simulation*.R"
  - "**/*_sim.R"
  - "**/*_mc.R"
  - "scripts/**/simulations/**"
  - "explorations/**/*.R"
---

# Monte Carlo Simulation Standards

**Standard:** A simulation study is an experiment. It must be reproducible, its estimand must be unambiguous, and every headline number must carry its own Monte Carlo uncertainty.

> **Scope:** This rule covers *simulation-specific* discipline. General R standards (header, `library()` at top, relative paths, figure theme, no float `==`, CDF clamping, pre-allocation) live in [`r-code-conventions.md`](r-code-conventions.md) and the [`r-reviewer`](../agents/r-reviewer.toml) Cat 9 (error handling) + Cat 11 (numerical discipline) checklists. Do not restate those here — follow both.

---

## 1. The simulation contract

Every Monte Carlo script must make five things explicit and inspectable:

1. **The DGP** — a single parameterized function `generate_data(params)` that returns a dataset. No data generation scattered through the run loop.
2. **The truth** — the true value of the target parameter, computed from `params` (not from any estimate), stored alongside the results.
3. **The estimand** — which quantity each estimator targets (e.g., ATT, ATE, a specific event-study coefficient). An estimator that targets a *different* estimand than `the truth` is a bug, not a finding.
4. **The replication budget** — `R` (number of replications) and the resulting Monte Carlo standard error on the headline metrics.
5. **The assumption regime** — which conditions the estimator maintains, whether this run's DGP satisfies each of them, and how that was verified. Required of any run whose output supports a claim, promotes a default, or leaves this machine; not of a disposable exploratory run (§2).

## 2. The assumption regime

Every estimator maintains assumptions. A DGP either satisfies them or it does not — and a
simulation that never says which is reporting one of two completely different experiments
without telling you which. **Nothing else in this file catches that.** A run whose DGP violates
an assumption the estimator maintains can pass every other check here — MCSE reported, coverage
scored against the truth, estimand aligned — and still be evidence about the violation rather
than about the estimator.

### Which runs owe a regime block

**The ones whose output supports a claim, promotes a default, or leaves this machine.** A number
headed for a paper, a slide, a README, or a referee; the evidence behind shipping something on by
default; anything handed to a coauthor or packaged for replication. Those owe the full block.

**A disposable exploratory run does not** — checking whether the estimator runs at all, sweeping
a grid to find where to look, bisecting a DGP that misbehaves. That exemption is stated out loud
on purpose. An external referee's objection is exact: imposed identically on throwaway runs, this
becomes ceremony, and ceremony is complied with perfunctorily and then bypassed wholesale —
including on the runs that needed it. A rule nobody can afford everywhere gets followed nowhere.

**The line is the output, not the intent.** An exploratory run whose number is about to be quoted
has crossed it, and owes the block **before** the number is quoted — retrofitting a regime onto a
run whose DGP you no longer remember produces a description of what you think you did, not a
verification of what you did.

### The regime block

Every in-scope script declares, in its header, four things:

| Field | What it states |
|---|---|
| **Estimand** | the target quantity and how its true value is computed from `params` (§1) |
| **Maintained assumptions** | the **full** list the estimator or procedure under study requires — every one, not the interesting ones |
| **Regime** | `IN-ASSUMPTION`, or the **single** assumption this run relaxes and how severely |
| **Verified** | per assumption, the checkable property of the DGP that establishes it |

**A map, not a list.** What licenses the run is the *correspondence* between the estimator's
conditions and the DGP, never the two lists placed side by side. So write it condition by
condition: each condition the theorem or the documented procedure requires on its own line, and
opposite it the property of `generate_data()` that establishes it — and where the run departs
from a condition, that departure is named in the `Regime` line as a **deliberate violation**,
not quietly missing from `Verified`. A condition with nothing opposite it has recorded a hope; a
DGP feature with no condition opposite it has recorded a changelog.

**"The DGP is correctly specified" is an assertion, not a verification.** An assumption is
verified when you can name the property of `generate_data()` that makes it true. Two forms
count: *by construction* (the DGP draws errors from a distribution with finite variance, so the
moment condition holds) and *by a check* (a large-draw assertion, a condition number, a
structural read of the generator). "It looks right" is neither.

**And one assumption per line.** Two conditions merged under one label — "finite *and*
nonsingular second moments" — produce a block that verifies one of them and looks complete;
split them, and each gets its own check.

**A check counts only if it can go red.** State the threshold or the comparison, not the
property: `stopifnot(rcond(J) > 1e-8)` fails on a singular Jacobian, `is.finite(kappa(J))` does
not — measured, `kappa()` of an exactly singular 2×2 returns `1.478e+17`, which is finite, so
the finiteness form passes on precisely the failure it was written to catch. A verification whose
predicate is true for the defect it targets is worse than no verification, because the header now
says the assumption was checked ([`research-agent-laws.md`](../references/research-agent-laws.md)
law 5). If you cannot name the number the check compares against, you have written an assertion.

```r
# --- Assumption regime -------------------------------------------------
# Estimand   theta0, the unique solution of E[psi(W; theta)] = 0 under the
#            DGP; computed in closed form from params (compute_truth()).
# Maintained assumptions of the estimator under study:
#   A1  i.i.d. sampling of W_i
#   A2  correct specification: the DGP's conditional mean IS the one psi assumes
#   A3  finite, positive-definite variance matrix Omega = E[psi psi'] at theta0
#   A4  nonsingular Jacobian G = E[d psi / d theta'] evaluated at theta0
#   A5  theta0 interior to the parameter space; psi differentiable there
# Regime     IN-ASSUMPTION -- A1-A5 all hold.
# Verified   A1  rows are drawn i.i.d. within a replication -- no group-level
#                or latent draw in generate_data() enters more than one row
#            A2  by construction -- the outcome equation and psi share one
#                functional form and one coefficient vector; asserted on a
#                1e6-row draw that mean(psi(W, truth)) is within 4 MCSE of 0
#            A3  Omega estimated on a 1e6-row draw (Gaussian errors,
#                sigma = params$sigma, so the fourth moments exist);
#                stopifnot(all(is.finite(Omega)),
#                          min(eigen(Omega, symmetric = TRUE,
#                                    only.values = TRUE)$values) > 1e-8)
#            A4  G formed analytically at theta0;
#                stopifnot(rcond(G) > 1e-8)   -- reciprocal condition against a
#                stated floor, NOT is.finite(kappa(G)): kappa() of an exactly
#                singular matrix is ~1.5e17, finite, so that form cannot fail
#            A5  params$theta lies strictly inside the search bounds --
#                stopifnot() at setup
# -----------------------------------------------------------------------
```

An out-of-assumption run changes exactly two lines of that block:

```r
# Regime     OUT-OF-ASSUMPTION -- relaxes A2 only, at severity
#            delta in {0, 0.1, 0.25, 0.5}; A1, A3-A5 hold exactly as above.
# Target     the pseudo-estimand theta*(delta) -- the solution of
#            E[psi(W; theta)] = 0 under the perturbed DGP, obtained by
#            root-finding on a 1e7-row draw (no closed form).
```

### The firewall

**Hard rule: only an in-assumption run may support a within-assumption claim.** A
within-assumption claim is any claim about how the estimator or procedure behaves where it
promises to behave — consistency, validity of the analytic standard errors, nominal coverage,
or the decision to ship a default. Each may cite **only** a run whose regime line reads
`IN-ASSUMPTION`.

An out-of-assumption run may never support a within-assumption claim, in either direction:

- It cannot confirm one. Coverage near nominal under a violated assumption is a fact about that
  violation — usually about how mild it was — not about the estimator's inference.
- It cannot refute one. Bias under a violated assumption is the DGP doing exactly what it was
  built to do.

So every table carries its regime — in the caption, and **per row** wherever a severity grid
mixes them (the null-dose arm of a dose–response *is* an in-assumption row and must be labelled
as one). Carry it into the saved summary object as well, so a reader — or a reviewer six months
later — can tell which rows license which claims without rerunning anything. This is
[`credible-claims`](../../.agents/skills/credible-claims/SKILL.md) discipline applied to the *regime* the
evidence came from: the claim may never be stronger than the run behind it.

### Designing an out-of-assumption study

1. **Relax exactly one assumption.** Two at once makes a failure unattributable — you learn
   that something broke, never which thing, and no amount of later analysis repairs it.
2. **Hold everything else fixed.** Same sampling scheme, same sample sizes, same estimator
   grid, same seeds. The perturbation is the only difference between the two runs.
3. **Target the pseudo-estimand, and say which target each metric uses.** Under a violated
   assumption the estimator no longer targets `truth`; it converges to whatever solves its own
   criterion under the perturbed DGP. Compute that quantity from the perturbed parameters
   (numerically if there is no closed form) and score against it — reporting both targets when
   they differ, because they answer different questions: deviation from the original estimand
   answers *how wrong is someone who assumed this held*, coverage of the pseudo-estimand
   answers *does the estimator's own inference still work for what it now targets*. A table
   that does not say which target it used cannot be read.
4. **Prefer a dose–response to one extreme dose.** Sweep a severity grid; a single severe
   violation only shows that an estimator can be broken, which was never in doubt. Include the
   null dose, which reproduces the in-assumption run — **a positive control on the perturbation
   machinery.** If the null-dose arm does not match the in-assumption numbers, the perturbation
   has leaked into something else and every other dose is uninterpretable.

## 3. Reproducibility & seeding

- `set.seed(YYYYMMDD)` **once**, at the top — never inside the replication loop or the DGP.
- **Parallel runs are not reproducible with a single seed.** When replications run in parallel (`future`/`furrr`, `parallel`, `foreach`), use independent streams:

  ```r
  RNGkind("L'Ecuyer-CMRG")
  set.seed(20260531)
  # furrr: carry streams explicitly
  results <- furrr::future_map(seq_len(R), run_one_rep,
                               .options = furrr::furrr_options(seed = TRUE))
  ```

- Record the seed and `R` in the saved output object so a result can be traced to the exact run that produced it.

## 4. Replication count & Monte Carlo standard error (MCSE)

**A simulation result without an MCSE is an opinion.** Always report the Monte Carlo uncertainty of the headline metrics, and choose `R` so it is small relative to the effects you claim.

| Metric | Monte Carlo SE | Rule of thumb |
|---|---|---|
| Bias / mean estimate | `sd(estimates) / sqrt(R)` | Report next to every bias number |
| Coverage `p` | `sqrt(p * (1 - p) / R)` | For MCSE ≈ 0.005 (±0.5 pp) on coverage near 0.95, need `R ≈ 1900`; for ±1 pp, `R ≈ 475` |
| Rejection rate / power | `sqrt(p * (1 - p) / R)` | Same as coverage |
| RMSE | bootstrap or delta-method over reps | At minimum report `R` so readers can gauge it |

If two estimators differ by less than a couple of MCSEs, say so — do not present the smaller number as "better."

## 5. Metrics: compute them correctly

Define against **the truth**, never against another estimate:

- **Bias** = `mean(est) - truth`.
- **Empirical SE** = `sd(est)` across reps (the actual sampling variability).
- **RMSE** = `sqrt(mean((est - truth)^2))`.
- **Coverage** = share of reps whose CI **contains `truth`** — i.e. `mean(ci_lo <= truth & truth <= ci_hi)`. The single most common simulation bug is checking the CI against the point estimate or a mislabeled "true" value.
- **Size / power** = rejection rate of the test under the null DGP (size) and under the alternative DGP (power). Size must be evaluated under a DGP where the null is literally true.

## 6. Storage: save raw, not just summary

- `saveRDS()` the **per-replication raw results** (a tibble: one row per rep × estimator, with `est`, `se`, `ci_lo`, `ci_hi`, `converged`), not only the aggregated table. Re-aggregation, new metrics, and `sim-reviewer` all need the raw object.
- Save the summary table as `.rds` **and** a human-readable `.csv`/`.tex`. Outputs go to `scripts/R/_outputs/` (repo canonical path).
- Never let a headline number exist only in console output — it cannot be audited or re-rendered onto slides.

## 7. Performance & robustness

- **Pre-allocate**; never grow result vectors with `c()`/`append()` inside the loop (see `r-code-conventions.md` §8).
- Count and report **failed/non-converged replications** explicitly (`converged` flag) — silently dropping them biases every metric.
- No per-replication `print()`/`cat()`. Use a single progress bar (`progressr`) or nothing.
- Guard `NA`/`NaN`/`Inf` in estimates before computing summaries; decide and document whether they count as failures or are excluded.

## 8. Common pitfalls

| Pitfall | Impact | Prevention |
|---|---|---|
| DGP silently violates a maintained assumption | Every other check passes; the result is about the violation, not the estimator | Regime block; verify each assumption rather than asserting it |
| Within-assumption claim cited from an out-of-assumption run | A promise about the estimator resting on evidence that cannot bear it | The firewall (§2) |
| Two assumptions relaxed at once | Failure is unattributable — you cannot say which one broke it | One relaxation per run, over a severity grid |
| `set.seed()` inside the loop | Identical / correlated reps; understated variance | Seed once at top; L'Ecuyer streams for parallel |
| Coverage vs. the estimate, not the truth | Coverage ≈ nominal by construction — meaningless | `mean(ci_lo <= truth & truth <= ci_hi)` |
| No MCSE reported | "Estimator A beats B" within noise | Report MCSE on bias/coverage/power |
| Estimator targets a different estimand than `truth` | Apparent "bias" that is really a mismatch | State each estimator's estimand; align with truth |
| Raw per-rep results discarded | Can't re-aggregate or audit | `saveRDS()` the raw tibble |
| Dropped failed reps unrecorded | Survivorship bias in all metrics | Track + report `converged` count |

## 9. Checklist

```
[ ] DGP is one parameterized generate_data() function
[ ] truth computed from params, stored with results
[ ] each estimator's estimand stated and aligned with truth
[ ] does this run's output support a claim, promote a default, or leave the machine?
    if no, the regime items below are optional (§2); everything else still applies
[ ] regime block in the header: estimand, ALL maintained conditions, regime, verification
[ ] one condition per assumption line -- no two merged under one label
[ ] each condition mapped to the DGP property opposite it; deliberate violations named
    in the regime line, not omitted
[ ] each maintained assumption verified by a named property, not asserted, and
    every check states a threshold it can fail against (rcond(J) > 1e-8, not
    is.finite(kappa(J)))
[ ] within-assumption claims (consistency, analytic SEs, coverage, a shipped default)
    cite an IN-ASSUMPTION run and nothing else
[ ] out-of-assumption run relaxes ONE assumption, over a severity grid including the
    null dose, scored against a named target
[ ] set.seed() once at top (YYYYMMDD); L'Ecuyer streams if parallel
[ ] R chosen for adequate MCSE; MCSE reported on bias/coverage/power
[ ] coverage = CI contains truth (not the estimate)
[ ] failed/non-converged reps counted and reported
[ ] per-rep raw results saved via saveRDS() to scripts/R/_outputs/
[ ] no per-replication console printing
```

## Cross-references

- [`r-code-conventions.md`](r-code-conventions.md) — general R standards (seeding format, pre-allocation, numerical discipline).
- [`../agents/sim-reviewer.toml`](../agents/sim-reviewer.toml) — the agent that enforces this rule.
- [`../agents/r-reviewer.toml`](../agents/r-reviewer.toml) — Cat 9 (error handling) + Cat 11 (numerical discipline).
- [`replication-protocol.md`](replication-protocol.md) — replicate-then-extend tolerance contract (applies when a simulation reproduces a published table).
- [`../../.agents/skills/credible-claims/SKILL.md`](../../.agents/skills/credible-claims/SKILL.md) — never state a claim more strongly than the run behind it; the firewall (§2) is that discipline applied to the assumption regime.

## Parallelism must be provably run-shape-independent

**Seed by task, not by worker.** Pre-generate **one RNG stream per replication** (L'Ecuyer
`"L'Ecuyer-CMRG"`), so replication *k* draws the same numbers no matter which core runs it or
how many cores exist.

Worker-based seeding — `mc.set.seed`, `clusterSetRNGStream`, or "set the seed inside the
worker" — **silently binds your results to the execution shape**. The same script on a laptop
and a cluster then produces different numbers, and nothing warns you. That is a
reproducibility failure a replicator will find and you will not.

```r
# Correct: one stream per replication, independent of core count
RNGkind("L'Ecuyer-CMRG")
set.seed(20260821)
streams <- vector("list", n_reps)
s <- .Random.seed
for (k in seq_len(n_reps)) { streams[[k]] <- s; s <- parallel::nextRNGStream(s) }

run_one <- function(k) { .Random.seed <<- streams[[k]]; simulate_once() }
results <- parallel::mclapply(seq_len(n_reps), run_one, mc.cores = n_cores)
```

**Prove it before trusting a campaign.** Run the first N replications at two core counts and
assert bit-identity:

```r
a <- run_campaign(n_reps = 20, n_cores = 2)
b <- run_campaign(n_reps = 20, n_cores = 4)
stopifnot(identical(a, b))   # fails loudly if results depend on run shape
```

This is a **positive control for your own harness** — the two-core/four-core check is cheap,
runs in seconds, and is the only thing that distinguishes "seeded correctly" from "seeded in a
way that happens to look fine on this machine." Record it in the qualification ledger.

For other runtimes, set a seed per replication from a pre-generated list, not once before a
`parallel` block. Python: use `numpy.random.SeedSequence(...).spawn(n_reps)` — one child per
replication, never one per worker.
