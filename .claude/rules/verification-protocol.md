---
paths:
  - "scripts/**/*.py"
  - "scripts/**/*.do"
  - "data/**"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For Python Scripts:
1. Run `python scripts/python/filename.py`
2. Verify output files were created with non-zero size
3. Check log output for errors or warnings
4. Spot-check key metrics (row counts, match rates, data types)
5. Report verification results

## For Stata Do-Files:
1. Run `stata-mp -b do scripts/stata/filename.do` (or `stata -b do ...`)
2. Check the .log file for errors (`grep -i "error\|invalid" filename.log`)
3. Verify output datasets exist and have expected row counts
4. Check merge diagnostics in the log
5. Report verification results

## For Data Outputs:
1. Verify file exists at expected path with non-zero size
2. Load and check: row count, column names, data types
3. Check for unexpected nulls in key columns
4. Check for duplicates on ID columns
5. If match output: report match rate, unique match rate, ambiguous rate

## Common Pitfalls:
- **Assuming success**: Always verify output files exist AND contain correct content
- **Ignoring merge diagnostics**: Check `_merge` in Stata, merge indicators in Python
- **Stale outputs**: Re-run scripts after edits; don't rely on old outputs
- **Path issues on different machines**: Always use relative paths

## Verification Checklist:
```
[ ] Script runs without errors
[ ] Output files created at expected paths
[ ] Row counts match expectations
[ ] Key metrics reported (match rates, coverage, etc.)
[ ] No unexpected warnings in logs
[ ] Reported results to user
```
