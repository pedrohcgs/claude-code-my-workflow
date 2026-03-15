---
paths:
  - "code/**/*.py"
  - "code/**/*.do"
  - "output/**"
  - "manuscript/**"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR / share** -- ready for co-author review
- **95/100 = Excellence** -- aspirational, submission-ready

## Python Scripts (`code/python/`)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax error / script crashes | -100 |
| Critical | Hardcoded absolute path | -20 |
| Critical | Data mutation of raw files | -20 |
| Major | No docstring on functions | -5 per function |
| Major | Imports not at top of file | -5 |
| Major | No seed for stochastic operations | -10 |
| Major | Output path does not match project structure | -10 |
| Minor | No inline comments on non-obvious logic | -2 |
| Minor | Variable names not descriptive | -2 |

## Stata Do-Files (`code/stata/`)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Do-file crashes with `r()` error | -100 |
| Critical | Hardcoded absolute path | -20 |
| Critical | Raw data modified in place | -20 |
| Major | No `set seed` before stochastic commands | -10 |
| Major | No `quietly` for intermediate output (log bloat) | -5 |
| Major | No log file opened | -10 |
| Major | Output file not created at expected path | -15 |
| Major | No version declaration (`version 19`) | -5 |
| Minor | No section comments | -2 |
| Minor | `tab` used instead of `tabulate` (abbrev) | -1 |

## Output Tables

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Table file missing or zero bytes | -100 |
| Critical | Wrong significance stars convention | -20 |
| Major | Standard errors not in parentheses | -10 |
| Major | Missing N or R-squared | -10 |
| Major | Non-booktabs formatting (for .tex) | -5 |
| Minor | Column alignment issues | -3 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Accounting Research)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | < 0.001 | Rounding in paper display |
| Standard errors | < 0.005 | Clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Observation counts | Exact match | No reason for any difference |
| Percentages | < 0.1pp | Display rounding |
