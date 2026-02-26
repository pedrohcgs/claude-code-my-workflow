---
name: review-paper
description: Full manuscript review dispatching 2 blind Referee agents and the Editor agent for editorial decision. Produces referee reports and accept/revise/reject recommendation. Use when asked to "review the paper", "get feedback", or "simulate peer review".
disable-model-invocation: true
argument-hint: "[paper .tex path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Paper

Simulate peer review by dispatching two **Referee** agents (blind reviewers) and the **Editor** agent (editorial decision).

**Input:** `$ARGUMENTS` — path to paper `.tex` file. Defaults to `Paper/main.tex`.

---

## Workflow

### Step 1: Context Gathering

1. Read the paper from `$ARGUMENTS` or `Paper/main.tex`
2. Read `.claude/rules/domain-profile.md` for field context and target journals
3. Read `Bibliography_base.bib` for citation verification
4. Check if a strategy memo exists in `quality_reports/`

### Step 2: Launch Referee Agents (Parallel)

Launch 2 Referee agents simultaneously via Task tool, each with different focus:

**Referee 1** (subagent_type: general-purpose, with referee instructions)
```
You are Referee 1 for a blind peer review. Review [paper.tex].
Score across 5 dimensions:
  - Contribution (25%): novelty, importance, gap filled
  - Identification (30%): design validity, assumptions, threats
  - Data (20%): quality, appropriateness, sample construction
  - Writing (15%): clarity, structure, notation
  - Journal Fit (10%): appropriate for [target journal from domain-profile]
Provide: summary, detailed comments, recommendation (Accept/Minor/Major/Reject).
Save to quality_reports/referee_1_report.md
```

**Referee 2** (subagent_type: general-purpose, with referee instructions)
```
You are Referee 2 for a blind peer review. Review [paper.tex].
Same 5-dimension scoring as Referee 1 but independently.
Focus especially on: [alternative concern area — e.g., external validity,
  robustness, alternative explanations].
Save to quality_reports/referee_2_report.md
```

### Step 3: Launch Editor Agent

After both Referees return, delegate to the `editor` agent:

```
Prompt: You are the Editor reviewing [paper.tex].
Read both referee reports:
  - quality_reports/referee_1_report.md
  - quality_reports/referee_2_report.md
Make editorial decision:
  - Weigh referee recommendations
  - Add your own assessment of contribution and fit
  - Identify areas of agreement and disagreement between referees
  - Make recommendation: Accept / Minor Revision / Major Revision / Reject
  - If revision: specify which referee points are mandatory vs optional
Save to quality_reports/editorial_decision.md
```

### Step 4: Present Results

```markdown
# Peer Review Report: [Paper Title]
**Date:** [YYYY-MM-DD]
**Target Journal:** [from domain-profile]

## Editorial Decision: [Accept / Minor / Major / Reject]

## Referee 1 Summary
- **Overall score:** XX/100
- **Recommendation:** [Accept/Minor/Major/Reject]
- **Key strengths:** [2-3 points]
- **Key concerns:** [2-3 points]

## Referee 2 Summary
- **Overall score:** XX/100
- **Recommendation:** [Accept/Minor/Major/Reject]
- **Key strengths:** [2-3 points]
- **Key concerns:** [2-3 points]

## Editor's Assessment
- **Referee agreement:** [Where they agree, where they disagree]
- **Mandatory revisions:** [List — must address]
- **Optional improvements:** [List — would strengthen]

## Full Reports
- Referee 1: quality_reports/referee_1_report.md
- Referee 2: quality_reports/referee_2_report.md
- Editor: quality_reports/editorial_decision.md
```

---

## Principles

- **Independence.** Referees do not see each other's reports. Run in parallel.
- **Constructive criticism.** The goal is to improve the paper, not tear it down.
- **Specific feedback.** Every concern must cite exact sections, equations, or tables.
- **Calibrated severity.** Working papers get developmental feedback. Submission-ready papers get referee-level scrutiny.
- **Editor synthesizes.** The Editor resolves referee disagreements and prioritizes revisions.
