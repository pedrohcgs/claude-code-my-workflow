---
name: seven-pass-review
description: Mechanize Pattern 15 — the seven-pass adversarial review protocol for academic manuscripts. Spawns 7 forked subagents in parallel (abstract, intro, methods, results, robustness, prose, citations), then synthesizes a prioritized revision checklist. Use for submission-ready or R&R-stage papers where single-pass review isn't enough.
argument-hint: "[manuscript path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
effort: high
---

# Seven-Pass Adversarial Review

Runs seven independent reviewers, each focused on a single lens, then synthesizes their findings into one prioritized revision plan. Pattern 15 from the workflow guide, mechanized.

**Why seven passes?** A single-agent review blends lenses and softens each one. Seven forked agents each approach the paper with full context budget for their own lens, then a synthesizer resolves conflicts and de-duplicates.

## Inputs

- `$0` — manuscript path (`.tex`, `.qmd`, `.md`, or `.pdf`). Required.

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
| 7 | Citation audit | Invokes `/validate-bib --semantic`; checks cite-claim direction for top-10 works | general-purpose |

## Workflow

### Phase 0: Pre-flight

1. Resolve manuscript path.
2. Decide if `.pdf` → extract text first (`pdftotext -layout`).
3. Create output dir: `quality_reports/seven_pass_[stem]/`.

### Phase 1: Spawn 7 reviewers in parallel

In a single message, spawn 7 Task tool calls (one per lens). Each subagent gets:

- The manuscript path (to re-read with its own context).
- The lens-specific prompt (below).
- Instructions to write to `quality_reports/seven_pass_[stem]/lens_[N]_[lens-name].md`.
- Severity tagging: CRITICAL / MAJOR / MINOR.

Lens prompt rubrics are embedded inline below — one summary paragraph per lens. Each forked subagent receives its lens's rubric plus the manuscript path.

**Lens prompt summaries:**

- **Lens 1 (Abstract):** Does the first sentence state the question? Does it name the method? Quantify the headline result? State one-sentence contribution? Cross-check: do these four things match the body?
- **Lens 2 (Intro):** Does the intro open with the question? Hook → context → contribution → roadmap? Lit review placed correctly (after the hook, not before)? Contribution-counted (1, 2, 3…)? Preview of findings with magnitudes?
- **Lens 3 (Methods):** Is every assumption stated? Are they strong or weak? Is identification one-liner clear? Are known violations (selection, measurement, reverse causality, SUTVA) addressed? Are instruments / RDD / DiD assumptions explicit and defensible?
- **Lens 4 (Results):** Does each table read standalone (caption, units, SEs clarified)? Is magnitude interpreted (not just significance)? Are units consistent across tables? Are figures legible at 8pt?
- **Lens 5 (Robustness):** Does the paper ANTICIPATE a sharp referee's objections? Are robustness checks motivated, or just listed? Power/placebo tests present? Heterogeneity explored where promised?
- **Lens 6 (Prose):** Sentences under 30 words? Active voice dominant? Hedging proportionate (neither overclaiming nor endless "may suggest")? Paragraph topic sentences?
- **Lens 7 (Citations):** Invoke `/validate-bib --semantic`. For top-10 cited works, does the in-text claim match the cited paper's actual finding direction? Are contemporary / competing works cited?

### Phase 2: Synthesize

Wait for all 7 lens reports. Then read them and produce:

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
Approx token usage: ~80–120k (vs ~15k for single-pass /review-paper).
Runtime: ~3–5 min wall-clock.
For cheaper alternatives:
  - Single-pass: /review-paper
  - Iterative: /review-paper --adversarial
```

## When to use this skill

- **Before first submission** to a top journal.
- **After a major revision** when you want to catch drift.
- **R&R when referees disagree** — surfaces contradictions your revision must navigate.

## When NOT to use

- Early drafts (use `/review-paper` single-pass first).
- Short notes, comments, or replies (overkill).
- When you've already run this in the last 7 days and nothing substantive changed.

## Cross-references

- `.claude/skills/review-paper/SKILL.md` — the single-pass and `--adversarial` modes (cheaper, faster).
- `.claude/skills/validate-bib/SKILL.md` — invoked by Lens 7.
- `.claude/skills/audit-reproducibility/SKILL.md` — complementary; numeric-claims side of the audit.
- Workflow guide, Pattern 15 — the narrative explanation of why seven lenses.

## Exit behavior

- Exits 0 always (review is informational). The synthesis report's "Executive verdict" is the gate.
- Any `CRITICAL` at the top of the synthesis should block submission until resolved.

## What this skill does NOT do

- Re-run seven lenses if the manuscript hasn't changed — check git diff against last run date in `_SYNTHESIS.md`, skip unchanged lenses if requested via `--incremental` (future).
- Auto-apply fixes — that's `/review-paper --adversarial`'s job.
- Replace human judgment. A reviewer who knows your subfield still beats seven LLMs.
