---
name: lit-review
description: Structured economics literature search and synthesis with citation extraction, gap identification, and research frontier mapping. Prioritizes top-5 journals, NBER working papers, and field journals.
disable-model-invocation: true
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch"]
---

# Literature Review

Conduct a structured literature search and synthesis on the given topic, optimized for applied economics research.

**Input:** `$ARGUMENTS` — a topic, paper title, research question, or phenomenon to investigate.

---

## Steps

1. **Parse the topic** from `$ARGUMENTS`. If a specific paper is named, use it as the anchor.

2. **Search for related work** using available tools:
   - Check `master_supporting_docs/` for uploaded papers
   - Read `Bibliography_base.bib` for papers already in the project
   - Use `WebSearch` to find recent publications, targeting:
     - **Top-5 general:** AER, Econometrica, QJE, JPE, REStud
     - **Top field:** AEJ:Applied, AEJ:Policy, AEJ:Micro, RESTAT, JoE, Journal of Labor Economics, Journal of Public Economics, Journal of Development Economics
     - **Working papers:** NBER Working Papers, SSRN Economics, IZA Discussion Papers, CEPR
     - **Methodological:** Journal of Econometrics, Journal of Business & Economic Statistics, Econometric Theory
   - Use `WebFetch` to access specific paper abstracts when URLs are found

3. **Organize findings** into these categories:
   - **Theoretical contributions** — models, frameworks, mechanisms
   - **Empirical findings** — key results, effect sizes, data sources used
   - **Methodological innovations** — new estimators, identification strategies, inference methods
   - **Open debates** — unresolved disagreements in the literature
   - **Methodological context** — which identification strategies dominate this literature? DiD, IV, RDD? Are there known concerns about standard approaches?

4. **Identify gaps and opportunities:**
   - What questions remain unanswered?
   - What data or methods could address them?
   - Where do findings conflict?
   - What identification strategies haven't been tried?

5. **Extract citations** in BibTeX format for all papers discussed:
   - For NBER papers: use standard NBER BibTeX format with WP number
   - For published papers: include DOI when available
   - Mark working papers clearly: `note = {NBER Working Paper No. XXXXX}`
   - If a working paper has been published since: cite the **published version**
   - **CRITICAL: Flag unverified citations.** If you cannot confirm author list, year, or journal, mark as `% UNVERIFIED — please confirm`

6. **Save the report** to `quality_reports/lit_review_[sanitized_topic].md`

---

## Output Format

```markdown
# Literature Review: [Topic]

**Date:** [YYYY-MM-DD]
**Query:** [Original query from user]

## Summary

[2-3 paragraph overview of the state of the literature]

## Key Papers

### [Author (Year)] — [Short Title]
- **Journal:** [Publication venue or "NBER WP No. XXXX"]
- **Main contribution:** [1-2 sentences]
- **Identification strategy:** [DiD / IV / RDD / SC / structural / descriptive]
- **Key finding:** [Result with effect size if available]
- **Relevance:** [Why it matters for our research]

[Repeat for 5-15 papers, ordered by relevance]

## Thematic Organization

### Theoretical Contributions
[Grouped discussion]

### Empirical Findings
[Grouped discussion with comparison across studies — note conflicting results]

### Methodological Innovations
[Methods relevant to the topic]

## Gaps and Opportunities

1. [Gap 1 — what's missing and why it matters]
2. [Gap 2]
3. [Gap 3]

## Research Frontier

### Active Debates
[Ongoing unresolved methodological or empirical debates in this literature]

### Recent Working Papers to Watch
[3-5 recent working papers that may shift the literature — with brief note on why]

### Emerging Methods
[New econometric approaches being applied to this topic]

## Suggested Next Steps

- [Concrete actions: papers to read in full, data to obtain, methods to consider]

## BibTeX Entries

```bibtex
@article{...}
```
```

---

## Principles

- **Be honest about uncertainty.** If you cannot verify a citation, say so explicitly.
- **Prioritize published work in top journals** over general working papers. Note publication status.
- **Note when WPs became published** — the published version may differ substantively.
- **Do NOT fabricate citations.** If you're unsure about a paper's details, flag it for the user to verify.
- **Prioritize recent work** (last 5-10 years) unless seminal papers are older.
- **For economics literature:** Identification strategy is a key organizing dimension. Always note how each paper identifies its causal effect (or whether it's descriptive).
- **Effect sizes matter.** Report magnitudes, not just signs and significance.
