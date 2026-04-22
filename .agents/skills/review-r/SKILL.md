---
name: review-r
description: Read-only R code review protocol for `.R` scripts. Checks code quality, reproducibility, domain correctness, tidyverse or base-R hygiene, and professional standards; produces a report without editing. Use this for R-specific empirical code. Use `/review-python` or `/review-stata` for the other analysis stacks.
argument-hint: "[filename or 'all' or 'LectureN']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review R Scripts

Run the comprehensive R code review protocol.

## Steps

1. Identify scripts to review:
   - If `$ARGUMENTS` is a specific `.R` filename, review that file only.
   - If `$ARGUMENTS` is `LectureN`, review all matching R scripts.
   - If `$ARGUMENTS` is `all`, review all `.R` files in `scripts/R/` and `Figures/`.
2. For each script:
   - Read `.claude/rules/r-code-conventions.md`
   - Review reproducibility, path discipline, estimation hygiene, output discipline,
     and coding standards
   - Save a report to `quality_reports/[script_name]_r_review.md`
3. Present a concise summary:
   - issue counts by severity
   - top critical risks
   - whether the script is ready for replication-sensitive work

Do not edit the source files in this skill.
