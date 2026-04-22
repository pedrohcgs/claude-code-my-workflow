---
name: review-python
description: Read-only Python code review protocol for empirical `.py` scripts. Checks reproducibility, path discipline, estimation hygiene, output structure, and professional standards; produces a report without editing.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Python Scripts

Run a static review of Python empirical scripts.

## Steps

1. Identify scripts to review:
   - If `$ARGUMENTS` is a specific `.py` file, review that file only.
   - If `$ARGUMENTS` is `all`, review all `.py` files in `scripts/python/`.
2. For each script:
   - Read `.claude/rules/python-code-conventions.md`
   - Check reproducibility, path handling, environment assumptions, estimation
     logic, and output discipline
   - Save a report to `quality_reports/[script_name]_python_review.md`
3. Present a concise summary:
   - issue counts by severity
   - top critical risks
   - whether the script is ready for replication-sensitive work

Do not edit the source files in this skill.
