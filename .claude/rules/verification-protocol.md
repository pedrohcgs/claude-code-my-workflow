---
paths:
  - "code/**/*.py"
  - "code/**/*.do"
  - "output/**"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For Python Scripts (`code/python/`):

1. Run `python code/python/script_name.py` and check exit code (0 = success)
2. Verify output files were created at expected paths with non-zero size
3. Confirm no hardcoded absolute paths (search for `C:/`, `C:\`, `/Users/`, `/home/`)
4. Check imports are all at the top of the file
5. Spot-check key outputs for reasonable values (row counts, variable ranges)
6. Report verification results

## For Stata Do-Files (`code/stata/`):

1. Run in batch mode:
   ```
   "C:/Program Files/StataNow19/StataMP-64.exe" /e do code/stata/dofile.do
   ```
2. Check the generated `.log` file for errors (`r(` patterns indicate errors)
3. Verify output tables/figures were created in `output/` with non-zero size
4. Confirm no hardcoded absolute paths
5. Confirm `set seed` is present for any stochastic procedures
6. Report verification results

## For Output Tables (`output/tables/`):

1. Confirm file exists with non-zero size
2. Open/read the file and check for:
   - Correct number of rows/columns
   - Significance stars present where expected
   - Standard errors in parentheses
   - No missing values rendered as `.` in published tables
3. Verify booktabs formatting if `.tex`

## For Output Figures (`output/figures/`):

1. Confirm file exists with non-zero size
2. Check file format matches target journal requirements (`.eps`, `.pdf`, `.tif`)
3. Verify dimensions/resolution settings in the generating code (300 DPI minimum)

## Common Pitfalls:

- **Stata log files**: Always check `.log`, not just exit code — Stata exits 0 even with `r()` errors in some contexts
- **Hardcoded paths**: Any absolute path will break on another machine — use relative paths from project root
- **Assuming success**: Always verify output files exist AND contain correct content
- **Missing `set seed`**: Stochastic procedures without seeds are not reproducible

## Verification Checklist:

```
[ ] Script/do-file runs without errors
[ ] Output files created at expected paths
[ ] Output files have non-zero size
[ ] No hardcoded absolute paths
[ ] Seed set for any stochastic procedures
[ ] Key values spot-checked for reasonableness
[ ] Reported results to user
```
