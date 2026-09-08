---
name: credible-claims
description: "Research-brief + claim-record discipline for delegated or AI-assisted research work. Use when starting any substantive research task or long autonomous run (write the brief first), and when reporting results that will support a claim in a paper or decision (produce the claim record). Keeps faster execution from being confused with credible evidence."
---




# Credible claims: the brief before, the record after

Cheaper generation increases demand for scarce validation. The fix is two lightweight artifacts: a **research brief** that constrains what the system may do, and a **claim record** that constrains what may be reported. Applies to agents, workflows, sims, proof patches, data construction — anything delegated.

## Three standing rules
1. **Delegate only after inputs, boundaries, and completion criteria are clear.** No open-ended "make it better" runs.
2. **Require evidence, not confident conclusions.** Every delegated task returns inspectable evidence: locations, diffs, diagnostics, counts, failing cases, logs — never just "done/looks fine."
3. **Escalate anything that changes the economic object, the identifying assumptions, the inferential procedure, or the reporting language.** Those decisions return to the researcher (the user), always. A standing user ruling counts as a returned decision; record it.

## The research brief (before execution)
One short block, written before launching the work:
- **Question / target:** what exactly is being estimated, proved, built.
- **Completion:** what counts as done; what results would *not* answer the question.
- **Prohibited substitutions:** what the system may not silently change (estimand, sample, assumptions, statement of a theorem, benchmark spec).
- **Known failure modes:** what tends to go wrong here; the checks matched to each.
- **Required evidence:** what must come back (numbers, locations, diffs, diagnostics).
- **Escalation triggers:** which findings/decisions must return to the user before proceeding.
- **Blocked-route rule:** a route that depends on unavailable data, an unsupported assumption, or an unproved result is marked *blocked* — a scientific outcome, not an instruction to search until a favorable answer appears.

## The claim record (during/after execution)
For each claim the work will support:
- **Support:** which data/analysis/proof supports it (with locations).
- **Changes after seeing results:** anything modified after outcomes were visible, and why (diagnostic-triggered fix vs favorable switch — keep these distinguishable).
- **Unresolved:** checks that remain open, and how they constrain the language.
- **Decision:** who decided what could be reported (user ruling vs assistant default).

Proportionality: a routine task needs one short paragraph; heavier records only when branching is extensive, outputs will be reused, errors are consequential, or correction is costly.

## Reporting language
The final decision is never "all checks green" — it is whether the evidence supports the proposed *language*. The options are: repair; **narrower language**; additional review; an *exploratory/descriptive* label; or decline to report. Never upgrade language beyond the evidence (associational ≠ causal; pointwise ≠ uniform; illustrated ≠ validated; imposed ≠ derived).

## Keep credibility questions separate
Reproducibility, implementation correctness, statistical performance, measurement validity, and identification/scope are different questions; evidence on one cannot answer another. Reproducible code may implement the wrong estimator; favorable simulations cannot establish an assumption; a correct estimate may answer the wrong question.

## Learn forward
Every diagnosed failure becomes a durable artifact: a reusable test, a documented warning, or a memory entry stating the failure, why it happened, and the check that now prevents it. Preserve failed approaches and the reason they failed — a blocked route re-attempted without a new mechanism is waste.

## Cross-references

- [`verification-ladder.md`](../../../.codex/references/verification-ladder.md) — rung 5 (the ledger)
- [`.codex/guidance/orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md) — RUN_CONFIG is the brief for a fan-out

