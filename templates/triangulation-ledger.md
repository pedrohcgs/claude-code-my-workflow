# Triangulation ledger — what a check will mean, written before it runs

A robustness check, a placebo, an alternative sample, a second data source: each is evidence only if you decided **beforehand** what its result would mean. Decide afterwards and every outcome can be read as support. This ledger fixes the reading first.

`quality_reports/spec-ledger.md` records each specification *after* it runs. This file records, *before* a check runs, what result would support the claim, what would weaken it, and what would leave it undecided. The two link by **Check ID**.

**Rules.**
- A row is written and committed **before** the check runs. Its *Supports*, *Weakens* and *Ambiguous* cells are then frozen.
- A correction is a new row that names the row it replaces. Earlier rows are never edited.
- *Status* is honest. A check thought of after seeing a result is `post-hoc`, and it is reported as that.
- Every row eventually gets a *Result* and a *Reading*, including the ones that went against the claim. A row with no result is a check that was never run; say so in the paper or drop the row with a reason.

This file prescribes no method. The checks, and what counts as supporting, are the researcher's decisions. The ledger only makes them visible and fixes when they were made.

## Ledger

| Check ID | Fixed on (date, commit) | Claim it tests | Status | Supports the claim if… | Weakens the claim if… | Ambiguous if… | Ran on (date, script:line) | Result | Reading |
|---|---|---|---|---|---|---|---|---|---|
| T1 | 2026-__-__ · `abc1234` | *the claim, as the paper states it* | pre-specified / exploratory / post-hoc | *the result that would support it* | *the result that would weaken it* | *the range you could not call either way* | | | supports / weakens / ambiguous |

## How to use it

1. Before running a check, add its row with everything up to *Ambiguous*, and commit. The commit date is the evidence that the reading came first.
2. Run the check. Fill in *Ran on*, *Result* and *Reading* in a **new commit**. Do not rewrite the earlier cells; if the frozen reading turns out to be wrong, add a correcting row.
3. When writing up, report every row: the ones that weaken the claim with the same prominence as the ones that support it (see `.claude/rules/writing-with-ai.md`, "the results section prints what goes against you").
