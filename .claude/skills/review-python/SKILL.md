---
name: review-python
description: Review Python scripts for code quality, reproducibility, and data handling correctness
argument-hint: "[path to Python script, e.g., scripts/python/clean_form_ap.py]"
---

# Python Code Review

Review a Python script for quality, correctness, and adherence to project standards.

**Input:** `$ARGUMENTS` -- path to the Python script to review.

---

## Review Checklist

### 1. Structure & Style
- [ ] Header docstring (purpose, inputs, outputs, author, date)
- [ ] Imports at top (stdlib -> third-party -> local order)
- [ ] `if __name__ == "__main__":` guard present
- [ ] PEP 8 compliant naming (`snake_case`)
- [ ] Lines <= 100 characters (except long strings)

### 2. Type Hints & Documentation
- [ ] Type hints on all public function signatures
- [ ] Google-style docstrings on public functions
- [ ] Comments explain WHY, not WHAT

### 3. Reproducibility
- [ ] All paths via `pathlib.Path`, relative to project root
- [ ] No hardcoded absolute paths
- [ ] Random seed set if any randomization used
- [ ] Package versions pinned in requirements

### 4. Data Handling
- [ ] Merge diagnostics logged (row counts before/after, `_merge` indicator)
- [ ] No silent data loss (filters/drops without logging)
- [ ] Input validation at entry points (file exists, columns present)
- [ ] Intermediate results saved to `data/processed/`

### 5. Logging
- [ ] Uses `logging` module (not `print()` for status)
- [ ] Key metrics logged (match rates, row counts, timings)
- [ ] Warnings for unexpected but non-fatal conditions

### 6. Error Handling
- [ ] No broad `except:` without re-raise
- [ ] Clear error messages for bad inputs
- [ ] Fails fast on invalid data

---

## Scoring

Apply the quality-gates rubric from `.claude/rules/quality-gates.md`.

**Output format:**

```
=== Python Review: [filename] ===
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
