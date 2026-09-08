---
name: review-paper
description: "Comprehensive manuscript review with three modes: single-pass (default), --adversarial critic-fixer loop, and --peer [journal] simulated peer-review pipeline (editor + 2 dispositioned referees + editorial decision, calibrated to a target journal). R&R continuation via --peer --r2/--r3; hostile-editor stress test via --peer --stress; reviewer-disposition variance reporting via --peer --variance N. Auto-invokes $review-r + $audit-reproducibility on referenced scripts unless --no-cross-artifact."
---



# Manuscript Review

Produce a thorough, constructive review of an academic manuscript — the kind of report a top-journal referee would write.

> **Which review skill do I want?**
>
> - **`$review-paper`** (this skill) — single comprehensive report, optional `--adversarial` critic-fixer loop, or `--peer <journal>` simulated peer-review pipeline. Best for **most drafts**.
> - **`$seven-pass-review`** — seven independent lenses in parallel (abstract, intro, methods, results, robustness, prose, citations) then synthesized. Heavier (7× token cost). Best for **submission-ready drafts** or **R&R stage** where you need maximum coverage.
> - **`$respond-to-referees`** — if you already have referee comments and need a response document, not another review.
> - **`$slide-excellence`** — for research presentation slides, not papers.

**Input:** `the arguments supplied with the invocation` — path to a paper (`.tex`, `.pdf`, or `.md`), or a filename in `master_supporting_docs/`. Optional flags:

- `--adversarial` — critic-fixer loop (max 5 rounds).
- `--peer <JOURNAL>` — simulated peer review pipeline calibrated to `<JOURNAL>` (see `.codex/references/journal-profiles.md` for available short names).
- `--r2` / `--r3` — R&R continuation mode (requires `--peer`). Reloads prior round, classifies concerns Resolved / Partial / Not addressed.
- `--stress` — hostile-editor stress test (requires `--peer`). Forces SKEPTIC dispositions, doubles critical peeves.
- `--variance` (followed by integer **N**, default 3) — reviewer-disposition variance mode (requires `--peer`). Runs **N** referees with **independently sampled** dispositions from the 6-way taxonomy. Editor aggregates into a **decision distribution**, not a point estimate. Mutually exclusive with `--stress` and `--r2`/`--r3`.
- `--no-novelty-check` — skip editor's web search novelty probe (default is ON).
- `--no-cross-artifact` — skip auto-invocation of `$review-r` + `$audit-reproducibility` on referenced scripts.

> **Already received referee comments?** Use [`$respond-to-referees`](../respond-to-referees/SKILL.md) instead. That skill cross-references each referee concern against the revised manuscript and drafts a complete response document.

---

## Modes

### Default mode (single-pass)

One comprehensive review report. Fast, low token cost, suitable for early drafts where the author wants feedback and will iterate manually.

### Adversarial mode (`--adversarial`)

Iterative critic-fixer loop with independent review and adjudication. The critic identifies issues, the fixer proposes and applies edits (with user approval), and the critic re-audits. Loops until APPROVED or max 5 rounds.

Use when: preparing a pre-submission draft, responding to a journal-desk rejection with substantive revisions, or after your own major rewrite. Costs more tokens but produces a manuscript the critic has signed off on.

### Peer-review mode (`--peer <JOURNAL>`)

Simulated editorial pipeline: **editor desk review → referee selection → 2 blind referees with different dispositions → editorial synthesis**. Calibrated to a target journal from `.codex/references/journal-profiles.md`. Use when: pre-submission dress rehearsal, choosing between target journals, R&R planning.

This mode is materially different from `--adversarial`: adversarial runs the same critic 5× with fresh context; `--peer` runs **different personas** (editor + 2 dispositioned referees drawn from 6-way taxonomy: STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC) whose priors are *deliberately different* and who are blind to each other.

**Agents used** (all reimplemented in this template; adapted from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with permission):

- `.codex/agents/editor.md` — editor (desk review, referee selection, synthesis).
- `.codex/agents/domain-referee.md` — substance referee.
- `.codex/agents/methods-referee.md` — methodology referee (paper-type-aware).

**Sub-flags:**

- `--r2` / `--r3` — R&R mode. Skips fresh desk review; reloads prior round's reports; same referees + dispositions + peeves; classifies each prior concern as Resolved / Partial / Not addressed. Hard cap at `--r3` (no round 4+).
- `--stress` — Hostile editor. Forces both referees to SKEPTIC disposition, doubles critical peeves, framing: "you are looking for reasons to reject this paper." Output is a concern-list gauntlet, not a decision letter.
- `--variance` (with integer **N**, default 3) — Reviewer-disposition variance mode. Runs **N** referees with **independently sampled** dispositions from the 6-way taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC). Editor synthesizes into a **distribution of decisions**, not a single verdict. See "Variance mode" below.
- `--no-novelty-check` — Disables the editor's web search novelty probes (default is ON). Use in offline or hallucination-sensitive contexts. **Novelty-check caveat (document this to users):** web search can return hallucinated citations or miss paywalled recent work. Always surface novelty-probe results as flags for manual verification, not verdicts.

#### Variance mode (`--peer --variance N`)

**Why this mode exists.** Default `--peer` runs an editor + 2 referees with dispositions sampled once. A single peer-review pass is a point estimate of how the paper would fare — but the AgentReview ACL 2024 study ([arXiv:2406.12708](https://arxiv.org/abs/2406.12708)) found that **~37% of paper decisions vary purely from reviewer-disposition sampling** and another 27.7% from partial author-identity disclosure. A point estimate hides this variance.

Variance mode runs N independent referees (default N=3, max N=5 for token-cost discipline) with disposition sampling, then reports a **decision distribution** that surfaces this variance to the author.

**How it works:**

1. Editor performs desk review once (shared across the N referees).
2. The editor samples N dispositions from the 6-way taxonomy **with replacement**. Stratification rule: if N ≥ 3, at least one SKEPTIC is always sampled (avoids drawing N friendly referees by chance).
3. Each of the N referees runs in an isolated context (`Agent` with `context: fork`) — same manuscript, same paper-type rubric, different disposition. Referees are blind to each other.
4. Editor receives N independent reports and produces:
   - A **decision-distribution table** (e.g., `2/3 R&R, 1/3 Reject` with the modal verdict highlighted).
   - A **concern-frequency table** showing which concerns appeared across multiple referees (high frequency = robust criticism; low frequency = disposition-dependent).
   - An **editorial recommendation** that explicitly references the variance ("modal verdict R&R, with one SKEPTIC dissent on identification — author should address the identification concern even though it's not the majority position").

**Output files:**

- `quality_reports/peer_review_<paper>/referee_1.md` … `referee_N.md` (per-referee reports)
- `quality_reports/peer_review_<paper>/decision_distribution.md` (aggregate table + concern-frequency analysis)
- `quality_reports/peer_review_<paper>/editor_synthesis.md` (final editorial letter)

**Cost discipline.** Variance mode multiplies referee-tier cost by N relative to default `--peer` (which runs 2 referees). The Cost-Conscious Composition section of the workflow guide recommends keeping referees on a capable reviewer model for variance runs and reserving a stronger model for editor synthesis. Hard cap at N=5; for higher variance estimates, run `--variance 5` twice and combine offline.

**Mutual exclusivity.** Variance mode cannot combine with `--stress` (which forces SKEPTIC×2 and would defeat the sampling purpose) or `--r2`/`--r3` (which reuses prior-round dispositions for continuity). The skill halts with an error if mutually-exclusive flags are combined.

**When to reach for it:**

- Pre-submission dress rehearsal where you want to know not just "will this paper survive review" but "*how confidently* will it survive."
- Deciding between target journals — run `--variance 3` against two journal profiles, compare distributions.
- Responding to a rejection where the referee panel felt unrepresentative — `--variance 5` against the same journal profile gives an empirical sense of whether the original referees were typical.

---


## Steps (both modes)

1. **Locate and read the manuscript.** First strip flags (`--adversarial`, `--no-cross-artifact`) from `the arguments supplied with the invocation` to get the bare manuscript path. Check:
   - Direct path (bare path from step 1)
   - `master_supporting_docs/supporting_papers/the arguments supplied with the invocation`
   - Glob for partial matches

2. **Read the full paper** end-to-end with the Read tool — a 1M-token window holds a full paper. For long PDFs, page through with the `pages` parameter (up to 20 pages per request).

3. **Evaluate across 6 dimensions** (see below).

4. **Generate 3–5 "referee objections"** — the tough questions a top referee would ask.

5. **Produce the review report.**

6. **Save to** `quality_reports/paper_review_[sanitized_name]_round[N].md` (N=1 in default mode; N increments in adversarial mode).

6b. **Cross-artifact integration.** Unless `the arguments supplied with the invocation` contains `--no-cross-artifact`, and if the manuscript references analysis scripts (detected via `\input{scripts/...}`, `%% source:` comments, or matching `scripts/R/_outputs/` filenames), auto-invoke:
   - `$review-r` on each referenced script (forked subagent, results to `quality_reports/cross_artifact_[paper]/review_r_*.md`)
   - `$audit-reproducibility` on the manuscript + outputs dir (results to `quality_reports/cross_artifact_[paper]/reproducibility.md`)

   Merge critical cross-artifact findings (code bug invalidates paper claim, reproducibility FAIL) into a new "Cross-Artifact Findings" section at the top of the paper review report. See [`.codex/guidance/cross-artifact-review.md`](../../../.codex/guidance/cross-artifact-review.md) for the full protocol.

7. **If `--adversarial` is in `the arguments supplied with the invocation`:** invoke the critic-fixer loop defined in the next section. Otherwise stop here.

---

## Review Dimensions

### 1. Argument Structure
- Is the research question clearly stated?
- Does the introduction motivate the question effectively?
- Is the logical flow sound (question → method → results → conclusion)?
- Are the conclusions supported by the evidence?
- Are limitations acknowledged?

### 2. Identification Strategy
- Is the causal claim credible?
- What are the key identifying assumptions? Are they stated explicitly?
- Are there threats to identification (omitted variables, reverse causality, measurement error)?
- Are robustness checks adequate?
- Is the estimator appropriate for the research design?

### 3. Econometric Specification
- Correct standard errors (clustered? robust? bootstrap?)?
- Appropriate functional form?
- Sample selection issues?
- Multiple testing concerns?
- Are point estimates economically meaningful (not just statistically significant)?

### 4. Literature Positioning
- Are the key papers cited?
- Is prior work characterized accurately?
- Is the contribution clearly differentiated from existing work?
- Any missing citations that a referee would flag?

### 5. Writing Quality
- Clarity and concision
- Academic tone
- Consistent notation throughout
- Abstract effectively summarizes the paper
- Tables and figures are self-contained (clear labels, notes, sources)

### 6. Presentation
- Are tables and figures well-designed?
- Is notation consistent throughout?
- Are there any typos, grammatical errors, or formatting issues?
- Is the paper the right length for the contribution?

---

## Output Format

```markdown
# Manuscript Review: [Paper Title]

**Date:** [YYYY-MM-DD]
**Reviewer:** review-paper skill
**File:** [path to manuscript]

## Summary Assessment

**Overall recommendation:** [Strong Accept / Accept / Revise & Resubmit / Reject]

[2-3 paragraph summary: main contribution, strengths, and key concerns]

## Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

## Major Concerns

### MC1: [Title]
- **Dimension:** [Identification / Econometrics / Argument / Literature / Writing / Presentation]
- **Issue:** [Specific description]
- **Suggestion:** [How to address it]
- **Location:** [Section/page/table if applicable]

[Repeat for each major concern]

## Minor Concerns

### mc1: [Title]
- **Issue:** [Description]
- **Suggestion:** [Fix]

[Repeat]

## Referee Objections

These are the tough questions a top referee would likely raise:

### RO1: [Question]
**Why it matters:** [Why this could be fatal]
**How to address it:** [Suggested response or additional analysis]

[Repeat for 3-5 objections]

## Specific Comments

[Line-by-line or section-by-section comments, if any]

## Summary Statistics

| Dimension | Rating (1-5) |
|-----------|-------------|
| Argument Structure | [N] |
| Identification | [N] |
| Econometrics | [N] |
| Literature | [N] |
| Writing | [N] |
| Presentation | [N] |
| **Overall** | **[N]** |
```

---

## Principles

- **Be constructive.** Every criticism should come with a suggestion.
- **Be specific.** Reference exact sections, equations, tables.
- **Think like a referee at a top-5 journal.** What would make them reject?
- **Distinguish fatal flaws from minor issues.** Not everything is equally important.
- **Acknowledge what's done well.** Good research deserves recognition.
- **Do NOT fabricate details.** If you can't read a section clearly, say so.

---

## Adversarial Mode — Critic-Fixer Loop

**Only runs if `--adversarial` is in `the arguments supplied with the invocation`.**

Use a bounded critic-fixer loop so authors do not have to perform manual fix-and-resubmit cycles. Papers get it now because the single-pass review leaves authors doing manual fix-and-resubmit cycles.

### Flow

```
Phase 0: Pre-flight
  │
  ├─ Verify the manuscript compiles (xelatex / Markdown render) if applicable
  ├─ Snapshot the pre-review version: git stash OR copy to a .review-backup/
  │
Phase 1: Critic audit (round N=1,2,3,...)
  │
  ├─ Run the default review above, producing a round-N report
  ├─ If the report has ZERO Major Concerns and ZERO Referee Objections
  │  rated "fatal":
  │     → VERDICT = APPROVED. Stop the loop. Write final summary.
  │  Else: continue.
  │
Phase 2: Fixer
  │
  ├─ For each Major Concern in the round-N report, produce a concrete
  │  proposed edit (diff or new text block).
  ├─ Present proposed edits to the user grouped by severity (Critical →
  │  Major → Minor). Ask for approval: "apply all", "apply critical+major
  │  only", "review each", or "abort".
  ├─ Apply approved edits with Edit / Edit tools.
  ├─ If the manuscript is a compile target (`.tex` / `.md`), re-compile
  │  and verify it still builds.
  │
Phase 3: Re-audit
  │
  └─ Spawn a FRESH-CONTEXT subagent (as a subagent, `subagent_type` set to
     general-purpose) to re-read the paper and produce a round-(N+1)
     report. Fresh context prevents anchoring bias — the new reviewer
     sees the edited paper, not the diff.
     → Jump back to Phase 1.
```

### Iteration limits — loop-until-dry

Use the **loop-until-dry** primitive ([`orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md)): the critic returns `FINDING`s in the shared schema ([`orchestration-schemas.md`](../../../.codex/references/orchestration-schemas.md)) and the loop **converges when a round adds 0 new CRITICAL/MAJOR concerns** (deduped on `id = sha1(file:line:locus)`), not at a fixed count.

- **Convergence:** APPROVED when a round produces zero Major Concerns and zero fatal Referee Objections.
- **Fallback cap:** 5 rounds bounds a non-converging loop; after round 5, halt and list remaining concerns.
- **Two-strikes:** if the same Concern label appears in rounds N and N+2, flag as "author disagreement" and let the user decide (keep-as-is with rationale vs. another fix attempt) — see [`summary-parity.md`](../../../.codex/guidance/summary-parity.md).
- **Budget escape:** if cumulative token cost exceeds the spend cap (default ~500k — a spend ceiling, not a context-window limit, since each re-audit runs in fresh context), warn and let the user cap further rounds.

### Stopping criteria

| Condition | Action |
|---|---|
| Zero Major Concerns, zero fatal Referee Objections | APPROVED — final summary |
| Max 5 rounds reached | HALTED — list remaining concerns, user decides |
| User approves zero fixes in a round | HALTED — user signals "I disagree with this review" |
| Compile fails after applied fixes | ROLLED BACK to pre-round-N snapshot, report compile error, user decides |

### Final report

After the loop ends, write `quality_reports/paper_review_[sanitized_name]_FINAL.md`:

```markdown
# Final Review: [Paper Title]

**Rounds:** N
**Verdict:** APPROVED | HALTED (max rounds) | HALTED (user override) | ROLLED BACK
**Token cost estimate:** ~XXk

## Round Summary
| Round | Major Concerns | Fatal Objections | Status |
|---|---|---|---|
| 1 | 7 | 2 | Fixed 5, deferred 2 |
| 2 | 3 | 1 | ...              |
| ... | ... | ... | ...         |
| N | 0 | 0 | APPROVED        |

## Changes Applied
[link to git diff between the pre-round-1 snapshot and HEAD]

## Remaining Concerns (if HALTED)
[list with severity + rationale]

## Next Steps
[recommended action: submit / one more pass / substantial revision]
```

### When NOT to use adversarial mode

- Early exploratory drafts (the loop forces premature polish on ideas still being shaped)
- Papers you don't yet have compilable source for (can't verify edits)
- When you'd rather get ONE opinion and decide for yourself (adversarial-mode enforces "critic signed off" semantics — that's sometimes the wrong frame)

---

## `--peer [journal]` workflow detail

### Phase 0: Cross-artifact pre-flight (runs BEFORE desk review in --peer mode)

Unless `--no-cross-artifact` is set, auto-invoke `$audit-reproducibility` on the manuscript + its outputs directory *first*. Any reproducibility FAIL becomes desk-reject-worthy evidence the editor can cite. See `.codex/guidance/cross-artifact-review.md`.

Reports: `quality_reports/cross_artifact_[paper]/reproducibility.md`.

**Novelty-probe Post-Flight (new in v1.7.0).** The editor's novelty probe uses `web search` to check whether the paper's contribution has been made before. web search results can be hallucinated — fabricated prior work, misattributed findings, wrong years. Before the editor's desk review incorporates novelty-probe claims into its decision, those claims must pass Post-Flight Verification per [`.codex/guidance/post-flight-verification.md`](../../../.codex/guidance/post-flight-verification.md):

1. The editor collects novelty-probe claims (e.g., "Smith 2022 already showed this exact result").
2. Spawn `claim-verifier` as a `claim-verifier` subagent and `context=fork`, passing the claims + verification questions + candidate source URLs. Forked fresh context is the CoVe independence trick.
3. Only verified claims are allowed into the desk-review narrative. Unverified claims are surfaced separately as "editor could not verify — manual check recommended" rather than presented as established prior work.

Opt-out: `--no-novelty-check` already skips the probe entirely. If the probe runs, Post-Flight is mandatory.

**Pre-Flight Report (required before Phase 1).** This is the `RUN_CONFIG` echo from [`orchestrator-protocol.md`](../../../.codex/guidance/orchestrator-protocol.md) — every interactive choice (journal, dispositions, peeve budget, N referees, cross-artifact/novelty toggles, round) is resolved **before** the forked editor/referees spawn, because a forked subagent cannot stop to ask. Output it so the user can verify inputs, and halt here on any unresolved required field (unknown journal, missing script) rather than mid-run:

```markdown
## Pre-Flight Report — $review-paper --peer

**Manuscript:** [path] — [page count, last modified]
**Target journal:** [JOURNAL_SHORT] → [full name from `.codex/references/journal-profiles.md`]
**Journal profile loaded:** [yes/no; resolved from `.codex/references/journal-profiles.md`; key adjustments: e.g., "Identification 35 → 40"]
**Cross-artifact scripts found:** [list referenced .R / .py files]
**Reproducibility status:** [PASS / FAIL from Phase 0] — [N of M claims within tolerance]
**Round:** [fresh / r2 / r3 / stress]
```

If the manuscript path doesn't exist, the target journal isn't in `.codex/references/journal-profiles.md`, or a cross-artifact script is missing, stop and surface the issue before proceeding.

### Phase 1: Editor desk review

Spawn forked subagent `editor` with the manuscript path and `--peer <JOURNAL>` context. Editor:
- Reads journal profile from `.codex/references/journal-profiles.md` → states "Calibrated to: [journal]".
- Reads abstract + intro + methods overview + headline results.
- Runs novelty probes (unless `--no-novelty-check`).
- Either **DESK REJECT** (pipeline terminates with rejection letter) or **SEND OUT**.

Report: `quality_reports/peer_review_[paper]/desk_review.md`.

### Phase 1b: Referee selection (inside editor)

Editor draws 2 DIFFERENT dispositions from journal's Referee-pool weights and assigns each referee 1 critical + 1 constructive peeve (stress mode: 2 critical + 1 constructive). Appended to `desk_review.md`.

### Phase 2: Two parallel referees, blind to each other

Spawn in parallel:
- Forked subagent `domain-referee` with disposition D1, peeves P1 → `referee_domain.md`.
- Forked subagent `methods-referee` with disposition D2, peeves P2 → `referee_methods.md`.

Each referee must include "What would change my mind: [specific ask]" on every MAJOR concern.

### Phase 3: Editor synthesis (reduce → judge, with the hallucination gate)

Read both referee reports. **Reduce** their `FINDING`s, classify each MAJOR concern as FATAL / ADDRESSABLE / TASTE, and produce the editorial decision using the decision rule table in `editor.md`.

**Post-judge hallucination gate** ([`orchestration-schemas.md` §4](../../../.codex/references/orchestration-schemas.md)): the editor reduces the referees — it must not desk-reject or escalate on a CRITICAL reason **neither referee raised**. Any editor-introduced blocker that is not traceable to a referee finding is re-verified in a fresh `claim-verifier` fork or dropped to `[JUDGE-HALLUCINATED]` and the decision recomputed. (The editor may always downgrade or de-duplicate referee concerns.)

Report: `quality_reports/peer_review_[paper]/editorial_decision.md`.

### Phase 4: Summary

Tell the user:
- Final decision (Accept / Minor / Major / Reject / Desk Reject)
- Token usage + wall-clock time
- Paths to all 4 reports (desk_review, referee_domain, referee_methods, editorial_decision)

---

## Output layout for `--peer` mode

```
quality_reports/
  peer_review_[sanitized_paper_name]/
    desk_review.md                       # Phase 1 + Phase 1b
    referee_domain.md                    # Phase 2 (parallel)
    referee_methods.md                   # Phase 2 (parallel)
    editorial_decision.md                # Phase 3
    (R&R rounds: desk_review_r2.md, referee_domain_r2.md, ...)
  cross_artifact_[sanitized_paper_name]/
    reproducibility.md                   # Phase 0
    review_r_*.md                        # Phase 0 (one per referenced script)
```

---

## Field adaptation

The shipped `journal-profiles.md` covers 5 econ journals (AER, QJE, JPE, ECMA, ReStud) plus 3 political-science journals (APSR, AJPS, JOP). For other fields (finance, biology, CS, etc.), copy `templates/journal-profile-template.md` into a new section of `journal-profiles.md` and fill in the schema. See the "Field adaptation" section at the end of `journal-profiles.md` for detailed guidance. The pipeline itself is field-agnostic; only the calibration data changes.

For non-econ paper types in `methods-referee.md`, extend the paper-type list (e.g., biology: `observational / experimental / computational / review`).


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

- [`.agents/skills/audit-reproducibility/SKILL.md`](../audit-reproducibility/SKILL.md) — numeric-claim verification (auto-invoked on referenced scripts).
- [`.agents/skills/replication-package/SKILL.md`](../replication-package/SKILL.md) — assemble the AEA DCAS deposit once the paper passes review.
- [`.agents/skills/capture-environment/SKILL.md`](../capture-environment/SKILL.md) · [`.agents/skills/disclosure-check/SKILL.md`](../disclosure-check/SKILL.md) — environment capture + restricted-data screening for the deposit.
- [`.agents/skills/seven-pass-review/SKILL.md`](../seven-pass-review/SKILL.md) — heavier 7-lens pass for submission-ready drafts.


