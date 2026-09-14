# report/

Markdown working drafts, organized by the project's two components. **This is what Claude drafts and
reviews;** you paste the polished text into Word / Google Docs (the final rendering surface).

- Prose-review skills point here: `/proofread` → `/humanize` → `/verify-claims` → `/review-paper`.
- The repo (analysis outputs + these drafts) is the source of truth for every number;
  Word/Docs is kept in sync *from* here, never the reverse.
- One shared bibliography: `../Bibliography_base.bib` (INV-5).

## Components

| Folder | Component | Owner | Companion analysis |
| --- | --- | --- | --- |
| `theory/` | 2×2 competitive-solicitation model (setup, assumptions, propositions, proofs) | coauthor | `scripts/R/theory/` |
| `empirical/` | *"The Silence of the Satisfied"* — Google-vs-Yelp field paper | author | `scripts/python/{scraping,classifier}/`, `scripts/stata/` |
| `experiment/` | consumer-inference experiment (settles design question (b)) | author | `scripts/R/experiment/` |

The theory and empirical/experimental halves are interdependent (the experiment tests the model's
consumer-inference assumption) but each is drafted so it can stand alone if the other stalls. Keep
construct definitions consistent across components — see `.claude/rules/knowledge-base-template.md` and
the three unsettled design questions in `MEMORY.md`.
