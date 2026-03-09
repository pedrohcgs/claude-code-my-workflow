# CLAUDE.MD -- Nepal & Global Energy Economics Research

<!-- This project uses the pedrohcgs/claude-code-my-workflow template.
     Primary artifacts: literature review documents + research proposals (NOT slides).
     Beamer/Quarto/TikZ rules are inactive for this project but preserved for template users. -->

**Project:** Nepal & Global Energy Economics Research
**Institution:** Carthage
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- render/check output at the end of every task
- **Single source of truth** -- `literature/` for paper notes, `proposals/` for output drafts
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
my-project/
├── CLAUDE.md                    # This file
├── MEMORY.md                    # Persistent learnings across sessions
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── Figures/                     # Figures and images
├── Preambles/header.tex         # Minimal LaTeX header (for PDF outputs)
├── literature/                  # Paper notes and synthesis tables
│   ├── README.md                # Protocol for adding paper summaries
│   ├── global/                  # Global energy economics papers
│   └── nepal/                   # Nepal-specific papers
├── proposals/                   # Research proposals output
│   └── README.md                # Proposal template guidance
├── explorations/                # Research idea sandbox
├── scripts/R/                   # Quantitative analysis scripts
├── quality_reports/             # Plans, session logs, specs, merge reports
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Key reference papers (PDFs)
```

---

## Commands

```bash
# Quality score (primary artifact check)
python scripts/quality_score.py proposals/your_proposal.md

# R analysis
cd scripts/R && Rscript analysis.R

# Quarto render (HTML/PDF lit review output)
quarto render literature/synthesis.qmd

# LaTeX (for PDF proposal output, if needed — 3-pass XeLaTeX)
cd proposals && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | Share | Ready for advisor/collaborator review |
| 95 | Excellence | Aspirational — submit-ready |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/lit-review [topic]` | Literature search + synthesis (PRIMARY) |
| `/research-ideation [topic]` | Research questions + strategies (PRIMARY) |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/proofread [file]` | Grammar/typo/writing quality review |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/devils-advocate` | Challenge research design |
| `/validate-bib` | Cross-reference citations |
| `/review-r [file]` | R code quality review |

*Inactive for this project (template preserved): `/compile-latex`, `/deploy`, `/extract-tikz`,
`/visual-audit`, `/pedagogy-review`, `/qa-quarto`, `/translate-to-quarto`, `/slide-excellence`,
`/create-lecture`*

---

## Current Project State

| Artifact | File | Status | Notes |
|----------|------|--------|-------|
| Global energy lit review | `literature/global/` | Not started | Target: 2023–2026 papers |
| Nepal energy lit review | `literature/nepal/` | Not started | Focus: hydropower, NEA, transitions |
| Synthesis document | `literature/synthesis.md` | Not started | Cross-sector comparisons |
| Research proposal 1 | `proposals/` | Not started | TBD after lit review |
| Research proposal 2 | `proposals/` | Not started | TBD after lit review |
| Research proposal 3 | `proposals/` | Not started | TBD after lit review |

---

## Workflow Notes

### What differs from template defaults

| Template Default | This Project |
|-----------------|--------------|
| Primary artifact = Beamer slides | Primary artifact = lit review docs + proposals |
| `/compile-latex` as main command | `/lit-review` + `/research-ideation` as main commands |
| Beamer-Quarto sync mandatory | Not applicable (no slides initially) |
| TikZ visual quality rules | Not applicable |
| Pedagogy review | Not applicable for research docs |

### What stays the same
- Plan-first workflow for all non-trivial tasks
- Contractor mode after plan approval
- Adversarial QA (critic-fixer loop) for research proposals
- Context survival (pre-compact hook, MEMORY.md)
- Exploration sandbox in `explorations/` for research ideas
- 80/90/95 quality gates applied to proposals and synthesis documents
