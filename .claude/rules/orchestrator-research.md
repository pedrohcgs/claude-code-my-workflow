---
paths:
  - "scripts/**/*.py"
  - "scripts/**/*.do"
  - "explorations/**"
  - "data/**"
---

# Research Project Orchestrator (Simplified)

**For Python/Stata scripts, data processing, and matching pipelines** -- use this simplified loop instead of the full multi-agent orchestrator.

## The Simple Loop

```
Plan approved -> orchestrator activates
  |
  Step 1: IMPLEMENT -- Execute plan steps
  |
  Step 2: VERIFY -- Run code, check outputs
  |         Python scripts: runs without error, outputs exist
  |         Stata scripts: runs without error, log clean
  |         Data outputs: row counts, match rates, no duplicates
  |         If verification fails -> fix -> re-verify
  |
  Step 3: SCORE -- Apply quality-gates rubric
  |
  +-- Score >= 80?
        YES -> Done (commit when user signals)
        NO  -> Fix blocking issues, re-verify, re-score
```

**No 5-round loops. No multi-agent reviews. Just: write, test, done.**

## Verification Checklist

- [ ] Script runs without errors
- [ ] All imports/packages at top
- [ ] No hardcoded absolute paths
- [ ] Merge diagnostics logged (every merge)
- [ ] Output files created at expected paths
- [ ] Key metrics reported (match rates, row counts)
- [ ] Quality score >= 80
