---
paths:
  - "Paper/**/*.tex"
  - "Slides/**/*.tex"
  - "Scripts/**/*.py"
  - "Scripts/**/*.R"
  - "explorations/**/*.py"
  - "explorations/**/*.R"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## LaTeX Paper (.tex in Paper/)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Equation error / wrong formula | -20 |
| Critical | Overfull hbox > 10pt in main text | -10 |
| Major | Missing robustness check reference in text | -5 |
| Major | Notation inconsistency vs. knowledge base | -5 |
| Major | Table/figure number mismatch with text reference | -5 |
| Minor | Widowed/orphaned lines | -2 |
| Minor | Long lines (> 100 chars, non-math) | -1 per line |

## Beamer Slides (.tex in Slides/)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Major | Notation inconsistency vs. paper | -5 |
| Minor | Font size reduction on single slide | -1 per slide |

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax error | -100 |
| Critical | Hardcoded absolute path | -20 |
| Critical | `fillna(0)` on return or financial data | -20 |
| Critical | `.shift()` without `groupby(firm)` in panel data | -20 |
| Critical | Wrong synchronicity formula (raw R², not log-odds) | -30 |
| Major | Missing `random_state` for stochastic operations | -10 |
| Major | No `requirements.txt` or version pinning | -5 |
| Major | `groupby` without handling multi-index after `apply` | -5 |
| Major | SEs not clustered at firm level | -10 |
| Minor | Lines > 100 chars (non-math) | -1 per line |
| Minor | Missing docstring on function | -1 per function |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() | -10 |
| Major | Using `lm()` instead of `feols()` for panel regressions | -10 |
| Major | SEs not clustered at firm level | -10 |
| Minor | Missing figure generation | -5 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Research)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | 1e-4 | Panel regressions, not simulations |
| Standard errors | 1e-3 | Clustered SEs have variability |
| R² (synchronicity) | 1e-6 | Computed from OLS, deterministic |
| t-statistics | 2 decimal places | Journal convention |
| p-values | < 0.01, < 0.05, < 0.10 | Standard finance convention |
