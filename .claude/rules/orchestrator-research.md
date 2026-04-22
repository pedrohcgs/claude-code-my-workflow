---
paths:
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "scripts/**/*.do"
  - "explorations/**"
  - "Figures/**/*.R"
  - "Figures/**/*.py"
  - "Figures/**/*.do"
---

# Research Project Orchestrator (Simplified)

For empirical scripts, simulations, and data analysis, use a simple loop:

```text
Plan approved
  -> implement
  -> verify by running the relevant script or pipeline
  -> score with quality gates if needed
  -> fix and re-verify until clear
```

## Verification expectations

- R scripts: `Rscript` runs cleanly and writes expected outputs
- Python scripts: `python` runs cleanly and writes expected outputs
- Stata do-files: batch or interactive run completes and writes expected outputs
- Stochastic workflows: seed discipline is explicit
- Figures and tables: expected files exist in `scripts/<language>/_outputs/`

## Checklist

```text
[ ] Script or pipeline runs without errors
[ ] No hardcoded absolute paths
[ ] Seed discipline is explicit when stochastic
[ ] Output files created at expected paths
[ ] Tolerance checks pass when applicable
[ ] Quality score >= 80 when scored
```
