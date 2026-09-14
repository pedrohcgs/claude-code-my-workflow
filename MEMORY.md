# Project Memory — Online Review Ratings

Cross-session memory for this research project. Corrections and durable decisions persist here so
they are not re-litigated. When a mistake is corrected, append a `[LEARN:category]` entry.

> The template-development history that previously lived here (drift prevention, hooks, audit cycles,
> version-cycle notes) was archived to `quality_reports/archive/template-dev-memory.md` when the repo
> was repurposed on 2026-09-14. It is not relevant to doing review-ratings research.

---

## Project at a glance

**Online review ratings, from a marketing perspective.** One project, two interdependent components:

- **Analytical (theory) — coauthor's contribution.** A 2×2 competitive-solicitation model. Two firms
  each choose *solicit* vs. *consumer-driven* review collection. Soliciting narrows the rating
  distribution toward the truth (Sun 2012); quality sorts firms into the off-diagonal cells (strong
  firm solicits, weak firm stays organic). Platform policy decides which cells are feasible — Google
  permits soliciting, Yelp forbids it — so on Yelp only the bottom-right (both consumer-driven) cell
  exists. Source: `docs/coauthor_note_2x2_model.md`.
- **Empirical / experimental — author's contribution.** *"The Silence of the Satisfied."* The
  Google-vs-Yelp field comparison (published star-rating histograms, Yelp's not-recommended pile,
  LLM-scored review text) tests whether firms actually split by strategy and whether the split tracks
  quality. A consumer-inference experiment tests whether consumers adjust their quality inference once
  they know how reviews were collected. Source: proposal `.docx` (to be added to `docs/`).

Bibliography source: `docs/Review_Ratings_Literature_Review.docx` (checked at source 2026-09-12).

---

## Review-Ratings Project — Unsettled Design Questions (analysis branches on these)

These three modelling choices from the 2×2 note are **not yet settled**, and the analysis branches on
each. Recorded here because they must be decided deliberately, not drifted into.

**(a) Do the two firms differ in QUALITY or in TASTE?**
- *Quality* → the **sorting** story: a strong firm solicits to get a tight distribution around a high
  average; a weaker firm does better leaving reviews to consumers, keeping the spread that reads as
  "niche product some people love" (Sun 2012). The strategy choice then sorts firms by quality into the
  shaded off-diagonal cells.
- *Taste* → a **positioning** story: one firm goes broad, the other niche; the asymmetry is about
  horizontal differentiation, not vertical quality.

**(b) Do consumers ADJUST for how reviews were collected?**
- De Langhe, Fernbach & Lichtenstein (2016) find consumers take ratings at face value.
- If consumers **do not** adjust → soliciting is a straight advantage for strong firms (a better-looking
  distribution with no discount).
- If consumers **do** adjust → soliciting becomes a *signal* and can **backfire**.
- **The experiment settles this.** → The analytical and empirical components are interdependent: the
  model's consumer-inference assumption is exactly what the experiment measures. Neither half is fully
  specified without the other. [[design-q-b-experiment-dependency]]

**(c) Is soliciting COSTLY to the firm, and VISIBLE to consumers?**
- If a solicited distribution looks identical to an organic one to consumers, there is **no signal** —
  only a different *displayed* rating.
- If soliciting is costly and/or leaves visible traces (e.g., review bursts from first-time reviewers),
  it can support a separating equilibrium and a consumer inference.

---

<!-- Append new [LEARN] entries below. Most recent at bottom. -->

## Corrections & durable decisions

[LEARN:scope] The empirical/experimental component is **"The Silence of the Satisfied"** (platform
solicitation policy → what a rating measures; Google vs. Yelp; 2×2 model). It is **NOT**
`docs/Representational_Availability_Proposal.docx`, which is a **separate, out-of-scope standalone paper**
about LLM brand-consideration sets that happens to sit in `docs/`. Leave it in place; do not fold it in.

[LEARN:project] This repo was repurposed on 2026-09-14 from *Influencer Marketing (Essay 2): disclosure ×
surprise → engagement* to the review-ratings project (delete-and-reset; git history retains the old work).
Influencer-marketing content that was removed/reset: `CLAUDE.md`, `Bibliography_base.bib`, `report/*`,
`scripts/stata/*.do`, `scripts/R/01–05*.R`, `.claude/rules/knowledge-base-template.md`, the
`domain-reviewer` agent, and this file.

[LEARN:citation] Two source-verified bibliography corrections from the lit review (do not revert):
Hollenbeck (2018) is *Journal of Marketing Research* 55(5), 636–654 — **not** *Marketing Science*.
Gao, Greenwood, Agarwal & McCullough (2015) is titled **"Vocal Minority and Silent Majority,"** *MIS
Quarterly* 39(3) — its title sits close to our working title, so cite it early and say how the question
differs.

[LEARN:workflow] Not building slide decks in this project. The Beamer/Quarto/slides + teaching machinery
is dormant (see CLAUDE.md "What to Ignore"). The real quality gate is the review skills, not the numeric
`quality_score.py` (which errors on `.md`/`.py`/`.do`).
