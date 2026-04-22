---
name: data-analysis-python
description: End-to-end Python data analysis pipeline for empirical work. Use when the user wants a Python-based workflow with staged scripts under `scripts/python/` and outputs in `scripts/python/_outputs/`.
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis in Python

Run an end-to-end empirical workflow in Python using the reproducibility-first
template under `scripts/python/`.

## Constraints

- Follow `.claude/rules/python-code-conventions.md`
- Save scripts to `scripts/python/`
- Save outputs to `scripts/python/_outputs/`
- Keep paths repo-relative with `pathlib.Path`
- Save machine-readable results as `.csv`, `.json`, `.parquet`, or `.pkl`
- Run `/review-python` on generated or modified Python scripts before presenting results

## Workflow

1. Produce a short pre-flight report: data source, variables, task interpretation,
   and planned script sequence.
2. Use the staged pipeline pattern:
   - `01_load.py`
   - `02_clean.py`
   - `03_analyze.py`
   - `04_tables.py`
   - `05_figures.py`
3. Set one project seed near the top of `00_run_all.py`.
4. Use `pandas` for tabular work and appropriate modeling libraries
   (`statsmodels`, `linearmodels`, etc.) for estimation.
5. Save tables, figures, and machine-readable outputs to
   `scripts/python/_outputs/`.
6. Run `/review-python` on the main analysis script and address critical issues.

## Notes

- Prefer transparent figure backgrounds and explicit export dimensions.
- If the user needs Stata or R instead, use `/data-analysis-stata` or
  `/data-analysis-r`.
