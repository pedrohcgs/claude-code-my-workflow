---
name: data-analysis-stata
description: End-to-end Stata empirical workflow using chained `.do` files under `scripts/stata/` and outputs in `scripts/stata/_outputs/`.
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis in Stata

Run an end-to-end Stata workflow using the reproducibility-first template under
`scripts/stata/`.

## Constraints

- Follow `.claude/rules/stata-code-conventions.md`
- Save `.do` files to `scripts/stata/`
- Save outputs to `scripts/stata/_outputs/`
- Keep repo-root globals explicit and stable
- Open a text log for orchestrated runs
- Run `/review-stata` on generated or modified Stata scripts before presenting results

## Workflow

1. Produce a short pre-flight report: data source, variables, task interpretation,
   and planned do-file sequence.
2. Use the staged pipeline pattern:
   - `01_load.do`
   - `02_clean.do`
   - `03_analyze.do`
   - `04_tables.do`
   - `05_figures.do`
3. Set one project seed in `00_run_all.do`.
4. Save estimation outputs in machine-readable files where possible (`.dta`,
   `.csv`, `.tex`, `.log`).
5. Save tables, figures, and logs to `scripts/stata/_outputs/`.
6. Run `/review-stata` on the main analysis do-file and address critical issues.

## Notes

- Keep `version` statements at the top of each `do` file.
- If the user needs Python or R instead, use `/data-analysis-python` or
  `/data-analysis-r`.
