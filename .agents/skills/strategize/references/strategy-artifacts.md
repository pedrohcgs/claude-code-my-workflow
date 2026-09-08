# Strategy artifact contract

Use these sections as a schema, not as a reason to pad the memo. Unknowns stay
visible as `UNRESOLVED`; assumptions that are not directly testable say so.

## Pre-strategy report

- Inputs read, with paths or citations
- One-sentence research question
- Target population and available sample
- Candidate outcomes, treatment or exposure, and time horizon
- Identifying variation actually present in the data
- Candidate designs and feasibility
- Data, literature, access, or institutional gaps and their consequences
- Status: `READY` or `INCOMPLETE`

## Strategy memo

### Estimand

Give a formal definition when useful and a plain-language interpretation.
Specify population, treatment contrast, outcome, horizon, and aggregation. For
a local estimand, characterize the population to which it applies.

### Identification and specification

Name the identifying variation before writing the estimating equation. Define
every symbol and data field; state the estimator, sample, comparison group,
weights, fixed effects or controls, inference unit, and planned uncertainty
measure. Link each choice to an evidence or design rationale.

### Assumptions

For each assumption record:

- precise statement;
- plain-language interpretation;
- credibility evidence;
- observable implication or `not directly testable`;
- plausible violation and its likely direction of bias, when knowable; and
- diagnostic or sensitivity analysis and the decision it informs.

### Threat-prioritized tests

Order checks by inferential threat, not convenience:

1. tests of identifying variation and design integrity;
2. falsification and placebo outcomes/timings/exposures;
3. specification and sample sensitivity;
4. inference sensitivity; and
5. formal bounds or sensitivity analysis.

For each, state `threat`, `implementation`, `observable pattern`, and
`decision rule`. Do not state that the preferred estimate is the expected
result.

### Alternatives and invalidation

List serious alternative designs, why each was rejected, and what new evidence
would reopen it. End with the smallest set of findings that would invalidate or
materially narrow the proposed strategy.

## Pseudocode

Pseudocode must identify inputs, transformations, estimator calls, parameter
choices, outputs, and checks precisely enough that an analyst can implement it
without guessing. It is not production code and does not license unverified
package or API claims.

## Falsification tests

Keep falsification tests distinct from robustness checks. A falsification test
targets a pattern the proposed causal or structural account says should not
occur. Record what a failure means; do not dismiss it merely because the main
estimate remains statistically significant.
