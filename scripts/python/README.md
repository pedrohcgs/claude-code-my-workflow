# `scripts/python/` - Reproducibility-first analysis template

This directory mirrors the R pipeline with a Python-native workflow. Use it for
empirical projects built around `pandas`, `statsmodels`, `linearmodels`,
`matplotlib`, or other Python tools.

## Conventions

- Run the full pipeline from `00_run_all.py`.
- Keep raw loading, cleaning, analysis, tables, and figures in separate files.
- Write all outputs to `scripts/python/_outputs/`.
- Keep paths repo-relative with `pathlib.Path`.
- Set one project seed near the top of the orchestrator and reuse it downstream.
- Save machine-readable outputs (`.csv`, `.json`, `.pkl`, `.parquet`) alongside
  publication-facing files (`.tex`, `.pdf`, `.png`, `.svg`).
- Record environment details in `scripts/python/_outputs/environment.txt`.

## Files

| Script | Responsibility |
| --- | --- |
| `00_run_all.py` | Orchestrator. Runs the stage scripts in order and writes environment metadata. |
| `01_load.py` | Read raw data. No transformations. |
| `02_clean.py` | Type coercion, merges, missingness handling, feature creation. |
| `03_analyze.py` | Estimation, tests, model objects, robustness checks. |
| `04_tables.py` | Publication-ready tables to `.tex`, `.csv`, or `.html`. |
| `05_figures.py` | Publication-ready figures to `.pdf`, `.png`, and optional `.svg`. |

## First-time setup

Create a virtual environment and install what your project needs. A typical
stack:

```bash
python -m venv .venv
. .venv/bin/activate
pip install pandas statsmodels matplotlib seaborn
```

Then run:

```bash
python scripts/python/00_run_all.py
```

Expected outputs go to `scripts/python/_outputs/`.

## Reviewing

- `/review-python scripts/python/03_analyze.py` for static code review
- `/audit-reproducibility manuscript.tex scripts/python/_outputs/` for numeric checks
