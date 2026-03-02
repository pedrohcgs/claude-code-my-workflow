# CLAUDE.MD -- Geopolitics and Global Value Chains

**Project:** Geopolitics and Global Value Chains (Geopolitics-GVC)
**Institution:** Universidad de Chile
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render/run and confirm output at the end of every task
- **Paper is authoritative** -- `Paper/main.tex` is the primary artifact; slides derive from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
geopolitics-gvc/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Publication-ready figures (matplotlib, ggplot2)
├── Preambles/header.tex         # LaTeX preambles (shared by Paper and Slides)
├── Paper/                       # LaTeX manuscript (primary artifact)
│   ├── main.tex                 # Main paper entry point
│   └── sections/                # Individual section files
├── Slides/                      # Beamer working-paper slides (.tex)
├── Quarto/                      # RevealJS slides (.qmd) + theme
├── code/                        # All analysis code
│   ├── python/                  # MRIO algebra + data download (Python)
│   └── stata/                   # Econometric analysis + regression tables (Stata)
├── data/                        # Data pipeline
│   ├── raw/                     # Raw downloads (OECD ICIO, UN voting) -- gitignored
│   ├── processed/               # Cleaned, merged datasets
│   └── outputs/                 # Final tables and figures
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts (quality_score.py, sync_to_docs.sh)
├── quality_reports/             # Plans, session logs, merge reports, specs
├── explorations/                # Research sandbox (60/100 quality gate)
├── templates/                   # Session log, quality report, spec templates
└── master_supporting_docs/      # Key reference papers and existing slides
```

---

## Commands

```bash
# LaTeX paper (3-pass, XeLaTeX)
cd Paper && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex

# LaTeX slides (Beamer, 3-pass)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Python: MRIO algebra (run from repo root)
python code/python/mrio_pipeline.py

# Stata: analysis (adjust for Windows Stata installation)
stata-mp -b do code/stata/04_merge_analysis.do

# Deploy Quarto slides to GitHub Pages
./scripts/sync_to_docs.sh SlideName

# Quality score
python scripts/quality_score.py Paper/main.tex
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for sharing / deployment |
| 95 | Excellence | Submission-ready |

---

## Key Data Sources

| Dataset | Coverage | Where | Use |
|---------|----------|-------|-----|
| OECD ICIO 2025 (regular) | 80 economies, 1995–2022, 50 ISIC sectors | oecd.org/icio | MRIO backbone (Z, Y, x, VA) |
| Bailey-Strezhnev-Voeten ideal points | All UN members, 1946–2020 | Harvard Dataverse | IPD-based seg score (primary) |
| UNGA-DM (Christopher Kilby) | All UN members, 1946–2022 | Google Sites | Robustness seg score |
| FPSIM v2 (Frank Häge) | Dyadic UN-vote similarity, to 2015 | frankhaege.eu | Additional robustness check |

---

## Core Methodology

| Step | Formula | Symbol |
|------|---------|--------|
| Technical coefficients | **A** = **Z** · diag(**x**)⁻¹ | **A** |
| Leontief inverse | **L** = (**I** − **A**)⁻¹ | **L** |
| Output for focus country c | **g** = **L** · **y**_c | **g** |
| VA contributions | VAcontr = diag(**v**) · **g** | VAcontr |
| FVA weight (i → c) | w_{i,c,t} = FVA_{i,c,t} / Σ_{k≠c} FVA_{k,c,t} | w |
| US-China pivot score | seg(i,t) = [IPD(i,CHN,t)−IPD(i,US,t)] / [IPD(i,US,t)+IPD(i,CHN,t)] ∈ [−1,+1] | seg |
| Geopolitical exposure | Exposure_{c,t} = Σ_{i≠c} w_{i,c,t} · seg(i,t) | Exposure |
| Geopolitical risk | Risk_{c,t} = Σ_{i≠c} w_{i,c,t} · \|seg(i,t)−seg(c,t)\| / 2 | Risk |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/deploy [SlideName]` | Render Quarto + sync to docs/ |
| `/extract-tikz [SlideName]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/qa-quarto [SlideName]` | Adversarial Quarto vs Beamer QA |
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
| `/data-analysis [dataset]` | End-to-end analysis workflow |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |

---

## Current Project State

| Component | Status | File | Notes |
|-----------|--------|------|-------|
| Paper | Not started | `Paper/main.tex` | Intro MRIO + UN-voting geopolitics approach |
| Working-paper slides | Not started | `Slides/GVC_Geopolitics.tex` | Summary deck for seminars |
| MRIO pipeline | Not started | `code/python/mrio_pipeline.py` | OECD ICIO 2025 → FVA weights |
| Geopolitics scores | Not started | `code/stata/01_geopolitics_scores.do` | seg from Bailey-Strezhnev-Voeten |
| LA analysis | Not started | `code/stata/02_LA_analysis.do` | Chile pilot + ~8 LA countries |
| Bibliography | Empty | `Bibliography_base.bib` | Needs MRIO + fragmentation references |
| Figures | Not started | `Figures/` | Exposure series, sector heatmaps |
