---
paths:
  - "scripts/**/*.py"
  - "scripts/stata/**/*.do"
  - "project/**/*.do"
  - "project/**/*.py"
  - "project/**/*.do"
  - "project/**/*.py"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/replication_targets.md` or as pickle/parquet

---

## Phase 2: Translate & Execute

- [ ] Follow `python-code-conventions.md` or `stata-code-conventions.md` for coding standards
- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save all intermediate results (pickle/parquet for Python, .dta for Stata)

### Stata to Python Translation Pitfalls

<!-- Customize: Add pitfalls specific to your field -->

| Stata | Python | Trap |
|-------|--------|------|
| `reg y x, cluster(id)` | `smf.ols(); .fit(cov_type='cluster')` | Check df adjustment matches |
| `areg y x, absorb(id)` | `linearmodels.PanelOLS` | Check demeaning method matches |
| `probit` for PS | `statsmodels Probit` | Default link functions may differ |
| `bootstrap, reps(999)` | Depends on method | Match seed, reps, and bootstrap type exactly |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/etc.]
**Translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- Python version, key packages (with versions), data source
- OR: Stata version, ado packages, data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with project-specific modifications (different estimators, new figures, etc.)
- [ ] Each extension builds on the verified baseline
