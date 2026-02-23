# CLAUDE.MD --- Data Analysis with Claude Code

**Project:** [YOUR PROJECT NAME]
**Institution:** Macquarie University
**Branch:** main

---

## Core principles

- **Plan first** --- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** --- compile/run and confirm output at the end of every task
- **Quality gates** --- nothing ships below 80/100
- **[LEARN] tags** --- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Project setup checklist (first session)

1. Drop your existing project folder contents into `project/`
2. Describe the folder structure in the "File structure map" section below
3. Configure Dropbox sync paths if applicable (see Dropbox sync section)
4. Update "Beamer custom environments" if you use a custom theme
5. Run `/compile-latex` on a test file to verify MikTeX works

---

## Folder structure

```
repo/
├── CLAUDE.md                    # This file
├── MEMORY.md                    # Persistent learnings
├── README.md                    # Minimal: what, how, prerequisites
├── bibliography.bib             # Shared bibliography
├── .syncignore                  # Excluded from Dropbox sync
├── .claude/                     # All infrastructure
│   ├── settings.json            # Permissions + hook wiring
│   ├── agents/                  # Review agents
│   ├── rules/                   # Workflow rules
│   ├── skills/                  # Slash commands
│   ├── hooks/                   # Automation hooks
│   └── WORKFLOW_QUICK_REF.md    # One-page cheat sheet
├── preambles/header.tex         # Shared Beamer preamble (Metropolis)
├── slides/                      # New Beamer slides
├── figures/                     # Static images for slides
├── scripts/
│   ├── quality_score.py         # Quality scoring (Beamer/Python/Stata)
│   ├── python/                  # Shared Python utilities
│   └── stata/
│       └── logs/                # Stata log files
├── templates/                   # Session log, quality report, sync scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox
├── master_supporting_docs/      # Papers (PDF processing rule)
└── project/                     # YOUR EXISTING PROJECT FILES HERE
    └── README.md                # Explains convention + Dropbox sync
```

Infrastructure at root never touches Dropbox. Only `project/` syncs bidirectionally.

---

## File structure map

<!-- Claude: on first session, explore project/ and fill this in. -->
<!-- Example:
project/
├── data/
│   ├── raw/             # Original datasets (protected, never overwrite)
│   └── processed/       # Cleaned data
├── code/
│   ├── 01_clean.do      # Data cleaning
│   └── 02_analysis.py   # Main analysis
└── output/
    ├── tables/          # LaTeX tables
    └── figures/         # Generated figures
-->

```
project/
└── [Describe your structure here]
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX + MikTeX on Windows)
cd slides && xelatex --include-directory=../preambles -interaction=nonstopmode file.tex
bibtex file
xelatex --include-directory=../preambles -interaction=nonstopmode file.tex
xelatex --include-directory=../preambles -interaction=nonstopmode file.tex

# Python
python scripts/python/analysis.py

# Stata (StataNow 19, cd into script directory so log lands there)
cd scripts/stata && stata-mp -b do analysis.do

# Quality score
python scripts/quality_score.py slides/Lecture01_Topic.tex
python scripts/quality_score.py scripts/python/analysis.py
python scripts/quality_score.py scripts/stata/analysis.do
```

---

## Quality thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills quick reference

| Command | What it does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata .do file quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end Python analysis |

---

## Beamer custom environments

| Environment | Effect | Use case |
|-------------|--------|----------|
| `keybox` | Gold background box | Key takeaways |
| `highlightbox` | Teal left-accent box | Highlights |
| `definitionbox[Title]` | Navy titled box | Formal definitions |

---

## Sync

<!-- Configure with: bash templates/setup-sync.sh -->
<!-- Paths are stored in .sync-config (gitignored). If no Dropbox/Overleaf, skip this. -->

---

## Current project state

| Lecture | File | Key content |
|---------|------|-------------|
| 1: [Topic] | `slides/Lecture01_Topic.tex` | [Brief description] |
