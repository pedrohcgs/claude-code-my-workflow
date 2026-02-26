---
name: review-r
description: Code review dispatching the Debugger agent in standalone mode (categories 4-12 only). Checks code quality, reproducibility, figure standards, and professional polish. Use for R, Stata, Python, or Julia scripts.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Code Scripts

Run the code review protocol by dispatching the **Debugger** agent in standalone mode.

In standalone mode, the Debugger runs **categories 4-12 only** (code quality). Categories 1-3 (strategic alignment) require a strategy memo and are only run within the pipeline or via `/econometrics-check`.

## Workflow

### Step 1: Identify Scripts

- If `$ARGUMENTS` is a specific file: review that file only
- If `$ARGUMENTS` is `all`: review all scripts in `scripts/R/`, `scripts/stata/`, `scripts/python/`, `scripts/julia/`
- If `$ARGUMENTS` is a directory: review all scripts in that directory

### Step 2: Launch Debugger Agent

For each script (or batch), delegate to the `debugger` agent via Task tool:

```
Prompt: Review [file] in standalone mode (categories 4-12 only).
Categories:
  4. Script structure (header, sections, flow)
  5. Console hygiene (no print/cat pollution, clean output)
  6. Reproducibility (set.seed, relative paths, no hardcoded values)
  7. Function design (DRY, appropriate abstraction level)
  8. Figure quality (labels, dimensions, theme, transparency)
  9. RDS pattern (saveRDS for all computed objects)
  10. Comments (explain why, not what)
  11. Error handling (graceful failures, informative messages)
  12. Polish (consistent style, no dead code, clean namespace)
Save report to quality_reports/[script_name]_code_review.md
```

### Step 3: Present Summary

After all reviews complete:
- Total issues found per script
- Breakdown by severity (Critical / Major / Minor)
- Top 3 most critical issues across all scripts
- Code review score

### Step 4: IMPORTANT

**Do NOT edit any source files.** Only produce reports. Fixes are applied after user review, either manually or by re-dispatching the Coder agent.

---

## Principles

- **Standalone mode = code quality only.** Strategic alignment (does the code match the design?) requires a strategy memo.
- **Language-flexible.** Same categories apply to R, Stata, Python, Julia — adapt checks to language idioms.
- **Proportional severity.** A missing `set.seed()` is Major. A missing comment is Minor.
- **Worker-critic separation.** The Debugger never fixes code — it only critiques.
