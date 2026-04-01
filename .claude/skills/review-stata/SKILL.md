---
name: review-stata
description: Review Stata do-files for code quality, reproducibility, and merge diagnostics
argument-hint: "[path to Stata do-file, e.g., scripts/stata/merge_partners.do]"
---

# Stata Code Review

Review a Stata do-file for quality, correctness, and adherence to project standards.

**Input:** `$ARGUMENTS` -- path to the Stata do-file to review.

---

## Review Checklist

### 1. Structure
- [ ] Header block (purpose, inputs, outputs, author, date)
- [ ] `clear all` / `set more off` at top
- [ ] `log using` at start, `log close` at end
- [ ] Logical section organization with comments

### 2. Paths & Reproducibility
- [ ] `global root` set once at top
- [ ] All paths relative to `${root}`
- [ ] No hardcoded absolute paths
- [ ] `set seed` if any randomization

### 3. Merge Diagnostics (Critical)
- [ ] `tab _merge` after every merge
- [ ] Row counts logged before and after merges
- [ ] `_merge` inspected before being dropped
- [ ] Match rates documented

### 4. Data Quality
- [ ] `duplicates report` or `isid` on key identifiers
- [ ] Missing value checks on critical variables
- [ ] `assert` statements for expected conditions
- [ ] `describe` / `summarize` after loading data

### 5. Documentation
- [ ] Comments explain WHY, not WHAT
- [ ] Non-obvious variable transformations documented
- [ ] Cleaning decisions documented

---

## Scoring

Apply the quality-gates rubric from `.claude/rules/quality-gates.md`.

**Output format:**

```
=== Stata Review: [filename] ===
Score: XX/100

Critical Issues:
- [issue] (line X)

Major Issues:
- [issue] (line X)

Minor Issues:
- [issue] (line X)

Recommendations:
- [suggestion]
```

**Do not edit files.** Report only.
