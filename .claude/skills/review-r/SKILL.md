---
name: review-code
description: Run the code review protocol on Python scripts or Stata do-files. Checks code quality, reproducibility, path management, and output standards. Produces a report without editing files.
argument-hint: "[filename or 'all' or 'python' or 'stata']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Code (Python or Stata)

Run the comprehensive code review protocol on Python scripts or Stata do-files.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific `.py` filename: review that Python script only
   - If `$ARGUMENTS` is a specific `.do` filename: review that Stata do-file only
   - If `$ARGUMENTS` is `python`: review all scripts in `code/python/`
   - If `$ARGUMENTS` is `stata`: review all do-files in `code/stata/`
   - If `$ARGUMENTS` is `all`: review all files in both directories

2. **For each Python script, launch the `python-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/python-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_python_review.md`

3. **For each Stata do-file, launch the `stata-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/stata-conventions.md` for current standards
   - Save report to `quality_reports/[dofile_name]_stata_review.md`

4. **After all reviews complete**, present a summary:
   - Total issues found per file
   - Breakdown by severity (Critical / Major / Minor)
   - Top 3 most critical issues across all files

5. **IMPORTANT: Do NOT edit any source files.**
   Only produce reports. Fixes are applied after user review.
