---
paths:
  - "scripts/**/*.R"
  - "Figures/**/*.R"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

This protocol applies whenever working with papers that have replication packages (Stata, R, or other code). The goal is exact numerical reproducibility before any course-specific modifications.

---

## Why This Matters

- Incorrect replication = teaching students wrong numbers
- Translation errors (Stata to R) can silently change results
- Extensions built on a broken baseline propagate errors
- Students will attempt to replicate -- they must get the same numbers

---

## Phase 1: Inventory & Baseline

Before writing any R code:

1. **Read the paper's replication README** (or equivalent documentation)
2. **Inventory the replication package:**
   - What language? (Stata, R, Python, Matlab)
   - What data files? (sizes, formats, public vs restricted)
   - What scripts? (order of execution, dependencies)
   - What outputs? (tables, figures, estimates)

3. **Record gold standard numbers** -- the exact results from the paper:
   ```markdown
   ## Replication Targets: [Paper Author (Year)]

   | Target | Table/Figure | Value | SE/CI | Notes |
   |--------|-------------|-------|-------|-------|
   | Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
   | Placebo | Table 3, Col 1 | 0.012 | (0.891) | Should be ~0 |
   | ...     | ...           | ...   | ...   | ... |
   ```

4. **Store gold standard** in one of:
   - `quality_reports/LectureNN_replication_targets.md` (for reference)
   - An RDS file with named list of target values (for programmatic comparison)

---

## Phase 2: Translate & Execute

When translating code (typically Stata to R):

1. **Follow `r-code-conventions.md`** for all R coding standards
2. **Translate line-by-line initially** -- don't "improve" or "modernize" during replication
3. **Match the original specification exactly:**
   - Same covariates, same sample restrictions, same clustering
   - Same estimation method (even if a "better" one exists)
   - Same standard error computation
4. **Save all intermediate results as RDS:**
   - Raw data after cleaning: `LectureNN_data_clean.rds`
   - Estimation results: `LectureNN_estimates.rds`
   - Summary tables: `LectureNN_summary.rds`
5. **Execute and capture outputs**

### Common Stata to R Translation Pitfalls

<!-- Customize: Add pitfalls specific to your field's common packages -->

| Stata | R | Trap |
|-------|---|------|
| `reg y x, cluster(id)` | `feols(y ~ x, cluster = ~id)` | Stata clusters df-adjust differently from some R packages |
| `areg y x, absorb(id)` | `feols(y ~ x \| id)` | Check demeaning method matches |
| `probit` for PS | `glm(family=binomial(link="probit"))` | R default logit != Stata default in some commands |
| `bootstrap, reps(999)` | Depends on method | Match seed, reps, and bootstrap type exactly |

---

## Phase 3: Verify Match

Compare every target number:

```r
# Programmatic comparison
targets <- list(
  main_att = -1.632,
  main_se = 0.584,
  placebo = 0.012
)

results <- list(
  main_att = coef(model)[["treatment"]],
  main_se = sqrt(vcov(model)[["treatment", "treatment"]]),
  placebo = coef(placebo_model)[["treatment"]]
)

# Check each target
for (name in names(targets)) {
  diff <- abs(results[[name]] - targets[[name]])
  status <- if (diff < 0.01) "PASS" else "FAIL"
  message(sprintf("[%s] %s: paper=%.4f, ours=%.4f, diff=%.4f",
                  status, name, targets[[name]], results[[name]], diff))
}
```

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Instead:

1. **Isolate the discrepancy:** Which step introduces the difference?
2. **Check common causes:**
   - Sample size mismatch (different data cleaning)
   - Different SE computation (robust vs cluster vs analytical)
   - Different default options (e.g., R vs Stata logit convergence criteria)
   - Missing covariates or different variable definitions
3. **Document the investigation** even if unresolved
4. **Consult the instructor** if the difference persists and matters

### Generate Replication Report

Save to `quality_reports/LectureNN_replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Lecture:** [LectureNN]
**Original language:** [Stata/R/etc.]
**R translation:** [script path]

## Summary
- **Targets checked:** N
- **Passed:** M
- **Failed:** K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|
| Main ATT | -1.632 | -1.631 | 0.001 | PASS |
| Main SE | 0.584 | 0.586 | 0.002 | PASS |
| ...     | ...   | ...  | ...  | ... |

## Discrepancies (if any)
### [Target name]
- **Paper value:** X
- **Our value:** Y
- **Investigation:** [what we checked]
- **Root cause:** [if found]
- **Resolution:** [how resolved, or "pending"]

## Environment
- R version: [version]
- Key packages: [with versions]
- Data source: [path or URL]
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

1. **Commit the replication script** with a clear message: "Replicate [Paper] Table X -- all targets match"
2. **Now extend** with course-specific modifications:
   - Apply different estimators
   - Add new specifications
   - Create course-themed figures
   - Generate interactive plotly versions
3. **Each extension builds on the verified baseline** -- if an extension produces unexpected results, compare against the replicated baseline

---

## Integration

- **`/create-lecture` Phase 4:** When replication packages are provided, follow this protocol before creating figures
- **`/review-r`:** The r-reviewer agent checks for replication-related issues (DGP match, correct estimand)
- **`/substance-review`:** The domain reviewer checks code-theory alignment
