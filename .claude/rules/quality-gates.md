---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
---

# Quality Review & Scoring Rubrics

> **Framing:** Thresholds are **advisory at the harness level**. The `/commit` skill runs `quality_score.py` and halts on failure until the user fixes or explicitly overrides. A **real git pre-commit hook** (`.githooks/pre-commit`, activated once via `./scripts/install-hooks.sh`) extends the same gates to *every* commit, so bypassing the skill no longer bypasses the review — unless you opt out with `SKIP_QUALITY_GATE=1` / `--no-verify`. "Gate" here means "checkpoint enforced by a skill or the pre-commit hook," not an unconditional harness-level block.

## Thresholds

- **90/100 = Commit** -- good enough to save
- **95/100 = PR** -- ready for deployment
- **98/100 = Excellence** -- aspirational

> This project runs **stricter-than-default** gates (the template default is 80/90/95). The bar is raised because the deliverables — a Beamer slide deck and a descriptive note — are publication-facing.

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

## Enforcement (the /commit skill + an optional pre-commit hook)

- **Score < 90:** Halt within `/commit`. List blocking issues. User may override with an explicit natural-language signal ("commit anyway" / "skip quality gate") and a reason — the override is logged in the commit body.
- **Score < 95:** Allow commit within `/commit`, warn. List recommendations.
- **Direct `git commit`:** unenforced *until* you run `./scripts/install-hooks.sh`, which points `core.hooksPath` at the version-controlled `.githooks/pre-commit`. After that, every commit (skill or not) runs the surface-sync + quality (≥90) gates. Bypass sparingly with `SKIP_QUALITY_GATE=1` (quality only) or `git commit --no-verify` (all hooks); record the reason in the commit body.

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
