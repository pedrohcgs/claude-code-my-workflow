---
name: strategize
description: Design an implementation-ready empirical strategy by fixing the estimand, data variation, assumptions, specification, inference, robustness, falsification tests, and rejected alternatives before confirmatory analysis. Use after a research question exists and before analysis code is treated as confirmatory.
---

# Design the empirical strategy

Turn a research question and available evidence into an auditable analysis
contract. This skill designs a strategy; use `$research-ideation` when the
question itself is still open and `$preregister` when a registration document
is the requested deliverable.

## Pre-strategy inventory

Before recommending a design, inspect what exists:

- the research specification or interview record;
- the literature review and checked bibliography;
- data documentation, sample structure, variable availability, and access
  constraints;
- existing analysis, figures, or design notes;
- `.codex/references/project-profile.md` when it has been customized; and
- `.codex/references/discipline-cards.md` for relevant defaults.

Write a short `pre_strategy_report.md` naming every input read, the exact
identifying variation available, material data limitations, and missing inputs.
Do not silently fill a missing literature, data, or institutional premise with
a favorable assumption. Mark the strategy `INCOMPLETE` when a missing input
prevents a defensible choice, and state what would resolve it.

## Design contract

Define the estimand before the estimator. Then specify:

1. the target population, treatment or exposure, outcome, time horizon, and
   aggregation level;
2. the exact variation that identifies the estimand and why it is available in
   these data;
3. the primary specification, sample, variable construction, controls, fixed
   effects, estimator, and inference procedure;
4. every identifying assumption, in formal or precise prose, plus its plain
   meaning, credibility evidence, testable implications, and known blind spots;
5. diagnostics, robustness checks, placebos, falsification tests, and
   sensitivity analyses ordered by the threat they address;
6. implementation-ready pseudocode, including package/function choices only
   when verified for the project environment; and
7. rejected alternatives, why they were rejected, and evidence that would make
   the team revisit the decision.

For a design-specific audit, read only the relevant section of
[design-checklists.md](references/design-checklists.md). Use
[strategy-artifacts.md](references/strategy-artifacts.md) for the output schema.
Do not use statistical significance as evidence for an untestable identifying
assumption, and do not write an "expected result" that turns robustness into a
search for favorable estimates. State the diagnostic pattern and the decision
it would trigger instead.

## Outputs and review

Save the strategy bundle under `quality_reports/strategy/<project>/`:

- `pre_strategy_report.md`
- `strategy_memo.md`
- `pseudo_code.md`
- `robustness_plan.md`
- `falsification_tests.md`

Record the approved design and rejected alternatives with the repository's
[decision-record template](../../../templates/decision-record.md). Ask the user
to approve the strategy before labeling downstream work confirmatory. When an
independent methods review is requested or consequential, dispatch the existing
`methods-referee`; adjudicate its findings before revising the strategy.

Do not run the analysis, preregister, draft a paper, commit, or contact a
registry unless the user separately authorizes that work.
