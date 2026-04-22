---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "docs/**"
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "scripts/**/*.do"
---

# Task Completion Verification Protocol

At the end of every non-trivial task, verify the output actually works.

## Quarto / HTML slides

1. Run `./scripts/sync_to_docs.sh` (or the lecture-specific variant).
2. Check render output for errors.
3. Verify figures and image paths.
4. Spot-check dense slides for overflow or layout breakage.

## LaTeX / Beamer slides

1. Compile with XeLaTeX.
2. Check for errors and overfull warnings.
3. Open the PDF if visual inspection matters.

## TikZ in HTML / Quarto

1. Convert PDF diagrams to SVG for browser use.
2. Verify SVG files contain valid markup.
3. Confirm deployed paths resolve in `docs/`.

## R scripts

1. Run `Rscript scripts/R/<file>.R` or `Rscript scripts/R/00_run_all.R`.
2. Verify `scripts/R/_outputs/` contains the expected artifacts.
3. Spot-check key estimates for plausible magnitude.

## Python scripts

1. Run `python scripts/python/<file>.py` or `python scripts/python/00_run_all.py`.
2. Verify `scripts/python/_outputs/` contains the expected artifacts.
3. Spot-check key estimates or summaries for plausible magnitude.

## Stata do-files

1. Run the relevant `do` file or `scripts/stata/00_run_all.do`.
2. Verify `scripts/stata/_outputs/` contains the expected artifacts and log.
3. Spot-check key estimates or summaries for plausible magnitude.

## Checklist

```text
[ ] Output file(s) created successfully
[ ] No compilation or runtime errors
[ ] Expected paths and deployment targets resolve
[ ] Visual or numeric spot-check completed
[ ] Results reported back to the user
```
