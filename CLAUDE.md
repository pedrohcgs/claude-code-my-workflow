# CLAUDE.MD -- Regulatory Fragmentation and Voluntary Disclosure

**Project:** Regulatory Fragmentation and Voluntary Disclosure (Earnings Guidance)
**Institution:** Boston College
**Branch:** main
**Target Journals:** Top-3 Accounting (TAR / JAR / JAE)

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- `Manuscript/main.tex` is the authoritative paper; slides derive from it
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to MEMORY.md

---

## Project Context

### Research Question
How does regulatory fragmentation affect voluntary disclosure (earnings guidance)?

### Related Repository
- **Replication pipeline:** `/Users/jieonki0/Dropbox/Ji_RegFrag/Ji_RegFrag_Replication/`
  - Steps 1-7 complete (FR XML parsing, LDA training, FR topic distributions)
  - Step 8 in progress (10-K LDA posteriors via SLURM job array)
  - Step 9 + InternetAppendix.R not yet started
- **Server:** Andromeda 2 HPC at Boston College (`kimjie@a002.bc.edu`)
- **Server path:** `/projects/liulab/RegFrag_Ji/`
- **Professor:** Professor Miao

### Key Data Locations (Server)
- Federal Register texts: `/projects/liulab/RegFrag_Ji/Data/Master and Texts/`
- LDA model + DTMs: `/projects/liulab/RegFrag_Ji/Data/LDA_Data/`
- 10-K LDA outputs: `/projects/liulab/RegFrag_Ji/Data/LDA_Data/LDA10K/`
- 10-K SQLite DBs: `/projects/liulab/RegFrag_Ji/Data/10-K/`

---

## Folder Structure

```
RegFrag/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Manuscript/                  # LaTeX paper (single source of truth)
│   ├── main.tex                 # Master document
│   └── sections/                # \input{} files (intro, lit review, etc.)
├── Data/                        # Data storage
│   ├── raw/                     # Not committed (large/sensitive)
│   ├── processed/               # Not committed
│   └── metadata/                # Data dictionaries (committed)
├── Figures/                     # All figures and tables
├── scripts/                     # Analysis and utility scripts
│   ├── R/                       # R analysis scripts
│   ├── Python/                  # Python scripts
│   └── shell/                   # HPC/SLURM scripts
├── Bibliography_base.bib        # Centralized bibliography
├── Preambles/                   # LaTeX headers
├── Slides/                      # Beamer slides (for conferences)
├── Quarto/                      # RevealJS slides (for conferences)
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing materials
```

---

## Commands

```bash
# Manuscript compilation (pdflatex or xelatex)
cd Manuscript && pdflatex -interaction=nonstopmode main.tex
bibtex main
pdflatex -interaction=nonstopmode main.tex
pdflatex -interaction=nonstopmode main.tex

# Beamer slides (for conference presentations)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# R analysis
Rscript scripts/R/script_name.R

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

### Research (Primary)
| Command | What It Does |
|---------|-------------|
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/review-r [file]` | R code quality review |
| `/review-paper [file]` | Manuscript review |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/validate-bib` | Cross-reference citations |
| `/proofread [file]` | Grammar/typo review |

### Infrastructure
| Command | What It Does |
|---------|-------------|
| `/commit [msg]` | Stage, commit, PR, merge |
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |

### Presentations (When Needed)
| Command | What It Does |
|---------|-------------|
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/translate-to-quarto [file]` | Beamer -> Quarto translation |
| `/visual-audit [file]` | Slide layout audit |
| `/slide-excellence [file]` | Combined multi-agent review |

---

## Current Project State

| Milestone | Status | Key Artifacts | Notes |
|-----------|--------|---------------|-------|
| Data Pipeline (Steps 1-7) | Complete | In Ji_RegFrag_Replication/ | FR XML, LDA training, FR topics |
| 10-K LDA Posteriors (Step 8) | In Progress | SLURM job array on Andromeda | ~217 min/chunk, 2 submissions/year |
| Company-Year Panel (Step 9) | Not Started | -- | Merge LDA + Compustat/CRSP + lobbying |
| Literature Review | Not Started | -- | RegFrag + guidance literatures |
| Manuscript Draft | Not Started | `Manuscript/main.tex` | Target: TAR/JAR/JAE |
| Empirical Analysis | Not Started | `scripts/R/` | After panel construction |
| Robustness Checks | Not Started | -- | After main analysis |
