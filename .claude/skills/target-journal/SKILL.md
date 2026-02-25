---
name: target-journal
description: Journal targeting and submission strategy for economics papers. Analyzes paper fit, suggests ranked journal list, provides formatting requirements and submission checklists. Use when asked to "target a journal", "where should I submit", or "prepare for submission".
disable-model-invocation: true
argument-hint: "[paper path or abstract]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch"]
---

# Target Journal

Analyze a paper and recommend journals for submission with formatting requirements and strategy.

**Input:** `$ARGUMENTS` — path to paper `.tex` file, or a text abstract/summary.

---

## Step 1: Analyze the Paper

Read the paper (or abstract) and extract:
- **Topic/field:** (labor, public, development, IO, macro, trade, health, finance, etc.)
- **Contribution type:** (new empirical fact, new method, new data, policy evaluation, replication)
- **Identification strategy:** (DiD, IV, RDD, SC, structural, descriptive)
- **Scope:** (country-specific, cross-country, theoretical + empirical)
- **Data type:** (administrative, survey, experimental, simulated)
- **Novelty level:** (incremental, significant, paradigm-shifting)

---

## Step 2: Suggest Journals (Ranked)

Provide 5-8 journal suggestions in three tiers:

### Tier 1: Reach Journals
Top-5 general interest (if the contribution warrants):
- **American Economic Review** — broad appeal, strong identification, policy relevance
- **Econometrica** — methodological contribution, formal theory
- **Quarterly Journal of Economics** — big questions, clean identification
- **Journal of Political Economy** — deep economics, ambitious scope
- **Review of Economic Studies** — technical rigor, novel approach

For each suggested journal, explain:
- Why this paper fits (or doesn't)
- Recent similar publications (use WebSearch if available)
- Desk rejection risk factors

### Tier 2: Strong Field Journals
Match to the paper's field:
- Labor: **Journal of Labor Economics**, **Labour Economics**
- Public: **Journal of Public Economics**, **National Tax Journal**
- Development: **Journal of Development Economics**, **World Bank Economic Review**
- Health: **Journal of Health Economics**, **American Journal of Health Economics**
- Applied micro (general): **AEJ: Applied Economics**, **AEJ: Economic Policy**, **AEJ: Microeconomics**
- Econometrics/methods: **Journal of Econometrics**, **JBES**, **Econometric Theory**
- Trade: **Journal of International Economics**
- IO: **RAND Journal of Economics**, **Journal of Industrial Economics**
- General field: **Review of Economics and Statistics**, **Economic Journal**

### Tier 3: Solid Alternatives
- **Journal of the European Economic Association**
- **Journal of Applied Econometrics** (if methods-heavy)
- **Economics Letters** (if short, focused result)
- Specialized journals in the exact sub-field

---

## Step 3: Formatting Requirements

For the top 3 recommended journals, provide:

```markdown
### [Journal Name]

| Requirement | Details |
|-------------|---------|
| Word/page limit | [X words / X pages] |
| Abstract limit | [X words] |
| Citation style | [Author-year / numbered] |
| LaTeX class | [article / specific class if required] |
| Figure format | [PDF / EPS / high-res PNG] |
| Supplementary materials | [Online appendix policy] |
| Data availability | [Required / Recommended / Not required] |
| Submission portal | [ScholarOne / Editorial Express / etc.] |
| Typical turnaround | [X months for first decision] |
| Double-blind | [Yes / No] |
```

---

## Step 4: Submission Checklist

```markdown
## Submission Checklist for [Top Journal Choice]

### Manuscript
- [ ] Title page with all authors, affiliations, contact info
- [ ] Abstract within word limit
- [ ] JEL codes (2-3 relevant codes)
- [ ] Keywords (3-5)
- [ ] Manuscript formatted per journal guidelines
- [ ] All figures and tables numbered sequentially
- [ ] References complete and formatted correctly

### Cover Letter
- [ ] Addressed to current editor(s)
- [ ] 1 paragraph: what the paper does and why it matters
- [ ] 1 paragraph: why this journal (connect to recent publications)
- [ ] 1 paragraph: confirmation of originality, no simultaneous submission
- [ ] List of suggested referees (3-5, with emails)
- [ ] List of excluded referees (if any, with brief justification)

### Data and Code
- [ ] Data availability statement in manuscript
- [ ] Replication package prepared (use `/data-deposit`)
- [ ] README in package (use `/audit-replication` to verify)

### Supplementary Materials
- [ ] Online appendix formatted separately
- [ ] Appendix figures/tables numbered A.1, A.2, etc.
- [ ] All appendix items referenced in main text
```

---

## Step 5: Strategic Notes

Provide honest assessment:
- **Desk rejection risk:** Based on topic fit, methods, and ambition level
- **Suggested referees:** 3-5 names with expertise match (search WebSearch for recent papers on the topic)
- **Timing considerations:** Submission deadlines, conference cycles, job market timing
- **Competing papers:** Any recent working papers on the same topic that might affect reception
- **Resubmission strategy:** If rejected from Tier 1, which Tier 2 journal is the natural next stop?

---

## Output

Save to `quality_reports/journal_targeting_[date].md`

---

## Principles

- **Be honest about fit.** Don't suggest AER for every paper. Most papers belong in good field journals.
- **Recent publications matter.** A journal that recently published on the same topic is more likely to be interested (or saturated — note both possibilities).
- **Editor identity matters.** Note if the current editor has relevant expertise.
- **Don't over-optimize.** The best journal is the one that publishes the paper, not the highest-ranked one that desk-rejects it.
- **Formatting details change.** Flag any requirements you're unsure about and recommend checking the journal's author guidelines directly.
