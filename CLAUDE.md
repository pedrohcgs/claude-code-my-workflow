# CLAUDE.MD -- Academic Project Development with Claude Code

<!-- HOW TO USE: Replace [BRACKETED PLACEHOLDERS] with your project info.
     Keep this file under ~150 lines — Claude loads it every session.
     See the guide at docs/workflow-guide.html for full documentation. -->

**Project:** Credit Constraints and Exports
**Institution:** [YOUR INSTITUTION]
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/render and confirm output at the end of every task
- **Single source of truth** -- `paper/manuscript.tex` is authoritative
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
credit-constraints-exports/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images (output of R scripts)
├── paper/                       # LaTeX manuscript (.tex + .bbl + .pdf)
├── data/
│   ├── raw/                     # Source data files (gitignored if large)
│   └── processed/               # Cleaned/merged datasets (RDS or CSV)
├── scripts/
│   └── R/
│       └── _outputs/            # Pre-computed RDS results (loaded by paper)
├── quality_reports/             # Plans, session logs, merge reports, specs
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Source papers and literature
```

---

## Commands

```bash
# LaTeX paper (3-pass, XeLaTeX)
cd paper && xelatex -interaction=nonstopmode manuscript.tex
bibtex manuscript
xelatex -interaction=nonstopmode manuscript.tex
xelatex -interaction=nonstopmode manuscript.tex

# R analysis pipeline
Rscript scripts/R/00_construct_proxies.R
Rscript scripts/R/01_clean.R
Rscript scripts/R/02_analyze.R
Rscript scripts/R/03_figures.R

# Quality score (R script)
python scripts/quality_score.py scripts/R/02_analyze.R
```

---

## Quality Thresholds (advisory)

| Score | Checkpoint | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

Enforced by `/commit` (halts + asks for override); not enforced by a git pre-commit hook.

---

## Skills Quick Reference

### Paper project (primary)

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/review-paper [file]` | Manuscript review (`--adversarial` / `--peer <journal>`) |
| `/seven-pass-review` | Seven-pass adversarial manuscript review (parallel forked subagents) |
| `/verify-claims [file]` | Chain-of-Verification fact-check (forked verifier, fresh context) |
| `/respond-to-referees [report] [manuscript]` | R&R cross-reference + response draft |
| `/validate-bib` | Cross-reference citations |
| `/review-r [file]` | R code quality review |
| `/data-analysis [dataset]` | End-to-end R analysis pipeline |
| `/audit-reproducibility [paper]` | Enforce replication tolerance thresholds on paper ↔ code |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/permission-check` | Diagnose permission layers when prompts fire unexpectedly |

### Slides (available if needed later)

| Command | What It Does |
|---------|-------------|
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/extract-tikz [LectureN]` | TikZ → PDF → SVG |
| `/new-diagram [snippet] [output.tex]` | Scaffold a TikZ diagram from the gallery |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer QA |
| `/slide-excellence [file]` | Combined multi-agent slide review |
| `/translate-to-quarto [file]` | Beamer → Quarto translation |
| `/devils-advocate` | Challenge slide design |
| `/create-lecture` | Full lecture creation |

---

## LaTeX Paper Environments

<!-- Add custom theorem/definition environments here as you define them in header.tex -->

| Environment | Effect | Use Case |
| --- | --- | --- |
| `[your-env]` | [Description] | [When to use] |

---

## Current Project State

| Artifact | File | Status | Key Content |
| --- | --- | --- | --- |
| Paper | `paper/manuscript.tex` | Not started | Credit constraints & exports analysis |
