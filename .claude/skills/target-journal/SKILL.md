---
name: target-journal
description: Journal targeting dispatching the Editor agent in journal-selection mode. Analyzes paper fit, suggests ranked journal list from domain-profile.md tiers, provides formatting requirements and submission strategy.
disable-model-invocation: true
argument-hint: "[paper path or abstract]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch", "Task"]
---

# Target Journal

Analyze a paper and recommend journals for submission by dispatching the **Editor** agent in journal-selection mode.

**Input:** `$ARGUMENTS` — path to paper `.tex` file, or a text abstract/summary.

---

## Workflow

### Step 1: Context Gathering

1. Read the paper (or abstract) from `$ARGUMENTS`
2. Read `.claude/rules/domain-profile.md` for field-specific journal tiers
3. Read any existing referee reports or editorial decisions in `quality_reports/`

### Step 2: Launch Editor Agent (Journal-Selection Mode)

Delegate to the `editor` agent via Task tool:

```
Prompt: Analyze [paper] for journal targeting.
Mode: Journal selection (Phase 4 of editor lifecycle).
Extract: topic, contribution type, identification strategy, scope, data type, novelty level.
Using domain-profile.md journal tiers, recommend 5-8 journals in 3 tiers.
For top 3 recommendations: provide formatting requirements.
Save to quality_reports/journal_targeting_[date].md
```

### Step 3: Journal Recommendations (3 Tiers)

**Tier 1: Reach Journals**
- Top-5 general interest (if contribution warrants)
- For each: why it fits, recent similar publications, desk rejection risk

**Tier 2: Strong Field Journals**
- From domain-profile.md field journal list
- Match to paper's specific sub-field

**Tier 3: Solid Alternatives**
- JEEA, JAE, Economics Letters, specialized journals

### Step 4: Formatting Requirements

For the top 3 recommended journals:

| Requirement | Details |
|-------------|---------|
| Word/page limit | |
| Abstract limit | |
| Citation style | |
| LaTeX class | |
| Figure format | |
| Data availability | |
| Submission portal | |
| Typical turnaround | |
| Double-blind | |

### Step 5: Submission Checklist

Generate checklist for top journal choice:
- Manuscript formatting
- Cover letter (addressed to current editor)
- JEL codes and keywords
- Data availability statement
- Replication package
- Suggested/excluded referees

### Step 6: Strategic Notes

- **Desk rejection risk** — honest assessment
- **Suggested referees** — 3-5 names with expertise match
- **Timing considerations** — deadlines, conference cycles
- **Competing papers** — recent working papers on same topic
- **Resubmission strategy** — if rejected from Tier 1, which Tier 2 journal next?

### Step 7: Save and Present

Save to `quality_reports/journal_targeting_[date].md`

---

## Principles

- **Be honest about fit.** Don't suggest AER for every paper.
- **Domain-profile aware.** Use the field-specific journal tiers, not generic lists.
- **Recent publications matter.** Check if the journal recently published on the topic.
- **Don't over-optimize.** The best journal is one that publishes the paper.
- **Formatting details change.** Flag any uncertain requirements.
