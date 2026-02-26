---
name: lit-review
description: Structured literature search dispatching the Librarian agent for collection and Editor agent for coverage critique. Searches top-5 journals, NBER/SSRN, and field journals. Produces synthesis with gap identification and BibTeX entries.
disable-model-invocation: true
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch", "Task"]
---

# Literature Review

Conduct a structured literature search and synthesis by dispatching the **Librarian** (collector) and **Editor** (critic).

**Input:** `$ARGUMENTS` — a topic, paper title, research question, or phenomenon to investigate.

---

## Workflow

### Step 1: Context Gathering

1. Parse the topic from `$ARGUMENTS`
2. Read `.claude/rules/domain-profile.md` for field-specific journal tiers and seminal references
3. Check `master_supporting_docs/` for uploaded papers
4. Read `Bibliography_base.bib` for papers already in the project

### Step 2: Launch Librarian Agent

Delegate to the `librarian` agent via Task tool:

```
Prompt: Search for literature on "[topic]".
Search protocol:
  1. Top-5 journals (AER, Econometrica, QJE, JPE, REStud)
  2. Field journals from domain-profile.md
  3. NBER/SSRN/IZA working papers
  4. Citation chains (forward + backward from key papers)
Assign proximity scores (1-5) to each paper found.
Produce annotated bibliography with BibTeX entries.
Save to quality_reports/lit_review_[sanitized_topic].md
```

### Step 3: Launch Editor Agent (Lit Critic Mode)

After Librarian returns, delegate to the `editor` agent:

```
Prompt: Review the literature collection at quality_reports/lit_review_[topic].md.
Mode: Literature critic (Phase 1).
Check for:
  - Coverage gaps (missing seminal papers, missing strands)
  - Journal quality distribution (too many working papers?)
  - Scope appropriateness (too broad or too narrow?)
  - Missing methodological context
Flag gaps for Librarian to fill.
```

### Step 4: Fill Gaps (if needed)

If Editor identifies gaps:
1. Re-dispatch Librarian for targeted searches (max 1 round)
2. Merge new findings into the report

### Step 5: Present Results

```markdown
# Literature Review: [Topic]
**Date:** [YYYY-MM-DD]
**Query:** [Original query]

## Summary
[2-3 paragraph overview of the state of the literature]

## Key Papers
### [Author (Year)] — [Short Title]
- **Journal:** [venue]
- **Proximity:** [1-5 score]
- **Main contribution:** [1-2 sentences]
- **Identification strategy:** [DiD / IV / RDD / SC / descriptive]
- **Key finding:** [result with effect size]
- **Relevance:** [why it matters for our research]

## Thematic Organization
### Theoretical Contributions
### Empirical Findings
### Methodological Innovations

## Gaps and Opportunities
1. [Gap 1 — what's missing and why it matters]
2. [Gap 2]

## Research Frontier
### Active Debates
### Recent Working Papers to Watch
### Emerging Methods

## Suggested Next Steps

## BibTeX Entries
```bibtex
@article{...}
```
```

---

## Principles

- **Be honest about uncertainty.** If you cannot verify a citation, mark as `% UNVERIFIED`.
- **Prioritize published work** over working papers. Note publication status.
- **Note when WPs became published** — cite the published version.
- **Do NOT fabricate citations.** Flag any uncertain details.
- **Identification strategy is key.** Always note how each paper identifies effects.
- **Effect sizes matter.** Report magnitudes, not just signs.
- **Proximity scoring:** 1 = directly competes, 5 = tangentially related.
