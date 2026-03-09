---
paths:
  - "scripts/Stata/**/*.do"
  - "Data/**"
  - "Tables/**"
  - "Papers/**"
---

# Empirical Analysis Protocol

**Core principle:** Every analysis decision is documented. Tables are publication-ready before any commit.

---

## Phase 1: Data Preparation

### 1.1 Raw Data Inventory

- [ ] Document all data sources (vendor, sample period, variables)
- [ ] Record data access date (for reproducibility)
- [ ] Store raw data in `Data/raw/` — never modify raw data

### 1.2 Cleaning Script

```
scripts/Stata/01_clean_data.do
```

Steps:
1. Merge datasets by unique identifier
2. Handle missing values (document strategy: drop, impute, flag)
3. Drop duplicates
4. Construct key variables with full documentation
5. Save cleaned panel to `Data/clean/`

---

## Phase 2: Exploratory Analysis

### 2.1 Descriptive Statistics

- [ ] Full sample summary stats (N, mean, median, SD, min, max)
- [ ] Time-series trends
- [ ] Cross-sectional distributions
- [ ] Correlation matrix (pearson and spearman)

### 2.2 Univariate Plots

- [ ] Histograms for key variables
- [ ] Time trends
- [ ] Distribution checks (outliers, skewness)

---

## Phase 3: Main Tests

### 3.1 Specification

Before running regressions, document:

```markdown
## Main Specification: [Paper Title]

| Element | Decision | Rationale |
|---------|----------|-----------|
| Dependent Var | [variable] | [economic rationale] |
| Key Independent | [variable] | [hypothesis link] |
| Controls | [list] | [standard in literature] |
| FE | [firm, year] | [unobserved heterogeneity] |
| SE Clustering | [firm] | [serial dependence] |
```

### 3.2 Execution

- [ ] Run baseline specification
- [ ] Add controls incrementally
- [ ] Test economic significance (marginal effects, percentiles)
- [ ] Store all results with `eststo`

---

## Phase 4: Robustness Checks

| Check | Common Variations |
|-------|------------------|
| Alternative samples | Exclude extremes, different time windows |
| Alternative specs | Log, winsorized, different controls |
| Alternative SEs | Double-cluster, bootstrap |
| Placebo | Random assignment, shuffled treatment |
| Subsamples | By industry, size, region |

---

## Phase 5: Publication Tables

### 5.1 Table Specification

Before coding, complete `templates/table-spec.md`:

```markdown
## Table 1: Descriptive Statistics

| Panel | Content | Variables |
|-------|---------|-----------|
| A | Full Sample | all vars |
| B | By Treatment | treatment indicator |

Significance stars: * p<0.10, ** p<0.05, *** p<0.01
```

### 5.2 Export Standards

Use `esttab` with booktabs:

```stata
esttab Table1_* using "Tables/table1.tex" ///
    , booktabs replace ///
    se(%4.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 1: Descriptive Statistics") ///
    alignment(D{.}{.}{-1}) ///
    fragment
```

---

## Analysis Log

For every analysis project, maintain `Papers/[project_name]/analysis_log.md`:

```markdown
# Analysis Log: [Project Name]
**Started:** YYYY-MM-DD

## 2026-03-09
- Decision: Drop firms with missing ROA
- Rationale: Cannot compute ROA without both NI and AT
- Impact: Loses 234 observations (3.2%)

## 2026-03-10
- Decision: Cluster at firm level
- Rationale: Serial correlation within firms
- Alternative considered: Double-cluster (too few clusters: 42)
```

---

## Quality Gates

| Stage | Threshold | Check |
|-------|-----------|-------|
| Data Clean | 100% | No missing in key vars without documentation |
| EDA | Complete | All variables visualized |
| Main Tests | All specs run | Coefficient signs match hypothesis |
| Robustness | ≥5 checks | At least half "pass" |
| Tables | Publication-ready | No manual edits after export |

---

## Commit Protocol

**Never commit analysis results without:**
- [ ] All .do files versioned
- [ ] Table .tex files match Stata output
- [ ] Analysis log updated
- [ ] Paper draft reflects latest numbers
