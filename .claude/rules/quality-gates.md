---
paths:
  - "Paper/**/*.tex"
  - "Talks/**/*.tex"
  - "scripts/**/*.R"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for submission/deployment
- **95/100 = Excellence** -- aspirational

## Paper LaTeX (.tex in Paper/)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Critical | Typo in equation | -10 |
| Major | Undefined reference (\ref) | -5 |
| Major | Notation inconsistency | -5 |
| Major | Missing figure/table at referenced path | -5 |
| Major | Hedging language ("interestingly", "it is worth noting") | -3 |
| Minor | Overfull hbox 1-10pt | -1 |
| Minor | Long lines (>100 chars) | -1 (EXCEPT math formulas) |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs (wrong clustering, wrong estimand) | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() | -10 |
| Major | Missing figure/table generation | -5 |
| Major | Non-reproducible output (no session info) | -5 |

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
Only the paper and R script scores are blocking.

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
