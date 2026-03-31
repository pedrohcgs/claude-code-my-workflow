# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** Climate, Coffee & Migration: Evidence from Hawassa Industrial Park, Ethiopia
**Institution:** [YOUR INSTITUTION]
**Stack:** Python (GEE + ML) · R (statistics) · LaTeX (thesis document)
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **Single source of truth** -- LaTeX chapters are authoritative; figures/tables derive from Python and R scripts
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
climate-coffee-migration/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Generated figures, maps, plots (derived)
├── Preambles/header.tex         # LaTeX thesis preamble/headers
├── Chapters/                    # LaTeX .tex chapter files (source of truth)
├── Data/                        # Satellite data docs, codebooks, metadata
├── output/                      # Generated tables, model outputs, metrics
│   ├── tables/                  # R-generated .tex tables
│   └── models/                  # ML model checkpoints
├── scripts/                     # Analysis code
│   ├── python/                  # GEE scripts, image processing, ML
│   └── R/                       # Statistical analysis, regression
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Reference papers and slides
```

---

## Commands

```bash
# LaTeX thesis (3-pass, XeLaTeX)
cd Chapters && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode thesis.tex
BIBINPUTS=..:$BIBINPUTS bibtex thesis
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode thesis.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode thesis.tex

# Python / GEE (run from project root)
python scripts/python/gee_export.py          # Batch GEE export
python scripts/python/classify_images.py     # ML classification

# R analysis
Rscript scripts/R/analysis.R                 # Main regression analysis

# Quality score
python scripts/quality_score.py Chapters/chapter1.tex
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for chapter draft |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/review-r [file]` | R code quality review |
| `/review-paper [file]` | Manuscript/chapter review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/validate-bib` | Cross-reference citations |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |
| `/visual-audit [file]` | Slide layout audit *(presentations only)* |
| `/compile-latex [file]` | Beamer slides *(presentations only)* |
| `/translate-to-quarto [file]` | Beamer → Quarto *(presentations only)* |

---

## LaTeX Thesis Environments

| Environment | Effect | Use Case |
|-------------|--------|----------|
| *(add yours as you define them)* | | |

## Python / R Conventions

| Convention | Rule | Why |
|-----------|------|-----|
| GEE exports | Batch only; `.getInfo()` at export time | Avoid quota limits |
| Random seeds | Always set (`np.random.seed`, `set.seed`) | Reproducibility |
| Figure provenance | Every figure has a script in `scripts/` | Traceability |
| Table provenance | Every table traces to an R script | Traceability |
| CRS documentation | Document CRS + resolution in comments | Reproducibility |

---

## Thesis Chapter State

| Chapter | Topic | .tex File | Status | Key Content |
|---------|-------|-----------|--------|-------------|
| 1 | Introduction | `chapter1_intro.tex` | -- | Research question, motivation, preview |
| 2 | Context & Data | `chapter2_data.tex` | -- | Ethiopia, Hawassa IP, GEE satellite data |
| 3 | Climate & Coffee | `chapter3_climate.tex` | -- | NDVI, SPEI, arabica degradation |
| 4 | Empirical Strategy | `chapter4_empirics.tex` | -- | Identification, estimands, ML pipeline |
| 5 | Results | `chapter5_results.tex` | -- | Main results, robustness |
| 6 | Conclusion | `chapter6_conclusion.tex` | -- | Contributions, policy implications |
