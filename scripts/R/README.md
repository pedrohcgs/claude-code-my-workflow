# `scripts/R/` - Reproducibility-first analysis template

This directory ships the R branch of the repo's three-language empirical
workflow. Use it when the analysis is naturally R-first, but keep its outputs
parallel to `scripts/python/` and `scripts/stata/`.

## Conventions

- Run everything from `00_run_all.R`.
- Keep all paths relative to the repository root.
- Set one project seed in the orchestrator.
- Write `sessionInfo()` or equivalent environment capture to
  `scripts/R/_outputs/`.
- Save all outputs to `scripts/R/_outputs/`.
- Keep the stage split: load, clean, analyze, tables, figures.

## Files

| Script | Responsibility |
| --- | --- |
| `00_run_all.R` | Orchestrator. Sources 01-05 in order and records environment info. |
| `01_load.R` | Read raw data into memory. |
| `02_clean.R` | Transform, merge, and clean. |
| `03_analyze.R` | Estimate models and save machine-readable results. |
| `04_tables.R` | Export publication-ready tables. |
| `05_figures.R` | Export publication-ready figures. |

## First-time setup

Install the packages your project needs, then run:

```r
source("scripts/R/00_run_all.R")
```

Expected outputs go to `scripts/R/_outputs/`.

## Related workflows

- `/data-analysis-r` for an R-first empirical pipeline
- `/review-r scripts/R/03_analyze.R` for static code review
- `/audit-reproducibility manuscript.tex scripts/R/_outputs/` for numeric checks

If the project is Python-first or Stata-first, use the sibling directories
`scripts/python/` or `scripts/stata/` instead.
