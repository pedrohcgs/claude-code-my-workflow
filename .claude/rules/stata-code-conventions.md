---
paths:
  - "**/*.do"
  - "scripts/**/*.do"
  - "Figures/**/*.do"
---

# Stata Code Standards

**Standard:** Senior empirical Stata workflow suitable for replication-sensitive work.

## 1. Reproducibility

- Start each `do` file with an explicit `version` statement.
- Set one project seed in the orchestration layer when randomness appears.
- Use repo-root globals or locals consistently; avoid machine-specific paths.
- Open a log for orchestrated runs and save it under `scripts/stata/_outputs/`.

## 2. Project Structure

- Keep the staged pipeline split: load, clean, analyze, tables, figures.
- Use one main orchestrator `do` file to call the stages in order.
- Keep file names descriptive and stable.
- Use comments to document sample restrictions, estimands, and export logic.

## 3. Data and Estimation Hygiene

- Make merges, drops, and sample filters explicit.
- Document clustering, fixed effects, weights, and absorb logic.
- Save machine-readable outputs for anything cited in manuscripts or slides.
- Keep generated outputs in `scripts/stata/_outputs/`.

## 4. Tables and Figures

- Export publication-facing tables in `.tex`, `.csv`, or `.txt`.
- Export figures with explicit names and dimensions.
- Keep figure backgrounds and sizing consistent with the slide workflow.

## 5. Common Pitfalls

| Pitfall | Impact | Prevention |
| --- | --- | --- |
| Missing `version` | Behavior drifts across Stata releases | Pin the version in every file |
| Hardcoded drive paths | Breaks on other machines | Use repo-root globals |
| No log file | Hard to audit replication | Open a text log in the orchestrator |
| Hidden sample changes | Results drift silently | Comment every drop/keep/merge decision |

## 6. Checklist

```
[ ] version statement at top
[ ] Repo-relative globals or locals only
[ ] set seed if randomness appears
[ ] Log written for orchestrated runs
[ ] Publication outputs saved to scripts/stata/_outputs/
[ ] Comments explain identification or modeling choices
```
