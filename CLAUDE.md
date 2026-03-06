# CLAUDE.MD -- AIGC and Stock Price Synchronicity

**Project:** AIGC and Stock Price Synchronicity
**Institution:** [YOUR INSTITUTION]
**Target Journals:** JFQA, JAE, JMCB, Management Science
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- `Paper/main.tex` is authoritative for the paper
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
AIGC-Synchronicity/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Paper/                       # LaTeX paper source
│   ├── main.tex                 # Main paper
│   └── appendix.tex             # Online appendix
├── Slides/                      # Beamer presentation files
├── Scripts/                     # Python (primary) + R empirical code
├── Figures/                     # Generated figures (PDF/PNG)
├── Tables/                      # Generated LaTeX tables
├── Data/                        # Raw + processed data (large files gitignored)
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Reference papers and prior slides
```

---

## Commands

```bash
# LaTeX paper (3-pass, XeLaTeX)
cd Paper && xelatex -interaction=nonstopmode main.tex
bibtex main
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex

# LaTeX slides (3-pass, XeLaTeX)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Python environment
pip install -r requirements.txt
python Scripts/[script].py
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
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/review-r [file]` | R code quality review |
| `/validate-bib` | Cross-reference citations |
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

## Beamer Custom Environments

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| `[your-env]`      | [Description] | [When to use]  |

---

## Current Project State

| Component | File | Status | Key Content |
|-----------|------|--------|-------------|
| Introduction | `Paper/main.tex` | -- | Motivation, contribution, literature |
| Empirical Design | `Paper/main.tex` | -- | AIGC measurement, synchronicity measure |
| Main Results | `Paper/main.tex` | -- | Baseline regressions |
| Robustness | `Paper/main.tex` | -- | Alternative specs, placebo tests |
| Presentation | `Slides/presentation.tex` | -- | Conference/seminar slides |
