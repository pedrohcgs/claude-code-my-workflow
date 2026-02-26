---
paths:
  - "Paper/**/*.tex"
  - "Talks/**/*.tex"
  - "scripts/**/*.R"
  - "scripts/**/*.do"
  - "scripts/**/*.py"
  - "scripts/**/*.jl"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for submission/deployment
- **95/100 = Submission** -- meets top-journal standard (requires per-component minimums)

## Aggregation (see scoring-protocol.md for weights)

The overall score is a weighted aggregate of component scores. At the submission gate (>= 95), every component must also individually score >= 80.

## Paper LaTeX (.tex in Paper/)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Numbers in text don't match tables | -25 |
| Critical | Undefined citation | -15 |
| Critical | Broken reference (\ref) | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Critical | Typo in equation | -10 |
| Major | Notation inconsistency | -5 |
| Major | Missing figure/table at referenced path | -5 |
| Major | Hedging language ("interestingly", "it is worth noting") | -3 per (max -15) |
| Minor | Overfull hbox 1-10pt | -1 |
| Minor | Long lines (>100 chars) | -1 (EXCEPT math formulas) |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors / script doesn't run | -100 |
| Critical | Domain-specific bugs (wrong clustering, wrong estimand) | -30 |
| Critical | Code doesn't match strategy memo | -25 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing robustness checks from memo | -15 |
| Major | Wrong clustering level | -15 |
| Major | Missing set.seed() | -10 |
| Major | Missing RDS saves (HIGH — Quarto can't render) | -10 |
| Major | Magnitude of main result implausible | -10 |
| Major | Missing figure/table generation | -5 |
| Major | Non-reproducible output (no session info) | -5 |
| Minor | No documentation headers | -5 |
| Minor | Missing outputs (stale) | -5 |

## Stata Scripts (.do)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Script doesn't run | -100 |
| Critical | Domain-specific bugs (wrong clustering, wrong estimand) | -30 |
| Critical | Code doesn't match strategy memo | -25 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing robustness checks | -15 |
| Major | Missing `set seed` | -10 |
| Major | Missing `esttab`/`outreg2` output | -5 |
| Minor | No documentation headers | -5 |

## Talks (Auxiliary — Advisory Only, Non-Blocking)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Major | Slide count outside format range | -10 |
| Major | Result not in paper (talk-only result) | -10 |
| Major | Notation mismatch with paper | -5 |
| Minor | Overfull hbox | -2 |
| Minor | Dense slide without font reduction | -1 |

Talk scores are reported as "Talk: XX/100" but do **not** block commits or PRs.

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- **Score >= 95 + all components >= 80:** Submission-ready.
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
