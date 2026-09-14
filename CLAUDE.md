# CLAUDE.MD -- Online Review Ratings Research Project

<!-- This repo is a fork of an academic-slides+econometrics workflow template
     (pedrohcgs/claude-code-my-workflow). It has been adapted for a PROSE + DATA
     research project on online review ratings: a formal theory model, platform
     data scraping, an LLM text classifier, distributional statistics, and a
     consumer-inference experiment. Analysis outputs + Markdown drafts live here;
     the final papers are written in Word / Google Docs. Slide/LaTeX/teaching
     machinery is kept on disk but DORMANT (see "What Applies / What to Ignore").
     Do not delete it — it keeps future upstream merges clean. -->

**Project:** Online Review Ratings — Platform Solicitation Policy and What a Rating Measures — *working title, confirm*
**Empirical paper:** *"The Silence of the Satisfied"*
**Institution:** Kelley School of Business, Indiana University
**Branch:** main

One project, **two interdependent components:**

- **Analytical (theory) — coauthor's contribution.** A 2×2 competitive-solicitation model. Two firms each choose *solicit* vs. *consumer-driven* collection; soliciting narrows the rating distribution toward the truth (Sun 2012); quality sorts firms into the off-diagonal cells; platform policy (Google permits soliciting, Yelp forbids it) decides which cells are feasible.
- **Empirical / experimental — author's contribution.** *"The Silence of the Satisfied":* a Google-vs-Yelp field comparison (published star-rating histograms, Yelp's not-recommended pile, LLM-scored review text) plus a consumer-inference experiment. The experiment settles the model's key consumer-inference assumption, so the two halves depend on each other (see [MEMORY.md](MEMORY.md), design question (b)).

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- re-run analysis / re-check outputs and confirm results at the end of every task
- **Single source of truth** -- analysis **outputs** (Stata primary; R / Python secondary) + **Markdown working drafts** in this repo are authoritative; **Word / Google Docs is the final rendering surface**, kept in sync *from* the repo drafts (never the reverse)
- **Quality gates** -- advisory for this project (see note below): use the review skills, not a numeric score, as the real gate
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md) (project memory) or `.claude/state/personal-memory.md` (machine-specific)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, decision records, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

The template's **language-first** `scripts/{R,stata,python}/` and top-level `report/` are preserved so the
workflow skills keep working; **component + task subfolders** organize the two strands. One shared
bibliography.

```
Reviews/
├── CLAUDE.MD                    # This file
├── MEMORY.md                    # [ACTIVE] Project memory (design questions, decisions, corrections)
├── Bibliography_base.bib        # [ACTIVE] ONE shared bibliography (theory + empirical + experiment)
├── .claude/                     # Rules, skills, agents, hooks
│
├── docs/                        # [ACTIVE] Source inputs (proposals, lit review, 2×2 note)
│   ├── coauthor_note_2x2_model.md              # analytical component note
│   ├── Review_Ratings_Literature_Review.docx   # lit review → bibliography source
│   ├── (The_Silence_of_the_Satisfied.docx)     # empirical proposal — to be added
│   └── Representational_Availability_Proposal.docx   # OUT OF SCOPE (separate paper)
│
├── report/                      # [ACTIVE] Markdown working drafts
│   ├── theory/                  # 2×2 model: setup, assumptions, propositions, proofs
│   ├── empirical/               # "The Silence of the Satisfied" — Google vs Yelp field paper
│   └── experiment/              # consumer-inference experiment write-up
│
├── scripts/
│   ├── python/                  # [ACTIVE] scraping + LLM classifier (Python-natural)
│   │   ├── scraping/            #   Google/Yelp histograms, not-recommended pile
│   │   ├── classifier/          #   LLM review-text scorer: prompts, run, validation
│   │   └── _outputs/
│   ├── stata/                   # [ACTIVE] PRIMARY: distributional statistics on ratings
│   ├── R/                       # [ACTIVE] SECONDARY: tables, figures, experiment, model numerics
│   │   ├── theory/              #   numerical equilibrium / comparative statics (Sun-2012 spread)
│   │   ├── experiment/          #   experiment data analysis
│   │   ├── 00_run_all.R         #   generic reproducibility orchestrator (kept)
│   │   └── _outputs/
│   └── (secondary check scripts)
│
├── data/                        # [ACTIVE] Raw + processed data (guarded by confidential-data rule)
│   ├── scraped/                 #   platform data (Google / Yelp)
│   └── experiment/              #   experiment responses
├── Figures/                     # [ACTIVE] Figures — Figures/{theory,empirical,experiment}/
├── quality_reports/             # [ACTIVE] Plans, specs, decision records, session logs, archive/
├── templates/                   # [ACTIVE] Spec / session-log / decision-record templates
├── master_supporting_docs/      # [ACTIVE] Papers and background docs
├── explorations/                # [ACTIVE] Research sandbox
│
├── Slides/                      # [DORMANT] Beamer .tex — not building slides in this project
├── Quarto/                      # [DORMANT] RevealJS .qmd + theme
└── Preambles/header.tex         # [DORMANT] LaTeX headers
```

---

## Commands

```bash
# Run Stata do-file (PRIMARY analysis; batch mode) — distributional statistics
stata-mp -b do scripts/stata/<name>.do

# Run the R pipeline (secondary; tables/figures, experiment, model numerics)
Rscript scripts/R/00_run_all.R

# Run a Python task (scraping / LLM classifier); outputs land in scripts/python/_outputs/
python scripts/python/scraping/<name>.py
python scripts/python/classifier/<name>.py

# Quality score — LIMITATION: scores only .qmd / .tex / .R; it ERRORS on .md, .py, and .do.
# Our main artifact types (Markdown drafts, Stata, Python) are NOT scorable, so treat
# the numeric gate as advisory and lean on the review skills below.
python scripts/quality_score.py scripts/R/file.R
```

---

## Quality Thresholds (advisory for this project)

The numeric 80/90/95 gate came from the slides template and only scores `.qmd/.tex/.R`.
For a prose+data project the **real quality mechanism is the review skills**:

- **Prose drafts:** `/proofread` → `/humanize` → `/verify-claims` → `/review-paper`
- **Analysis:** `/review-r` + `/audit-reproducibility` (and `/stata-replication` for Stata)
- **LLM classifier:** no `.py` scorer — validate with a labeled hold-out + `/verify-claims`, and
  `/audit-reproducibility` on its output tables (see the classifier README).

**Do not run `./scripts/install-hooks.sh`** — its pre-commit hook adds surface-sync (template maintenance) + R/qmd/tex scoring that mostly won't apply here and would only add friction. Revisit if we later add `.md`/`.py` scorers.

---

## What Applies / What to Ignore

**A — Applies directly (use freely):**
`/stata-replication` `/audit-reproducibility` `/replication-package` `/capture-environment`
`/review-paper` `/seven-pass-review` `/review-r` `/verify-claims` `/proofread` `/humanize`
`/submission-disclosures` `/respond-to-referees` `/lit-review` `/validate-bib` `/interview-me`
`/research-ideation` `/preregister` `/diagnose` `/commit` `/learn` `/checkpoint` `/context-status`
(`/data-analysis` is R-native — usable for the secondary R work + the experiment, not the Stata pipeline)

**B — Adapt before trusting (customized for this project):**
- `quality_score.py` — doesn't score `.md`/`.py`/`.do` (see above)
- Knowledge base (`.claude/rules/knowledge-base-template.md`) — a **review-ratings metrics + decisions registry**
- `domain-reviewer` agent — retuned for **review-ratings substance** (distributional stats, LLM-classifier
  measurement validity, platform-policy identification, consumer-inference experiment)

**C — Dormant / ignore (slides + teaching template machinery):**
`/create-lecture` `/compile-latex` `/deploy` `/qa-quarto` `/slide-excellence`
`/translate-to-quarto` `/extract-tikz` `/new-diagram` `/syllabus` `/teach-from-paper`
`/scaffold-exercises` `/pedagogy-review` `/visual-audit` — plus `Slides/ Quarto/ Preambles/`,
the slide-only content invariants (INV-1..4, 6..8, 11..12), and the palette-/surface-sync scripts.
Left on disk for clean upstream merges; not part of this workflow. (Applicable invariants:
**INV-5** single bibliography; **INV-9/INV-10** set.seed once / relative paths.)

*Note: `docs/` holds this project's source inputs. The template's stale GitHub-Pages HTML
(`index.html`, `workflow-guide.html`) is dormant and can be ignored.*

---

## Current Project State

| Component | Draft (`report/`) | Analysis | Key outputs |
| --- | --- | --- | --- |
| Theory: 2×2 competitive solicitation | `report/theory/` | `scripts/R/theory/` (numerical illustration) | propositions; comparative statics (Sun-2012 spread) |
| Empirical: Silence of the Satisfied (Google vs Yelp) | `report/empirical/` | `scripts/python/{scraping,classifier}/`, `scripts/stata/` | star-rating histograms; not-recommended-pile analysis; LLM text scores |
| Experiment: consumer inference | `report/experiment/` | `scripts/R/experiment/` | choice results (settles design question (b)) |

*Scraped platform data and experiment data live under `data/` (raw kept off-repo per the
confidential-data rule). Update this table as drafts and analysis land here. The empirical proposal
`.docx` ("The Silence of the Satisfied") is to be added to `docs/`.*
