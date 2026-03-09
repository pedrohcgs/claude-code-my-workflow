# Research Proposals Directory

3–5 feasible 3-month student research proposals in Nepal & Global Energy Economics.

---

## Structure

```
proposals/
├── README.md          # This file — proposal template guidance
├── proposal_01_[title].md
├── proposal_02_[title].md
└── ...
```

---

## Proposal Template

Each proposal should follow this structure:

```markdown
# [Proposal Title]

**Status:** [DRAFT / IN REVIEW / FINAL]
**Quality score:** [N/100]
**Date:** YYYY-MM-DD

---

## Research Question
[One precise, answerable question. Avoid vague "what is the relationship between X and Y."]

## Abstract (150–200 words)
[Background → Gap → This paper → Method → Expected contribution]

## Motivation & Background
[Why does this matter? What is the policy/academic gap?]
[3–5 key citations from `literature/`]

## Methodology
### Data
- Source(s): [be specific — IEA 2023 vintage, WDI downloaded YYYY-MM-DD]
- Coverage: [countries, years]
- Key variables: [with units and construction notes]

### Estimation Strategy
[Estimator choice + justification; identification assumption; robustness checks]

### Timeline (3 months)
| Month | Milestones |
|-------|-----------|
| 1 | Data collection, cleaning, descriptive analysis |
| 2 | Main estimation, initial results |
| 3 | Robustness checks, write-up |

## Expected Findings & Contribution
[What do you expect to find, and why does it matter?]
[How does it extend the existing literature?]

## Data Availability Check
- [ ] Primary dataset publicly available or accessible within 3 months
- [ ] No proprietary data required
- [ ] R packages for estimation available (list them)

## Potential Limitations
[Acknowledge upfront: data constraints, identification challenges, generalizability]

## References
[Use BibTeX keys from `Bibliography_base.bib`]
```

---

## Quality Gate Checklist (before marking FINAL)

- [ ] Research question is specific and answerable in 3 months
- [ ] Data sources verified as accessible
- [ ] Methodology is appropriate for the data structure and RQ
- [ ] Abstract clearly states gap → contribution
- [ ] Quality score >= 90/100 (use `python scripts/quality_score.py`)
- [ ] Domain review passed (`/deep-audit` or manual domain-reviewer agent)
