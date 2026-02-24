---
paths:
  - "slides/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/stata/**/*.do"
  - "project/**/*.do"
  - "project/**/*.py"
  - "project/**/*.do"
  - "project/**/*.py"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Beamer Slides (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Major | Text overflow | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Missing imports | -10 |
| Major | Missing random seed | -10 |
| Major | Missing docstrings on functions | -5 |
| Minor | Style violation | -1 |

## Stata Scripts (.do)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Missing `clear all` | -20 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing header block | -10 |
| Major | Missing log open/close | -5 |
| Minor | Style violation | -1 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Research)

<!-- Customize for your domain -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6] | [Numerical precision] |
| Standard errors | [e.g., 1e-4] | [MC variability] |
| Coverage rates | [e.g., +/- 0.01] | [MC with B reps] |
