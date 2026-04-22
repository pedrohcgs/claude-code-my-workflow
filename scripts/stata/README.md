# `scripts/stata/` - Reproducibility-first analysis template

This directory mirrors the R and Python pipelines with a Stata-native
`do`-file chain. Use it when your empirical workflow is most naturally expressed
in Stata, but keep outputs in a structure that the rest of the repo can audit.

## Conventions

- Run the full pipeline from `00_run_all.do`.
- Keep loading, cleaning, analysis, tables, and figures in separate `do` files.
- Write all outputs to `scripts/stata/_outputs/`.
- Use repo-relative globals rooted at the repository directory.
- Set one project seed in the orchestrator and reuse it downstream.
- Always write a log file so reproducibility audits have text evidence.
- Save machine-readable outputs (`.dta`, `.csv`, `.tex`, `.log`) alongside
  figures (`.pdf`, `.png`, `.svg` when relevant).

## Files

| Script | Responsibility |
| --- | --- |
| `00_run_all.do` | Orchestrator. Defines paths, opens a log, and runs 01-05 in order. |
| `01_load.do` | Read raw data. No transformations. |
| `02_clean.do` | Type coercion, merges, sample restrictions, feature creation. |
| `03_analyze.do` | Estimation, tests, model objects, robustness checks. |
| `04_tables.do` | Publication-ready tables to `.tex`, `.csv`, or `.txt`. |
| `05_figures.do` | Publication-ready figures to `.pdf`, `.png`, or `.svg` via conversion. |

## First-time setup

Run from Stata in batch mode or interactively:

```stata
do scripts/stata/00_run_all.do
```

Expected outputs go to `scripts/stata/_outputs/`.

## Reviewing

- `/review-stata scripts/stata/03_analyze.do` for static do-file review
- `/audit-reproducibility manuscript.tex scripts/stata/_outputs/` for numeric checks
