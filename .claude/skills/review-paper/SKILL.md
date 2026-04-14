---
name: review-paper
description: Comprehensive manuscript review with three modes: single-pass (default), --adversarial critic-fixer loop, and --peer [journal] simulated peer-review pipeline (editor + 2 dispositioned referees + editorial decision, calibrated to a target journal). R&R continuation via --peer --r2/--r3; hostile-editor stress test via --peer --stress. Auto-invokes /review-r + /audit-reproducibility on referenced scripts unless --no-cross-artifact.
argument-hint: "[paper path] [--adversarial | --peer <journal> [--r2 | --r3 | --stress] [--no-novelty-check]] [--no-cross-artifact]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Manuscript Review

Produce a thorough, constructive review of an academic manuscript — the kind of report a top-journal referee would write.

**Input:** `$ARGUMENTS` — path to a paper (`.tex`, `.pdf`, or `.qmd`), or a filename in `master_supporting_docs/`. Optional flags:

- `--adversarial` — critic-fixer loop (max 5 rounds).
- `--peer <JOURNAL>` — simulated peer review pipeline calibrated to `<JOURNAL>` (see `.claude/references/journal-profiles.md` for available short names).
- `--r2` / `--r3` — R&R continuation mode (requires `--peer`). Reloads prior round, classifies concerns Resolved / Partial / Not addressed.
- `--stress` — hostile-editor stress test (requires `--peer`). Forces SKEPTIC dispositions, doubles critical peeves.
- `--no-novelty-check` — skip editor's WebSearch novelty probe (default is ON).
- `--no-cross-artifact` — skip auto-invocation of `/review-r` + `/audit-reproducibility` on referenced scripts.

> **Already received referee comments?** Use [`/respond-to-referees`](../respond-to-referees/SKILL.md) instead. That skill cross-references each referee concern against the revised manuscript and drafts a complete response document.

---

## Modes

### Default mode (single-pass)

One comprehensive review report. Fast, low token cost, suitable for early drafts where the author wants feedback and will iterate manually.

### Adversarial mode (`--adversarial`)

Iterative critic-fixer loop modeled on [`/qa-quarto`](../qa-quarto/SKILL.md). The critic identifies issues, the fixer proposes and applies edits (with user approval), and the critic re-audits. Loops until APPROVED or max 5 rounds.

Use when: preparing a pre-submission draft, responding to a journal-desk rejection with substantive revisions, or after your own major rewrite. Costs more tokens but produces a manuscript the critic has signed off on.

### Peer-review mode (`--peer <JOURNAL>`)

Simulated editorial pipeline: **editor desk review → referee selection → 2 blind referees with different dispositions → editorial synthesis**. Calibrated to a target journal from `.claude/references/journal-profiles.md`. Use when: pre-submission dress rehearsal, choosing between target journals, R&R planning.

This mode is materially different from `--adversarial`: adversarial runs the same critic 5× with fresh context; `--peer` runs **different personas** (editor + 2 dispositioned referees drawn from 6-way taxonomy: STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC) whose priors are *deliberately different* and who are blind to each other.

**Agents used** (all reimplemented in this template; adapted from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with permission):

- `.claude/agents/editor.md` — editor (desk review, referee selection, synthesis).
- `.claude/agents/domain-referee.md` — substance referee.
- `.claude/agents/methods-referee.md` — methodology referee (paper-type-aware).

**Sub-flags:**

- `--r2` / `--r3` — R&R mode. Skips fresh desk review; reloads prior round's reports; same referees + dispositions + peeves; classifies each prior concern as Resolved / Partial / Not addressed. Hard cap at `--r3` (no round 4+).
- `--stress` — Hostile editor. Forces both referees to SKEPTIC disposition, doubles critical peeves, framing: "you are looking for reasons to reject this paper." Output is a concern-list gauntlet, not a decision letter.
- `--no-novelty-check` — Disables the editor's WebSearch novelty probes (default is ON). Use in offline or hallucination-sensitive contexts. **Novelty-check caveat (document this to users):** WebSearch can return hallucinated citations or miss paywalled recent work. Always surface novelty-probe results as flags for manual verification, not verdicts.

---


## Steps (both modes)

1. **Locate and read the manuscript.** First strip flags (`--adversarial`, `--no-cross-artifact`) from `$ARGUMENTS` to get the bare manuscript path. Check:
   - Direct path (bare path from step 1)
   - `master_supporting_docs/supporting_papers/$ARGUMENTS`
   - Glob for partial matches

2. **Read the full paper** end-to-end. For long PDFs, read in chunks (5 pages at a time).

3. **Evaluate across 6 dimensions** (see below).

4. **Generate 3–5 "referee objections"** — the tough questions a top referee would ask.

5. **Produce the review report.**

6. **Save to** `quality_reports/paper_review_[sanitized_name]_round[N].md` (N=1 in default mode; N increments in adversarial mode).

6b. **Cross-artifact integration.** Unless `$ARGUMENTS` contains `--no-cross-artifact`, and if the manuscript references analysis scripts (detected via `\input{scripts/...}`, `%% source:` comments, or matching `scripts/R/_outputs/` filenames), auto-invoke:
   - `/review-r` on each referenced script (forked subagent, results to `quality_reports/cross_artifact_[paper]/review_r_*.md`)
   - `/audit-reproducibility` on the manuscript + outputs dir (results to `quality_reports/cross_artifact_[paper]/reproducibility.md`)

   Merge critical cross-artifact findings (code bug invalidates paper claim, reproducibility FAIL) into a new "Cross-Artifact Findings" section at the top of the paper review report. See [`.claude/rules/cross-artifact-review.md`](../../rules/cross-artifact-review.md) for the full protocol.

7. **If `--adversarial` is in `$ARGUMENTS`:** invoke the critic-fixer loop defined in the next section. Otherwise stop here.

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

**Only runs if `--adversarial` is in `$ARGUMENTS`.**

Pattern adapted from [`/qa-quarto`](../qa-quarto/SKILL.md), which uses the same loop to iterate on slide quality. Papers get it now because the single-pass review leaves authors doing manual fix-and-resubmit cycles.

### Flow

```
Phase 0: Pre-flight
  │
  ├─ Verify the manuscript compiles (xelatex / quarto render) if applicable
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
  ├─ If the manuscript is a compile target (`.tex` / `.qmd`), re-compile
  │  and verify it still builds.
  │
Phase 3: Re-audit
  │
  └─ Spawn a FRESH-CONTEXT subagent (via Task, `subagent_type` set to
     general-purpose) to re-read the paper and produce a round-(N+1)
     report. Fresh context prevents anchoring bias — the new reviewer
     sees the edited paper, not the diff.
     → Jump back to Phase 1.
```

### Iteration limits

- **Max 5 rounds.** After round 5, halt regardless of verdict.
- **Fix round limits:** if the same Concern label appears in rounds N and N+2, flag as "author disagreement" and let the user decide (keep-as-is with rationale vs. another fix attempt).
- **Budget escape:** if token cost across all rounds exceeds ~200k, warn and let the user cap further rounds.

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

Unless `--no-cross-artifact` is set, auto-invoke `/audit-reproducibility` on the manuscript + its outputs directory *first*. Any reproducibility FAIL becomes desk-reject-worthy evidence the editor can cite. See `.claude/rules/cross-artifact-review.md`.

Reports: `quality_reports/cross_artifact_[paper]/reproducibility.md`.

### Phase 1: Editor desk review

Spawn forked subagent `editor` with the manuscript path and `--peer <JOURNAL>` context. Editor:
- Reads journal profile from `.claude/references/journal-profiles.md` → states "Calibrated to: [journal]".
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

### Phase 3: Editor synthesis

Read both referee reports. Classify each MAJOR concern as FATAL / ADDRESSABLE / TASTE. Produce editorial decision using the decision rule table in `editor.md`.

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

The shipped `journal-profiles.md` covers 5 econ journals (AER, QJE, JPE, ECMA, ReStud). For other fields (finance, political science, biology, CS, etc.), copy `templates/journal-profile-template.md` into a new section of `journal-profiles.md` and fill in the schema. See the "Field adaptation" section at the end of `journal-profiles.md` for detailed guidance. The pipeline itself is field-agnostic; only the calibration data changes.

For non-econ paper types in `methods-referee.md`, extend the paper-type list (e.g., biology: `observational / experimental / computational / review`).

