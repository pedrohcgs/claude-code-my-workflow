# `scripts/R/` — reproducibility-first analysis (SECONDARY)

R is the **secondary** analysis for this project (Stata is primary — see `scripts/stata/`). Use R for
publication-ready tables/figures, the **consumer-inference experiment** (`experiment/`), and the
**2×2 model numerics** (`theory/`).

## Conventions

Follow `.claude/rules/r-code-conventions.md`. Headline rules:

- **Run the numbered pipeline from `00_run_all.R`** — never source mid-pipeline scripts individually
  unless debugging.
- **Paths via `here::here()`** — never `setwd()`; the project root is the git repo root. No hardcoded
  absolute paths (`/review-r` enforces this).
- **Fixed seed** set once in `00_run_all.R` (`set.seed(20260413)`). Change only with a recorded reason.
- **`sessionInfo()`** written to `scripts/R/_outputs/sessionInfo.txt` for the replication package.
- **Outputs to `scripts/R/_outputs/`**; publication-ready tables (`.tex`/`.csv`) and figures
  (`.pdf` + `.svg`/`.png`).

## Layout

| Path | Responsibility |
| --- | --- |
| `00_run_all.R` | Orchestrator (kept from the template). Sources 01–05, writes `sessionInfo()`, prints timing. |
| `01_load.R … 05_figures.R` | Numbered pipeline **stubs** — load → clean → analyze → tables → figures. Populate for the review-ratings data. |
| `theory/` | Numerical equilibrium / comparative statics for the 2×2 model (Sun-2012 spread effect). |
| `experiment/` | Consumer-inference experiment analysis (pre-register first; see `/preregister`). |

## First-time setup

```r
install.packages(c("here", "ggplot2"))   # required — pipeline won't run without these
install.packages(c("svglite", "renv"))   # optional — SVG figures; version pinning
source("scripts/R/00_run_all.R")          # runs clean against the scaffolding stubs
```

## Reviewing

`/review-r scripts/R/<file>.R` (code review) + `/audit-reproducibility` (numeric verification against the
draft). `/data-analysis` is available for R-native exploratory work.

*(The scripts 01–05 are scaffolding stubs — the influencer-marketing Essay 2 pipeline was removed on
2026-09-14 when the repo was repurposed. They message a TODO and produce no outputs until populated.)*
