---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
  - "**/*.py"
  - "notebooks/**"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Quarto Slides (.qmd)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Compilation failure | -100 |
| Critical | Equation overflow | -20 |
| Critical | Broken citation | -15 |
| Critical | Typo in equation | -10 |
| Major | Text overflow | -5 |
| Major | TikZ label overlap | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors or import failures | -100 |
| Critical | Unit confusion (W/m² vs kW/m²) | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Timezone-naive solar timestamps | -15 |
| Major | Missing random seed in stochastic code | -10 |
| Major | No docstrings on public functions | -5 |
| Major | Missing unit labels on plot axes | -5 |
| Minor | PEP 8 violations (not auto-fixed by black) | -2 |
| Minor | Missing type hints on public API | -1 |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() | -10 |
| Major | Missing figure generation | -5 |

## Beamer Slides (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (PV Reliability)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Degradation rate (R_d) | ±0.05 %/year | Measurement uncertainty |
| Energy yield | ±2% | Combined model uncertainty |
| Temperature coefficients | ±0.02 %/°C | Typical measurement precision |
| Irradiance calibration | ±1% | Pyranometer accuracy (secondary standard) |
| Weibull shape parameter | ±0.1 | Fit uncertainty with limited samples |
