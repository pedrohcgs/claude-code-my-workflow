---
name: review-stata
description: Run the Stata code review protocol on do-files. Checks code quality, reproducibility, standard error correctness, and professional standards. Produces a report without editing files.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Stata Scripts

Run the comprehensive Stata code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.do` filename: review that file only
   - If `$ARGUMENTS` is `all`: review all .do files in `scripts/Stata/`

2. **For each script, launch the `r-reviewer` agent** with instructions to:
   - Follow the Stata code review checklist (adapt R reviewer for Stata)
   - Read `.claude/rules/stata-code-conventions.md` for current standards
   - Read `.claude/rules/empirical-analysis-protocol.md` for workflow standards
   - Save report to `quality_reports/[script_name]_stata_review.md`
   - Focus on: standard error choices, variable documentation, regression header completeness

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit any Stata source files.**
   Only produce reports. Fixes are applied after user review.

## Stata Review Checklist

| Category | Check |
|----------|-------|
| Header | Author, date, inputs, outputs documented |
| SE Type | Correct for research design (cluster, robust, double) |
| Variables | Every constructed var has documentation comment |
| Paths | Relative paths via globals, no hardcoded absolute |
| Output | Uses eststo for regressions, esttab for tables |
| Error Handling | Checks for required files before proceeding |
| Reproducibility | Seed set for any random procedures |
