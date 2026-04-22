---
name: data-analysis-r
description: End-to-end R data analysis pipeline for empirical work. Use when the user wants an R-based workflow with numbered scripts under `scripts/R/` and outputs in `scripts/R/_outputs/`.
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis in R

Run an end-to-end R analysis using the reproducibility-first template in
`scripts/R/`.

## Constraints

- Follow `.claude/rules/r-code-conventions.md`
- Save scripts to `scripts/R/`
- Save outputs to `scripts/R/_outputs/`
- Save machine-readable objects as `.rds`
- Run `/review-r` on generated or modified R scripts before presenting results

## Workflow

1. Produce a short pre-flight report: data source, variables, task interpretation,
   and planned script sequence.
2. Use the numbered pipeline pattern:
   - `01_load.R`
   - `02_clean.R`
   - `03_analyze.R`
   - `04_tables.R`
   - `05_figures.R`
3. Keep paths relative to repo root.
4. Set one seed near the top of the orchestration layer.
5. Save tables, figures, and `.rds` objects to `scripts/R/_outputs/`.
6. Run `/review-r` on the main analysis script and address critical issues.

## Notes

- Prefer `fixest`, `modelsummary`, and `ggplot2` when they fit the task.
- If the user needs a different language, use `/data-analysis-python` or
  `/data-analysis-stata` instead.
