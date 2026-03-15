---
paths:
  - "code/**/*.do"
  - "code/**/*.py"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any code:

- [ ] Read the paper's replication README (if available)
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main coefficient | Table 2, Col 3 | 0.152 | (0.034) | Primary specification |
```

- [ ] Store targets in `quality_reports/replication_targets_[paper].md`

---

## Phase 2: Translate & Execute

- [ ] Follow `stata-conventions.md` and `python-conventions.md` for coding standards
- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save intermediate datasets as `.dta` in `data/processed/`

### Common Pitfalls in Accounting / Finance Empirical Work

| Issue | Trap | Solution |
|-------|------|----------|
| Standard errors | Different clustering levels (firm vs. firm+year) | Match original exactly; document in do-file |
| Sample period | Fiscal vs. calendar year cutoffs | Check paper footnotes carefully |
| Variable construction | Winsorization level (1% vs. 1/99%) | Match original percentile convention |
| Fixed effects | Industry × year vs. industry + year | Check reghdfe absorb() specification |
| China data | CSMAR vs. CNRDS variable naming differs by vintage | Document data vintage in header |
| Probit/Logit | Marginal effects at mean vs. average marginal effects | Match paper's reported quantity |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Observation counts | Exact match | No reason for any difference |
| Point estimates | < 0.001 | Rounding in paper display |
| Standard errors | < 0.005 | Clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample restrictions, SE computation, variable definitions, data vintage), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/replication_report_[paper].md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/etc.]
**Our replication:** [do-file path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- StataNow 19, key packages (with versions), CSMAR/CNRDS vintage, date downloaded
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication do-file: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with project-specific modifications (additional controls, subsamples, etc.)
- [ ] Each extension builds on the verified baseline
