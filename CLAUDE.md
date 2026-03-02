# [PROJECT NAME]

[One-sentence description of the research project and its core question.]

Institution: Macquarie University
Branch: main

---

## Project setup checklist (first session)

1. Drop existing project files into `project/`
2. Fill in the sections below (research question, data, folder structure)
3. If using Dropbox: `bash templates/setup-sync.sh` then `bash sync-pull.sh`
4. Run `/compile-latex` on a test file to verify MikTeX works
5. Delete this checklist section

---

## Core principles

- Plan first --- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- Verify after --- compile/run and confirm output at the end of every task
- Quality gates --- nothing ships below 80/100
- [LEARN] tags --- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder structure

```
repo/
├── CLAUDE.md                    # This file (project-specific)
├── MEMORY.md                    # Persistent learnings
├── bibliography.bib             # Shared bibliography
├── preambles/header.tex         # Beamer preamble (Metropolis)
├── slides/                      # Beamer .tex files
├── figures/                     # Static images
├── scripts/
│   ├── python/                  # Python analysis scripts
│   └── stata/
│       └── logs/                # Stata log files
├── quality_reports/             # Plans, session logs
├── explorations/                # Research sandbox
├── master_supporting_docs/      # Reference papers
└── project/                     # YOUR PROJECT FILES (Dropbox sync target)
```

All skills, agents, rules, and hooks are inherited from `~/.claude/` and apply automatically. No project-level `.claude/` directory needed for generic infrastructure.

---

## Project-specific context

### Research question

[What is the main research question?]

### Data sources

[Describe the data: source, access, unit of observation, time period.]

### Key variables

[List the main dependent and independent variables.]

---

## File structure map

<!-- Explore project/ on first session and fill this in. -->

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

# Stata (cd into script directory so log lands there)
cd scripts/stata && stata-mp -b do analysis.do
```

---

## Beamer custom environments

| Environment | Effect | Use case |
|-------------|--------|----------|
| `keybox` | Gold background box | Key takeaways |
| `highlightbox` | Teal left-accent box | Highlights |
| `definitionbox[Title]` | Navy titled box | Formal definitions |

---

## Field-specific principles

<!-- Add domain-specific constraints, e.g.: -->
<!-- - "All monetary values in 2020 USD" -->
<!-- - "Cluster standard errors at the village level" -->
<!-- - "ITT estimates unless otherwise specified" -->

---

## Current project state

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| Slides | `slides/` | | |
| Data | `project/data/` | | |
| Analysis | `scripts/` | | |
