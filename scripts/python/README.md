# scripts/python/

Python does the **data collection and text work** for this project (Stata is primary for the statistics —
see `scripts/stata/`). Conventions: `.claude/rules/python-code-conventions.md`.

## Layout

| Path | Responsibility |
| --- | --- |
| `scraping/` | Collect platform data — Google/Yelp published star-rating histograms, review counts, and Yelp's not-recommended pile. Output raw pulls to `data/scraped/`. |
| `classifier/` | The LLM review-text classifier: prompts, elicitation runner, and **validation** against a labeled hold-out. |
| `_outputs/` | Derived tables/figures/intermediate artifacts. |

Within each subfolder use numbered scripts (`01_*.py`, `02_*.py`, …). Conventions:

- Project-root-relative paths via `pathlib`; **no hardcoded absolute paths**.
- Seed a `numpy.random.Generator` once; document it.
- **Publication-ready** figures (≥300 DPI, white bg, raster + vector) and labeled tables.
- **Time-stamp and version every LLM elicitation** (model, version, prompt id, seed) — models are
  non-stationary and this is load-bearing for reproducibility.

## Reviewing

No Python-native `/data-analysis` skill and no `.py` quality scorer — pair with `/audit-reproducibility`
(numeric checks on outputs), `/capture-environment` (pin the env), and `/verify-claims` for the classifier.
Validate the classifier on a **held-out labeled set**, not the training data.
