---
name: review-stata
description: Read-only Stata do-file review protocol for empirical `.do` scripts. Checks reproducibility, version pinning, path discipline, logging, estimation hygiene, and professional standards; produces a report without editing.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Stata Scripts

Run a static review of Stata empirical scripts.

## Steps

1. Identify scripts to review:
   - If `$ARGUMENTS` is a specific `.do` file, review that file only.
   - If `$ARGUMENTS` is `all`, review all `.do` files in `scripts/stata/`.
2. For each script:
   - Read `.claude/rules/stata-code-conventions.md`
   - Check reproducibility, version statements, path globals, log handling,
     estimation hygiene, and output discipline
   - Save a report to `quality_reports/[script_name]_stata_review.md`
3. Present a concise summary:
   - issue counts by severity
   - top critical risks
   - whether the script is ready for replication-sensitive work

Do not edit the source files in this skill.
