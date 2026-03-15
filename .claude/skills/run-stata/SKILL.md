---
name: run-stata
description: Execute a Stata do-file in batch mode using StataNow 19, check the log for errors, and verify that expected output files were created.
argument-hint: "[do-file path, e.g. code/stata/02_main_regressions.do]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Run Stata Do-File

Execute a Stata do-file in batch mode, check for errors, and verify outputs.

**Input:** `$ARGUMENTS` — path to a `.do` file (e.g., `code/stata/02_main_regressions.do`)

---

## Steps

1. **Pre-flight checks:**
   - Confirm the do-file exists: read `$ARGUMENTS`
   - Check for any obvious hardcoded absolute paths: grep for `C:\` or `C:/`
   - Note the expected output files from the do-file header comments

2. **Execute in batch mode:**
   ```bash
   "C:/Program Files/StataNow19/StataMP-64.exe" /e do $ARGUMENTS
   ```
   Run from the project root directory.

3. **Check the log file:**
   - Locate the log file (check `output/logs/` or the do-file directory)
   - Grep for Stata error codes: lines matching `r(` pattern
   - Grep for `end of do-file` to confirm the do-file ran to completion
   - Report any errors found

4. **Verify outputs:**
   - List files in `output/tables/` and `output/figures/` that match expected outputs
   - Check that each expected output file:
     - Exists
     - Has non-zero size
     - Was modified after the do-file was run (timestamp check)

5. **Report:**
   ```
   ## Run Report: [dofile_name.do]
   - Execution: PASS / FAIL
   - Log errors: NONE / [list r() codes]
   - Do-file completed: YES / NO
   - Outputs created:
     - output/tables/tab02_main.tex: YES (12 KB) ✓
     - output/figures/fig01.emf: YES (45 KB) ✓
   - Issues: [any warnings]
   ```

6. **If errors found:** Report the full error message from the log and suggest likely fixes based on the error code (reference StataNow 19 error code meanings).
