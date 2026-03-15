---
paths:
  - "code/**/*.py"
  - "code/**/*.do"
  - "explorations/**"
---

# Research Project Orchestrator (Simplified)

**For Python scripts, Stata do-files, and data analysis** -- use this simplified loop instead of the full multi-agent orchestrator.

## The Simple Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IMPLEMENT — Execute plan steps
  │
  Step 2: VERIFY — Run code, check outputs
  │         Python: script runs without error, outputs created
  │         Stata: do-file completes, log clean, outputs created
  │         Tables: correct format, stars, SE in parentheses
  │         Figures: file exists, non-zero size, 300 DPI minimum
  │         If verification fails → fix → re-verify
  │
  Step 3: SCORE — Apply quality-gates rubric
  │
  └── Score >= 80?
        YES → Done (commit when user signals)
        NO  → Fix blocking issues, re-verify, re-score
```

**No 5-round loops. No multi-agent reviews. Just: write, test, done.**

## Verification Checklist

- [ ] Script/do-file runs without errors
- [ ] All imports/packages loaded at top
- [ ] No hardcoded absolute paths
- [ ] `set seed YYYYMMDD` present if stochastic (Stata) or `random.seed()` / `np.random.seed()` (Python)
- [ ] Output files created at expected paths
- [ ] Output files have non-zero size
- [ ] Tolerance checks pass (if replicating existing results)
- [ ] Quality score >= 80
