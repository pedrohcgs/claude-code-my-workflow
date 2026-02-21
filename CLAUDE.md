# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** PV Module Reliability Assessment Framework
**Institution:** Amp Tech
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Code-first** -- Python/R analysis code is authoritative; slides and reports derive from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to MEMORY.md

---

## Folder Structure

```
pv-module-reliability/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # LaTeX headers
├── Slides/                      # Beamer .tex files
├── Quarto/                      # RevealJS .qmd files + theme
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts + R code
├── notebooks/                   # Jupyter notebooks (analysis, exploration)
├── data/                        # Data directory
│   ├── raw/                     # Original unmodified datasets
│   ├── processed/               # Cleaned/transformed data
│   └── external/                # Third-party data (NREL, Sandia, LBNL)
├── reports/                     # Generated reports and deliverables
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Python
pip install -r requirements.txt
pytest tests/
jupyter lab notebooks/

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
| `/extract-tikz [LectureN]` | TikZ -> PDF -> SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer QA |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/translate-to-quarto [file]` | Beamer -> Quarto translation |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end data analysis (R or Python) |

---

## Beamer Custom Environments

| Environment | Effect | Use Case |
|-------------|--------|----------|
| `resultbox` | Green-bordered box | Key findings and results |
| `warningbox` | Red-bordered box | Failure modes, degradation alerts |
| `specbox[Title]` | Blue-bordered titled box | IEC specifications, module specs |

## Quarto CSS Classes

| Class | Effect | Use Case |
|-------|--------|----------|
| `.smaller` | 85% font | Dense data tables |
| `.pass` | Green bold | Pass criteria met |
| `.fail` | Red bold | Failure threshold exceeded |

---

## Current Project State

| Module | Beamer | Quarto | Key Content |
|--------|--------|--------|-------------|
| 1: Optical Degradation | `Lecture01_Optical.tex` | -- | Transmittance loss, yellowing, AR coating |
| 2: Thermal Stress | `Lecture02_Thermal.tex` | -- | Thermal cycling, hot spots, Arrhenius models |
| 3: Mechanical Failure | `Lecture03_Mechanical.tex` | -- | Cell cracking, solder fatigue, backsheet |
| 4: Environmental Exposure | `Lecture04_Environmental.tex` | -- | Damp heat, UV, PID, corrosion |
