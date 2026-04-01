---
name: data-linkage
description: Run data linkage pipeline, report match rates, and validate output quality
argument-hint: "[task description, e.g., 'run fuzzy matching on cleaned partners' or 'validate current match output']"
---

# Data Linkage Workflow

Run matching pipeline steps, validate outputs, and report quality metrics.

**Input:** `$ARGUMENTS` -- a description of the linkage task (e.g., "run exact matching on standardized names" or "validate match output quality").

---

## Constraints

- **Follow data-linkage-protocol** in `.claude/rules/data-linkage-protocol.md`
- **Follow Python code conventions** in `.claude/rules/python-code-conventions.md`
- **Never modify raw data** -- all outputs go to `data/processed/` or `data/output/`
- **Log every merge** with row counts before/after and match rates
- **Report quality metrics** after every matching step

---

## Workflow Phases

### Phase 1: Pre-Match Check

1. Read `.claude/rules/data-linkage-protocol.md` for matching standards
2. Verify input data exists and is accessible
3. Check current state: what matching has been done, what remains?
4. Log baseline statistics (total records, unique partners, unique firms)

### Phase 2: Execute Matching Step

Based on the task:
- **Exact matching:** standardized name + firm, highest confidence
- **Fuzzy matching:** string similarity with threshold, log scores
- **Supplementary matching:** additional signals (location, time period)

For each step:
1. Log input record counts
2. Run matching logic
3. Log output: matches found, match rate, ambiguous matches
4. Save intermediate results to `data/processed/`

### Phase 3: Quality Report

After matching, produce a summary:

```
=== Match Quality Report ===
Input records:        N
Matched (high conf):  N (X%)
Matched (medium):     N (X%)
Ambiguous:            N (X%)
Unmatched:            N (X%)
Total match rate:     X%
```

### Phase 4: Validation Check

1. Flag any duplicate links (one source -> multiple targets)
2. Sample matched pairs for spot-check
3. Identify patterns in unmatched records
4. Recommend next steps (more cleaning, lower threshold, manual review)

---

## Important

- **Log everything.** Match rates at every step.
- **Never overwrite silently.** Date-stamp outputs or use versioned filenames.
- **Validate before finalizing.** Run quality checks before declaring a step complete.
- **Use relative paths.** All paths relative to repository root.
