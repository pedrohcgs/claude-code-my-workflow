# Scoring Protocol (Rule 9)

**How individual agent scores aggregate into the overall project score.**

## Weighted Aggregation

The overall project score that gates submission (>= 95) is a weighted aggregate:

| Component | Weight | Source Agent |
|-----------|--------|-------------|
| Literature coverage | 10% | Editor's score of Librarian |
| Data quality | 10% | Surveyor's score of Explorer |
| Identification validity | 25% | Econometrician's score of Strategist |
| Code quality | 15% | Debugger's score of Coder |
| Paper quality | 25% | Average of Referee 1 + Referee 2 scores |
| Manuscript polish | 10% | Proofreader's score of Writer |
| Replication readiness | 5% | Verifier pass/fail (0 or 100) |

## Minimum Per Component

No component can be below 80 for submission. A perfect literature review can't compensate for broken identification.

## Score Sources

- Each critic produces a score from 0 to 100 based on its deduction table
- Scores start at 100 and deduct for issues found
- The Verifier is pass/fail (mapped to 0 or 100)
- Referee scores are averaged: `(Referee1 + Referee2) / 2`

## Gate Thresholds

| Gate | Overall Score | Per-Component Minimum | Action |
|------|--------------|----------------------|--------|
| Commit | >= 80 | None enforced | Allowed |
| PR | >= 90 | None enforced | Allowed |
| Submission | >= 95 | >= 80 per component | Allowed |
| Below 80 | < 80 | — | Blocked |

## When Components Are Missing

Not every project uses all components. If a component hasn't been scored:
- It's excluded from the weighted average
- Remaining weights are renormalized
- Example: no literature review → weights become 11%, 28%, 17%, 28%, 11%, 6%
