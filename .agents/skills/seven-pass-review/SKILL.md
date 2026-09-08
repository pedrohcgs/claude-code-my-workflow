---
name: seven-pass-review
description: "Mechanize Pattern 15 — the seven-pass adversarial review protocol for academic manuscripts. Spawns 7 forked subagents in parallel (abstract, intro, methods, results, robustness, prose, citations), then synthesizes a prioritized revision checklist. Use for submission-ready or R&R-stage papers where single-pass review isn't enough."
---



# Seven-Pass Adversarial Review

Runs seven independent reviewers, each focused on a single lens, then synthesizes their findings into one prioritized revision plan — the fan-out → reduce → judge runtime from `orchestrator-protocol.md`, applied with seven lenses.

**Why seven passes?** A single-agent review blends lenses and softens each one. Seven forked agents each approach the paper with full context budget for their own lens, then a synthesizer resolves conflicts and de-duplicates.

> **When to pick this over `$review-paper`:** This skill costs roughly 7× more tokens than `$review-paper` (default) and ~2× more than `$review-paper --adversarial`. Use it when the paper is submission-ready or at R&R stage and you need maximum lens coverage. For early drafts or iterative work, `$review-paper` is the right tool. For journal-simulation pressure test, use `$review-paper --peer <journal>` instead.

## Inputs

- `the first argument` — manuscript path (`.tex` or `.md`, or `.pdf`). Required.

## The Seven Lenses

Each lens runs as a **forked subagent** (context: fork) so the main conversation stays clean.

| # | Lens | Focus | Agent type |
|---|---|---|---|
| 1 | Abstract audit | Does the abstract state the question, method, result, and contribution? Does it match the paper? | general-purpose |
| 2 | Intro structure | Does the intro follow Cochrane / Varian framework? Literature placement? Contribution clarity? | general-purpose |
| 3 | Methods / identification | Are assumptions stated? Is identification credible? Are alternatives addressed? | domain-reviewer |
| 4 | Results + tables | Do tables read standalone? Is magnitude + significance discussed? Units consistent? | general-purpose |
| 5 | Robustness | Are obvious threats pre-empted? Is the robustness section convincing or theatrical? | general-purpose |
| 6 | Prose quality | Sentence-level clarity, hedging, passive voice, paragraph cohesion | proofreader |
| 7 | Citation audit | Invokes `$validate-bib --semantic`; checks cite-claim direction for top-10 works | general-purpose |

## Workflow

### Phase 0: Pre-flight

1. Resolve manuscript path.
2. Decide if `.pdf` → extract text first (`pdftotext -layout`).
3. Create output dir: `quality_reports/seven_pass_[stem]/`.

### Phase 1: Spawn 7 reviewers in parallel

In a single message, spawn 7 subagent calls (one per lens). Each subagent gets:

- The manuscript path (to re-read with its own context).
- The lens-specific prompt (below).
- Instructions to write to `quality_reports/seven_pass_[stem]/lens_[N]_[lens-name].md`.
- A **JSON findings array** conforming to [`finding-schema.json`](../../../.codex/references/finding-schema.json), written to `quality_reports/seven_pass_[stem]/lens_[N]_[lens-name].json` beside the prose report. Severities: `blocker | major | minor | nit`. Every finding computes its `id` with `python3 scripts/validate-findings.py --id FILE LINE LOCUS` and carries `rule`, `evidence`, and a `failing_case`. Phase 2 **validates each array first** (`python3 scripts/validate-findings.py <file>` — exit 0 required; a lens whose report does not validate has not reviewed), then reduces over the typed findings — it does not re-read the prose. Because ids are lens-independent, the same defect found by two lenses dedups to one finding automatically.

This is the **fan-out** primitive from [`orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md); `Agent` subagents are the portable mechanism (the agents that fill lenses 3/6 are in [`agent-fleet.md`](../../../.codex/references/agent-fleet.md)).

Lens prompt rubrics are embedded inline below — one summary paragraph per lens. Each forked subagent receives its lens's rubric plus the manuscript path.

**Lens prompt summaries:**

- **Lens 1 (Abstract):** Does the first sentence state the question? Does it name the method? Quantify the headline result? State one-sentence contribution? Cross-check: do these four things match the body?
- **Lens 2 (Intro):** Does the intro open with the question? Hook → context → contribution → roadmap? Lit review placed correctly (after the hook, not before)? Contribution-counted (1, 2, 3…)? Preview of findings with magnitudes?
- **Lens 3 (Methods):** Is every assumption stated? Are they strong or weak? Is identification one-liner clear? Are known violations (selection, measurement, reverse causality, SUTVA) addressed? Are instruments / RDD / DiD assumptions explicit and defensible?
- **Lens 4 (Results):** Does each table read standalone (caption, units, SEs clarified)? Is magnitude interpreted (not just significance)? Are units consistent across tables? Are figures legible at 8pt?
- **Lens 5 (Robustness):** Does the paper ANTICIPATE a sharp referee's objections? Are robustness checks motivated, or just listed? Power/placebo tests present? Heterogeneity explored where promised?
- **Lens 6 (Prose):** Sentences under 30 words? Active voice dominant? Hedging proportionate (neither overclaiming nor endless "may suggest")? Paragraph topic sentences?
- **Lens 7 (Citations):** Invoke `$validate-bib --semantic`. For top-10 cited works, does the in-text claim match the cited paper's actual finding direction? Are contemporary / competing works cited?

### Phase 2: Synthesize (reduce → judge, with the hallucination gate)

Wait for all 7 lens reports. **Reduce, don't re-review:** stack the seven `scorecard`s and apply the gate predicate from [`orchestration-schemas.md` §3](../../../.codex/references/orchestration-schemas.md) — the Executive verdict is a function of the typed findings, not a fresh eighth opinion. Then **run the post-judge hallucination gate** ([§4](../../../.codex/references/orchestration-schemas.md)): any CRITICAL the synthesis introduces that **no lens raised** must be re-verified in a fresh `claim-verifier` fork, or dropped to `[JUDGE-HALLUCINATED]` and the verdict recomputed. A synthesis may freely downgrade or de-duplicate lens findings; it may not invent a new blocker.

Then produce:

`quality_reports/seven_pass_[stem]/_SYNTHESIS.md`

```markdown
# Seven-Pass Review: [Manuscript]

**Date:** YYYY-MM-DD
**Path:** [manuscript]

## Executive verdict

**Overall state:** [SUBMIT / REVISE-MINOR / REVISE-MAJOR / REJECT-AND-RESTART]

## Cross-lens CRITICAL issues
| # | Lens(es) | Issue | Recommendation |
|---|---|---|---|

## MAJOR issues (second-round)
| # | Lens(es) | Issue |
|---|---|---|

## MINOR polish
[bulleted]

## Per-lens scorecard
| Lens | Critical | Major | Minor | Score/10 |
|---|---|---|---|---|
| 1. Abstract | | | | |
| 2. Intro | | | | |
| 3. Methods | | | | |
| 4. Results | | | | |
| 5. Robustness | | | | |
| 6. Prose | | | | |
| 7. Citations | | | | |
| **Overall** | | | | |

## Revision plan (in recommended order)
1. [Highest-leverage fix — usually a lens with 2+ CRITICALs]
2. …
7. [Lowest-leverage polish]

## Contradictions between lenses
[If two lenses disagree, surface here. E.g., Lens 2 says "expand contribution" but Lens 6 says "trim intro".]
```

### Phase 3: Token-budget report

After synthesis, print:

```
Seven-pass review complete.
Subagents: 7 (parallel) + 1 synthesizer.
Approx token usage: ~80–120k (vs ~15k for single-pass $review-paper).
Runtime: ~3–5 min wall-clock.
For cheaper alternatives:
  - Single-pass: $review-paper
  - Iterative: $review-paper --adversarial
```

## When to use this skill

- **Before first submission** to a top journal.
- **After a major revision** when you want to catch drift.
- **R&R when referees disagree** — surfaces contradictions your revision must navigate.

## When NOT to use

- Early drafts (use `$review-paper` single-pass first).
- Short notes, comments, or replies (overkill).
- When you've already run this in the last 7 days and nothing substantive changed.


## Findings are validated, not just written (v2.5)

This skill's reviewers emit findings under the machine-checked contract in
[`finding-schema.json`](../../../.codex/references/finding-schema.json). Reports are JSON **arrays**.

**Smoke-test the harness before spending review effort** — a run that fans out reviewers and
then cannot write a valid report has wasted the whole pass:

```bash
echo '[]' | python3 scripts/validate-findings.py
```

Then, before presenting any summary:

```bash
python3 scripts/validate-findings.py <report>.json   # exit 0 required
```

What the contract forces, and why:

- **`rule`** — the documented rule or standard violated. A finding citing no rule is an
  opinion, and opinions do not gate a commit.
- **`failing_case`** — a concrete configuration under which the claim breaks, or the exact
  missing hypothesis. *"This could be clearer"* does not validate.
- **`id = sha1("<file>:<line>:<locus>")`** — deterministic, so dedup across rounds is
  exact and the two-strikes rule is checkable rather than eyeballed.
- **`mechanical`** — `true` only for fixes that cannot change a result (typo, cross-reference,
  formatting, label). **Never** for an estimand, assumption, specification, inference
  procedure, sample definition, or reporting language: those return to the researcher.

Apply the **per-lens evidence burdens** and the **"does NOT count" filters** in
[`orchestration-schemas.md` §7](../../../.codex/references/orchestration-schemas.md) *before*
verification, so known false alarms never reach the judge. The verifier pass is
**refute-biased**: only `verdict: "confirmed"` findings ship; anything it cannot ground is
dropped, not downgraded to a warning.

## Cross-references

- `.agents/skills/review-paper/SKILL.md` — the single-pass and `--adversarial` modes (cheaper, faster).
- `.agents/skills/validate-bib/SKILL.md` — invoked by Lens 7.
- `.agents/skills/audit-reproducibility/SKILL.md` — complementary; numeric-claims side of the audit.
- Workflow guide, Pattern 15 — the narrative explanation of why seven lenses.

## Exit behavior

- Exits 0 always (review is informational). The synthesis report's "Executive verdict" is the gate.
- Any `CRITICAL` at the top of the synthesis should block submission until resolved.

## What this skill does NOT do

- Re-run seven lenses if the manuscript hasn't changed — check git diff against last run date in `_SYNTHESIS.md`, skip unchanged lenses if requested via `--incremental` (future).
- Auto-apply fixes — that's `$review-paper --adversarial`'s job.
- Replace human judgment. A reviewer who knows your subfield still beats seven LLMs.

