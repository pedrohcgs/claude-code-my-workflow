# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** Capital and Labor Shares in Healthcare
**Institution:** University of Chicago
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- Beamer `.tex` is authoritative; Quarto `.qmd` derives from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
capital-labor-healthcare/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── analysis/                    # Stata task-based DAG (code/inputs/outputs per task)
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Slides/                      # Beamer .tex files (preamble inline, metropolis theme)
├── Quarto/                      # RevealJS .qmd files + theme
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only)
cd Slides && xelatex -interaction=nonstopmode slides.tex
BIBINPUTS=..:$BIBINPUTS bibtex slides
xelatex -interaction=nonstopmode slides.tex
xelatex -interaction=nonstopmode slides.tex

# Stata (run a task)
cd analysis/task_name && stata-mp -b do code/main.do

# Deploy Quarto to GitHub Pages
./scripts/sync_to_docs.sh LectureN

# Quality score
python scripts/quality_score.py Quarto/file.qmd
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer QA |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/translate-to-quarto [file]` | Beamer → Quarto translation |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end Stata analysis |

---

## Beamer Environments (Metropolis Theme)

| Environment | Effect | Use Case |
|-------------|--------|----------|
| `block{Title}` | Standard titled block | General emphasis, definitions |
| `alertblock{Title}` | Alert-colored block | Key results, warnings |
| `exampleblock{Title}` | Example-colored block | Examples, illustrations |
| `frame[plain]` | No header/footer | Title slides, full-page figures |

*Using standard metropolis theme. No custom box environments.*

## Quarto CSS Classes

| Class | Effect | Use Case |
|-------|--------|----------|
| `.smaller` | 85% font | Dense data slides |
| `.uchicago-maroon` | Maroon text | Institutional emphasis |
| `.uchicago-phoenix` | Phoenix yellow text | Highlight accents |
| `.hi` | Bold maroon | Key terms inline |
| `.positive` | Green bold | Positive results/effects |
| `.negative` | Red bold | Negative results/concerns |
| `.compact` | Tight spacing | Content-heavy slides |

---

## Current Project State

| Lecture | Beamer | Quarto | Key Content |
|---------|--------|--------|-------------|
| Main | `Slides/slides.tex` | -- | Metropolis theme; sections via `\input{sections/*.tex}` |
