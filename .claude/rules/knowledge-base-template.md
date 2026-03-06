---
paths:
  - "Paper/**/*.tex"
  - "Slides/**/*.tex"
  - "Scripts/**/*.py"
  - "Scripts/**/*.R"
---

# Project Knowledge Base: AIGC and Stock Price Synchronicity

<!-- Claude reads this before creating/modifying any paper content or scripts. -->

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Synchronicity | R²_i (firm-level) from market model | R²_i,t | "r-squared" (lowercase) |
| Log-odds transform | ψ_i = ln(R²_i / (1 − R²_i)) | ψ_i,t | Raw R² as dependent variable |
| Market model residuals | ε_i,t | firm-specific return residual | "error term" without subscript |
| AIGC adoption proxy | AIGC_i,t (firm-level, time-varying) | | "AI" (too broad) |
| Beta (market) | β_i | firm market beta | β (no subscript) |
| Stock return | r_i,t | firm i at time t | R_it (inconsistent caps) |
| Market return | r_m,t | market portfolio return | Rm (no time subscript) |

## Symbol Reference

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| R²_i,t | Firm-level R² from market model regression | Empirical Design |
| ψ_i,t | Log-odds of R²: ln(R²/(1−R²)) | Empirical Design |
| AIGC_i,t | AIGC adoption intensity/indicator for firm i at time t | Empirical Design |
| ε_i,t | Firm-specific return residual from market model | Empirical Design |
| β_i | Firm market beta | Empirical Design |
| r_i,t | Firm i stock return at time t | Empirical Design |
| r_m,t | Market portfolio return at time t | Empirical Design |

## Paper Structure

| Section | Core Question | Key Method | Key Output |
|---------|--------------|------------|------------|
| Introduction | How does AIGC adoption affect price informativeness? | Motivating evidence | Hypotheses |
| Empirical Design | How to measure AIGC and synchronicity? | Market model, text analysis | Variable definitions |
| Main Results | Does AIGC adoption reduce synchronicity? | Panel regression with FE | Baseline tables |
| Mechanism | Through what channel? | Mediation / heterogeneity | Mechanism tables |
| Robustness | Are results robust? | Alternative specs, placebo | Robustness tables |

## Empirical Applications

| Application | Paper | Dataset | Purpose |
|------------|-------|---------|---------|
| Stock price synchronicity | Roll (1988), Morck et al. (2000) | CRSP/Compustat | Baseline synchronicity measure |
| R² as synchronicity measure | Morck, Yeung & Yu (2000) | Cross-country | Motivates log-odds transform |
| Firm information environment | Durnev et al. (2003) | CRSP | R² and price informativeness |
| AIGC measurement | [TBD] | [TBD] | AIGC proxy construction |

## Design Principles

| Principle | Rationale |
|-----------|-----------|
| Use log-odds(R²) not raw R² | R² bounded [0,1]; log-odds is unbounded, better for OLS |
| Two-way fixed effects (firm + year) | Controls for time-invariant firm heterogeneity and macro shocks |
| Cluster SEs at firm level | Serial correlation in panel; errors correlated within firm |
| Winsorize at 1%/99% | Financial data routinely has extreme outliers |
| Staggered adoption design | AIGC rollout is staggered; use DiD or Sun & Abraham (2021) |

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| Raw R² as LHS variable | Bounded variable → OLS assumptions violated | Use log-odds(R²) = ψ |
| Cluster SEs at year level only | Ignores within-firm serial correlation | Cluster at firm (or two-way) |
| fillna(0) on return data | Treats missing as zero return (survivorship bias) | Drop or flag missing |
| `shift()` for returns | Introduces look-ahead bias | Compute returns explicitly with dates |
| Pooled OLS without FE | Omitted variable bias from firm and time effects | Always include firm + year FE |
| R² from panel regression as synchronicity | Mixes within and between variation | Compute R² from annual time-series regressions per firm |

## Python Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| `groupby` without `sort=False` | Silent row reordering | Always specify `sort=False` or sort explicitly |
| Multi-index after `groupby().apply()` | Unexpected index structure | Call `.reset_index()` after apply |
| `pct_change()` across firms in stacked panel | Computes cross-firm "return" | Use `groupby(firm).pct_change()` |
| `fillna(0)` on financial data | Survivorship/missing bias | Use `dropna()` or explicit flag |
| `.shift()` without groupby | Leaks across firms | Always `groupby(firm).shift()` |
| NaN propagation in R² computation | Silent NaN result | Assert no NaN before regression |
| Hardcoded ticker/PERMNO lists | Breaks replication | Load from data file |
| No `random_state` in sklearn | Non-reproducible results | Set `random_state=42` everywhere |

## R Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| Missing `set.seed()` | Non-reproducible results | Set once at top in YYYYMMDD format |
| Hardcoded absolute paths | Breaks on other machines | Use relative paths from project root |
| `lm()` instead of `feols()` for panel | No clustered SEs, no FE | Use `fixest::feols()` |
| `plm` default SEs | Not clustered | Specify `vcov = "cluster"` |

## Tolerance Thresholds

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | 1e-4 | Panel regressions, not simulations |
| Standard errors | 1e-3 | Clustered SEs have MC variability |
| R² (synchronicity) | 1e-6 | Computed from OLS, deterministic |
| t-statistics | Report to 2 decimal places | Journal convention |
| p-values | Report as < 0.01, < 0.05, < 0.10 | Standard finance convention |
