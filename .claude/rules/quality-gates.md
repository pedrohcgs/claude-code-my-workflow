---
paths:
  - "scripts/**/*.py"
  - "scripts/**/*.do"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for review
- **95/100 = Excellence** -- aspirational

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax error / script won't run | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Silent data loss (unlogged drops/filters) | -20 |
| Critical | Merge without diagnostics | -15 |
| Major | Missing docstrings on public functions | -5 |
| Major | Missing type hints on public functions | -3 |
| Major | print() instead of logging | -3 |
| Major | No input validation at entry point | -3 |
| Minor | Import order wrong (stdlib/third-party/local) | -1 |
| Minor | Long lines (>100 chars, non-string) | -1 per line |
| Minor | Missing `if __name__ == "__main__"` guard | -2 |

## Stata Scripts (.do)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax error / script won't run | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Merge without `tab _merge` | -15 |
| Critical | Silent data loss (drop without logging) | -15 |
| Major | Missing header block | -5 |
| Major | No `log using` / `log close` | -5 |
| Major | No duplicate check on key identifiers | -5 |
| Minor | Missing comments on non-obvious logic | -1 |

## Data Quality (Match Outputs)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Match rate not reported | -20 |
| Critical | No validation sample reviewed | -15 |
| Major | Duplicate links (one source ID -> multiple targets) | -10 |
| Major | Threshold not documented/justified | -5 |
| Minor | No date stamp on output file | -2 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Tolerance Thresholds (Matching)

| Parameter | Threshold | Rationale |
|-----------|-----------|-----------|
| Exact match confidence | HIGH (no threshold) | Name + firm exact match |
| Fuzzy name similarity | >= 0.90 Jaro-Winkler | Based on validation review |
| Fuzzy + firm match | >= 0.85 | Firm match compensates for name variation |
| Manual review zone | 0.80 - 0.90 | Human judgment required |
| Reject | < 0.80 | Too uncertain to link |
