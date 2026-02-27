# CLAUDE.MD -- Academic Project Development with Claude Code

**Project:** Capital and Labor Shares in Healthcare
**Institution:** University of Chicago
**Branch:** main
**Template:** Based on [Dingel projecttemplate](https://github.com/jdingel/projecttemplate)

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
├── bib/                         # Bibliography (bib.bib + aer.bst)
├── logbook/                     # Project logbook (LaTeX)
├── paper/                       # Paper manuscript (LaTeX)
├── slides/                      # Beamer .tex files (metropolis theme)
├── tasks/                       # Task-based DAG (code/input/output per task)
├── Quarto/                      # RevealJS .qmd files + theme
├── docs/                        # GitHub Pages (auto-generated)
├── scripts/                     # Utility scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Papers and existing slides
```

### Task Structure (Dingel Convention)

Each task in `tasks/` follows:
```
tasks/task_name/
├── code/
│   ├── Makefile              # Build rules (include generic.make)
│   └── main.do               # Entry point
├── input/                    # Symlinks to upstream task output/
└── output/                   # Task outputs (.dta, .csv, .png, .tex)
```

Shared build infrastructure:
- `tasks/generic.make` — directory creation, upstream dependency rules
- `tasks/shell_functions.sh` — Stata/Python/R execution wrappers
- `tasks/shell_functions.make` — Make variables for language commands

---

## Commands

```bash
# LaTeX slides (3-pass, XeLaTeX)
cd slides && xelatex -interaction=nonstopmode slides.tex
BIBINPUTS=../bib:$BIBINPUTS bibtex slides
xelatex -interaction=nonstopmode slides.tex
xelatex -interaction=nonstopmode slides.tex

# Or use Make:
cd slides && make

# Stata (run a task via Make)
cd tasks/task_name/code && make

# Stata (run a task directly)
cd tasks/task_name && stata-mp -b do code/main.do

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
| Main | `slides/slides.tex` | -- | Metropolis theme; sections via `\input{sections/*.tex}` |
