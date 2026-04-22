---
paths:
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "scripts/**/*.do"
  - "Figures/**/*.R"
  - "Figures/**/*.py"
  - "Figures/**/*.do"
---

# Replication-First Protocol

**Core principle:** replicate the original results before extending them,
regardless of whether the implementation language is R, Python, or Stata.

## Phase 1: Inventory & baseline

Before writing new empirical code:

- Read the paper's replication README.
- Inventory the replication package: language, data files, scripts, outputs.
- Record the gold-standard quantities from the paper.
- Store targets in `quality_reports/` as a markdown or JSON artifact.

## Phase 2: Translate or execute faithfully

- Follow the relevant language conventions:
  - `.claude/rules/r-code-conventions.md`
  - `.claude/rules/python-code-conventions.md`
  - `.claude/rules/stata-code-conventions.md`
- Match the original sample, covariates, clustering, transformations, and
  output definitions before "improving" anything.
- Save machine-readable intermediate results under
  `scripts/<language>/_outputs/`.

## Phase 3: Verify match

### Tolerance thresholds

| Type | Tolerance | Rationale |
| --- | --- | --- |
| Integers (N, counts) | Exact | No reason for difference |
| Point estimates | < 0.01 | Display rounding |
| Standard errors | < 0.05 | Bootstrap or clustering variation |
| P-values | Same significance level | Exact display may differ |
| Percentages | < 0.1pp | Display rounding |

If the match fails, stop and isolate the divergence before extending.

## Phase 4: Only then extend

After all targets pass:

- commit or checkpoint the verified baseline
- make extensions on top of that baseline
- document every extension relative to the replicated core

## Enforcement

This rule is enforced by `/audit-reproducibility`. That skill compares
manuscript claims against the current outputs under `scripts/R/_outputs/`,
`scripts/python/_outputs/`, or `scripts/stata/_outputs/`.
