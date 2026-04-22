---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "scripts/**/*.do"
---

# Quality Review & Scoring Rubrics

Thresholds are advisory at the repo level and enforced only by the workflows
that explicitly call `scripts/quality_score.py`.

## Thresholds

- **80/100 = Commit**
- **90/100 = PR**
- **95/100 = Excellence**

## Quarto Slides (.qmd)

| Severity | Issue | Deduction |
| --- | --- | --- |
| Critical | Compilation failure | -100 |
| Critical | Equation overflow | -20 |
| Critical | Broken citation | -15 |
| Major | Text overflow | -5 |
| Major | TikZ label overlap | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 |

## Beamer Slides (.tex)

| Severity | Issue | Deduction |
| --- | --- | --- |
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox risk | -10 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 |

## R Scripts (.R)

| Severity | Issue | Deduction |
| --- | --- | --- |
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() when stochastic | -10 |
| Major | Missing reproducibility outputs | -5 |

## Python Scripts (.py)

| Severity | Issue | Deduction |
| --- | --- | --- |
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing explicit seed when stochastic | -10 |
| Major | Missing `scripts/python/_outputs/` discipline | -5 |
| Minor | Missing main guard | -1 |

## Stata Do-files (.do)

| Severity | Issue | Deduction |
| --- | --- | --- |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing `version` statement | -10 |
| Major | Missing `set seed` when stochastic | -10 |
| Major | Missing orchestrator log | -5 |
| Minor | Missing `scripts/stata/_outputs/` discipline | -1 |

## Enforcement

- **Score < 80:** halt within the workflow that called the scorer.
- **Score < 90:** allow save/commit workflows but warn.
- **Direct git commands:** no enforcement unless the user wires in a hook.

## Quality Reports

Generate quality reports only when the workflow explicitly requests them.

## Research tolerances

Use `.claude/rules/replication-protocol.md` for cross-language numerical
tolerance thresholds.
