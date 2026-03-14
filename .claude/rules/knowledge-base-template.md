---
paths:
  - "Slides/**/*.tex"
  - "do/**/*.do"
---

# Project Knowledge Base: mh_layoff — Mental Health Effects of Layoffs

<!-- Claude reads this before creating or modifying any slide or do-file content. -->

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Relative time | `l` (lowercase L) for event-time relative to layoff | `l = -2, -1, 0, 1, 2` | `k`, `t-t*`, `tau` |
| Treatment indicator | `D_{it}` = 1 if unit `i` was laid off by time `t` | `D_{it}` | `T_{it}`, `Treat_{it}` |
| Relative-time indicator | `D_{it}^l` = 1 if `l` periods since layoff | `D_{it}^{-2}` | `post_2`, `lead2` |
| MH outcome | `Y_{it}` (generic); `GHQ_{it}` for GHQ-12 score | `Y_{it}` | `y_it`, `outcome` |
| Individual FE | `alpha_i` | `alpha_i` | `mu_i`, `eta_i` |
| Time FE | `delta_t` | `delta_t` | `gamma_t`, `lambda_t` |
| Cohort | `g` (first period of treatment / layoff year) | `g = 2010` | `c`, `G`, `treat_year` |
| ATT | `ATT(g,t)` for Callaway-Sant'Anna; `ATT` for aggregate | `ATT(g,t)` | `ATE`, `ATET` |
| Error term | `epsilon_{it}` | `epsilon_{it}` | `u_{it}`, `e_{it}` |

## Symbol Reference

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| `Y_{it}` | Mental health outcome (GHQ-12 or subindex) | Background section |
| `D_{it}` | Layoff treatment indicator | Identification section |
| `l` | Relative event time (l=0 is layoff period) | Event-study section |
| `g` | Treatment cohort (year of first layoff) | CS2021 section |
| `ATT(g,t)` | Average treatment effect on treated, cohort g at time t | CS2021 section |
| `alpha_i` | Individual fixed effect | Panel FE section |
| `delta_t` | Time (wave) fixed effect | Panel FE section |
| `beta_l` | Event-study coefficient at relative time l | Event-study section |

## Estimand Registry

| Estimand | Definition | Estimator | Stata command | Key assumption |
|----------|-----------|-----------|---------------|----------------|
| ATT (aggregate) | Avg effect of layoff on MH for laid-off workers | TWFE event study | `reghdfe` | Parallel trends, no anticipation |
| ATT(g,t) | Cohort-time specific ATT | Callaway-Sant'Anna | `csdid` | PT conditional on covariates, no anticipation |
| Dynamic ATT by l | ATT aggregated by relative period | CS aggregation | `csdid` + `csdid_plot` | Same as ATT(g,t) |
| Imputation estimator | Robust to heterogeneous treatment effects | Did-imputation | `did_imputation` | PT + no anticipation |

## Key Papers (Citation Registry)

| Short cite | Full reference | Key result / use |
|-----------|---------------|-----------------|
| CS2021 | Callaway & Sant'Anna (2021, JoE) | ATT(g,t) estimator; staggered DiD |
| Roth2023 | Roth et al. (2023, JoE) | Survey of DiD advances; pre-trends testing |
| JLS1993 | Jacobson, LaLonde & Sullivan (1993, AER) | Original earnings losses from displacement |
| SVW2009 | Sullivan & von Wachter (2009, QJE) | Mortality effects of job loss |
| HILDA | Household, Income and Labour Dynamics in Australia | Primary data source |

## HILDA Variable Naming Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `[wave_letter][var_stub]` | Wave-prefixed variables in wide format | `aghmhf` (GHQ-12, wave a) |
| `gh` prefix | GHQ mental health variables | `aghsf`, `bghsf` |
| `jb` prefix | Job/employment variables | `jbstss`, `jbmploj` |
| `hh` prefix | Household-level variables | `hhpers`, `hhrpid` |
| `xw` suffix | Cross-sectional weight | `ahhwth`, `bhhwth` |

## Design Principles

| Principle | Evidence | Context |
|-----------|----------|---------|
| Pre-trend test before main results | Roth et al. (2023) | Always show event-study plot with pre-periods |
| Cluster SEs at individual level | Standard in panel DiD | Layoff is individual-level shock |
| Use "never-treated" as control group | CS2021 recommendation | Avoids contamination from late-treated as controls |
| Report both aggregate ATT and dynamic ATTs | Best practice | Aggregate masks heterogeneity |

## Stata Code Pitfalls

| Pitfall | Impact | Fix |
|---------|--------|-----|
| Forgetting `xtset` before panel commands | Wrong results or error | Always `xtset id wave` at top of estimation file |
| `tsfill` without documenting intent | Spurious observations, wrong N | Only use when intentionally balancing; comment why |
| `i.rel_time` vs `ibn.rel_time` | Wrong omitted category | Use `ibn.` to explicitly set base; verify with `testparm` |
| Absolute paths in sub-do-files | Breaks on other machines | All paths via `$root` global |
| Overwriting raw HILDA files | Irreversible | Work only on copies in `data/clean/` |
| Missing `cluster(id)` in `reghdfe` | Understated SEs | Always specify clustering level explicitly |
| `csdid` without `notyet` option | Uses late-treated as controls | Add `notyet` for clean never-treated comparison group |

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| Manual dummy creation for event study | Error-prone, hard to audit | Use `ibn.rel_time` factor syntax |
| Reporting raw `.log` file as result | Unformatted, non-reproducible | Use `esttab`/`estout` for all tables |
| Re-setting `set seed` in sub-do-files | Breaks replication across run orders | Seed set once in `master.do` only |
