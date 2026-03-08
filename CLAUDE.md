# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** ECN 152: Economics of Education
**Institution:** UC Davis
**Branch:** main

> **Note on Quarto:** This project is Beamer-only for now. Quarto skills are available if/when needed but not the active workflow. Quarto-specific skills are marked "(not active)" below.

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **Single source of truth** -- Beamer `.tex` is the authoritative output format
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
ECN152/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # LaTeX headers
├── Slides/                      # Beamer .tex files (primary output)
├── scripts/                     # Utility scripts + R code
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

*(Quarto/ and docs/ directories exist in the template but are not active for this project.)*

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
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
| `/visual-audit [file]` | Slide layout audit (Beamer) |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |
| `/deploy [LectureN]` | *(not active)* Render Quarto + sync to docs/ |
| `/extract-tikz [LectureN]` | *(not active)* TikZ → PDF → SVG for Quarto |
| `/qa-quarto [LectureN]` | *(not active)* Adversarial Quarto vs Beamer QA |
| `/translate-to-quarto [file]` | *(not active)* Beamer → Quarto translation |

---

## Beamer Custom Environments

*(To be populated after reviewing existing .tex preambles)*

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| TBD               | —             | —              |

---

## Current Project State

*(To be populated when .tex slide files are added)*

| Lecture | Beamer | Key Content |
|---------|--------|-------------|
| TBD     | TBD    | TBD         |
