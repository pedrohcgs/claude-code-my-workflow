---
name: data-analysis
description: Legacy compatibility entry point for the R analysis workflow. Prefer `/data-analysis-r` for new work; this skill remains available so older prompts and repo references keep working.
argument-hint: "[dataset path or analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis (Legacy R Compatibility)

This skill is the backward-compatible alias for the R workflow.

## Default behavior

- Use the numbered R pipeline in `scripts/R/`
- Save outputs to `scripts/R/_outputs/`
- Follow `.claude/rules/r-code-conventions.md`
- Run `/review-r` on modified analysis scripts before presenting results

## Preferred modern entry points

- `/data-analysis-r` for R
- `/data-analysis-python` for Python
- `/data-analysis-stata` for Stata
