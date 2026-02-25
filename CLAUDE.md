# CLAUDE.MD -- Applied Econometrics Research with Claude Code

<!-- HOW TO USE: Replace [BRACKETED PLACEHOLDERS] with your project info.
     Customize Beamer environments for your talk preamble.
     Keep this file under ~150 lines — Claude loads it every session.
     See the guide at docs/workflow-guide.html for full documentation. -->

**Project:** [YOUR PROJECT NAME]
**Institution:** [YOUR INSTITUTION]
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **Single source of truth** -- Paper `main.tex` is authoritative; talks and supplements derive from it
- **Quality gates** -- nothing ships below 80/100 (paper); talks scored as auxiliary
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Paper/                       # Main LaTeX manuscript (source of truth)
│   ├── main.tex                 # Primary paper file
│   └── sections/                # Section-level .tex files
├── Talks/                       # Derivative Beamer presentations
│   ├── job_market_talk.tex      # 45-60 min, full results
│   ├── seminar_talk.tex         # 30-45 min, standard seminar
│   ├── short_talk.tex           # 15 min, conference session
│   └── lightning_talk.tex       # 5 min, spiel/elevator pitch
├── Data/                        # Project data
│   ├── raw/                     # Original untouched data (often gitignored)
│   └── cleaned/                 # Processed datasets ready for analysis
├── Output/                      # Intermediate results (logs, temp files)
├── Figures/                     # Final figures (.pdf, .png) referenced in paper
├── Tables/                      # Final tables (.tex) referenced in paper
├── Supplementary/               # Online appendix and supplements
├── Replication/                 # Replication package for deposit
├── Preambles/header.tex         # LaTeX headers / shared preamble
├── scripts/                     # Utility scripts + R code
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Reference papers and data docs
```

---

## Commands

```bash
# Paper compilation (3-pass, XeLaTeX only)
cd Paper && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex

# Talk compilation
cd Talks && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode talk.tex

# Quality score
python scripts/quality_score.py Paper/main.tex
python scripts/quality_score.py scripts/R/analysis.R
```

---

## Quality Thresholds

| Score | Gate | Applies To |
|-------|------|------------|
| 80 | Commit | Paper, R scripts (blocking) |
| 90 | PR | Paper, R scripts (blocking) |
| 95 | Excellence | Aspirational |
| -- | Advisory | Talks (reported, non-blocking) |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Layout audit |
| `/review-r [file]` | R code quality review |
| `/validate-bib` | Cross-reference citations |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/econometrics-check [file]` | Causal inference design audit |
| `/draft-paper [section]` | Draft paper sections |
| `/respond-to-referee [report]` | Point-by-point referee response |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/pre-analysis-plan [spec]` | Draft PAP (AEA/OSF/EGAP) |
| `/data-deposit` | AEA Data Editor compliance |
| `/audit-replication [dir]` | Validate replication package |
| `/target-journal [paper]` | Journal targeting + submission strategy |
| `/create-talk [format]` | Generate Beamer talk from paper |
| `/paper-excellence [file]` | Combined multi-agent paper review |
| `/devils-advocate [file]` | Challenge presentation design |

---

<!-- CUSTOMIZE: Replace the example entries below with your own
     Beamer environments for talks. -->

## Beamer Custom Environments (Talks)

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| `[your-env]`      | [Description] | [When to use]  |

---

## Current Project State

| Component | File | Status | Description |
|-----------|------|--------|-------------|
| Paper | `Paper/main.tex` | [draft/submitted/R&R] | [Brief description] |
| Data | `scripts/R/` | [complete/in-progress] | [Analysis description] |
| Replication | `Replication/` | [not started/ready] | [Deposit status] |
| Job Market Talk | `Talks/job_market_talk.tex` | -- | [Status] |
