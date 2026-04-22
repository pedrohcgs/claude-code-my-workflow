# AGENTS.md -- Academic Project Development with Codex

**Project:** [YOUR PROJECT NAME]
**Institution:** [YOUR INSTITUTION]
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile, render, or run the relevant pipeline before closing a task
- **Single source of truth** -- Beamer `.tex` is authoritative; Quarto `.qmd` derives from it
- **Quality gates** -- nothing ships below 80/100 when a workflow calls the scorer
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to [MEMORY.md](MEMORY.md)

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```text
[YOUR-PROJECT]/
|- AGENTS.md
|- .agents/skills/              # Codex skill surface
|- .claude/                     # Legacy Claude source of rules, hooks, references, settings
|- .codex/agents/               # Codex custom agents
|- Bibliography_base.bib
|- Figures/
|- Preambles/
|- Slides/
|- Quarto/
|- docs/
|- scripts/
|  |- R/
|  |- python/
|  `- stata/
|- quality_reports/
|- explorations/
|- templates/
`- master_supporting_docs/
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX only)
cd Slides && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Deploy Quarto to GitHub Pages
./scripts/sync_to_docs.sh LectureN

# Quality score
python scripts/quality_score.py Quarto/file.qmd
python scripts/quality_score.py scripts/python/03_analyze.py
python scripts/quality_score.py scripts/stata/03_analyze.do
python scripts/quality_score.py scripts/R/03_analyze.R

# Setup validation
./scripts/validate-setup.sh
```

**Palette contract:** color names in `Preambles/header.tex` must match SCSS variables in `Quarto/theme-template.scss`. See [`Preambles/README.md`](Preambles/README.md).

---

## Quality Thresholds

| Score | Checkpoint | Meaning |
| --- | --- | --- |
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

These thresholds are advisory unless enforced by the active workflow.

---

## Skills Quick Reference

| Skill | What It Does |
| --- | --- |
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/deploy [LectureN]` | Render Quarto + sync to docs/ |
| `/extract-tikz [LectureN]` | TikZ -> PDF -> SVG |
| `/new-diagram [snippet] [output.tex]` | Scaffold a new TikZ diagram |
| `/proofread [file]` | Grammar, typo, overflow, and consistency review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, and pacing review |
| `/qa-quarto [LectureN]` | Adversarial Quarto vs Beamer parity QA |
| `/slide-excellence [file]` | Combined multi-lens slide review |
| `/translate-to-quarto [file]` | Beamer -> Quarto translation |
| `/validate-bib` | Citation and bibliography checks |
| `/review-paper [file]` | Manuscript review |
| `/respond-to-referees [report] [manuscript]` | Response-to-referees drafting |
| `/seven-pass-review [file]` | Seven-pass manuscript review |
| `/verify-claims [file]` | Chain-of-Verification fact-check |
| `/lit-review [topic]` | Literature search and synthesis |
| `/research-ideation [topic]` | Research questions and empirical strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/data-analysis-python [dataset]` | End-to-end Python empirical workflow |
| `/data-analysis-stata [dataset]` | End-to-end Stata empirical workflow |
| `/data-analysis-r [dataset]` | End-to-end R empirical workflow |
| `/data-analysis [dataset]` | Legacy R compatibility entry point |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata do-file review |
| `/review-r [file]` | R code quality review |
| `/audit-reproducibility [paper]` | Numeric claim verification against outputs |
| `/devils-advocate` | Challenge slide design choices |
| `/create-lecture` | Create a new lecture scaffold |
| `/commit [msg]` | Stage, commit, PR, and merge workflow |
| `/context-status` | Session health and context status |
| `/deep-audit` | Repository-wide infrastructure audit |
| `/permission-check` | Diagnose Codex approval behavior |
| `/learn [skill-name]` | Extract a reusable workflow into a skill |

---

## Codex Compatibility

**Available skills**

- Slides and teaching: `/proofread`, `/visual-audit`, `/pedagogy-review`, `/slide-excellence`, `/qa-quarto`, `/translate-to-quarto`, `/extract-tikz`, `/new-diagram`, `/create-lecture`, `/devils-advocate`
- Manuscripts and research: `/review-paper`, `/seven-pass-review`, `/respond-to-referees`, `/verify-claims`, `/lit-review`, `/research-ideation`, `/interview-me`
- Empirical workflows: `/data-analysis-python`, `/data-analysis-stata`, `/data-analysis-r`, `/data-analysis`, `/review-python`, `/review-stata`, `/review-r`, `/audit-reproducibility`, `/validate-bib`
- Workflow and repo maintenance: `/compile-latex`, `/deploy`, `/commit`, `/deep-audit`, `/permission-check`, `/context-status`, `/learn`

**Available Codex custom agents**

- `proofreader`, `claim-verifier`, `verifier`, `r-reviewer`
- `slide-auditor`, `pedagogy-reviewer`, `tikz-reviewer`
- `editor`, `domain-referee`, `methods-referee`, `domain-reviewer`
- `quarto-critic`, `quarto-fixer`, `beamer-translator`

**When to use subagents**

- Use subagents for parallel specialist work such as multi-lens slide review, simulated peer review, or independent verification.
- Do not use subagents for routine single-file edits, simple compile checks, or straightforward workflow execution where one agent can finish the task directly.
- Treat `domain-reviewer` as a template role until customized for the field.

**Common academic workflows**

- Proofreading: run `/proofread path/to/file.tex` or `/proofread path/to/file.qmd`
- LaTeX compile check: run `/compile-latex Lecture01_Topic`
- Replication check: run `/audit-reproducibility path/to/manuscript.tex [outputs-dir]`
- Python review: run `/review-python scripts/python/03_analyze.py`
- Stata review: run `/review-stata scripts/stata/03_analyze.do`
- R review: run `/review-r scripts/R/03_analyze.R`
- Python empirical workflow: run `/data-analysis-python data/your_file.csv`
- Stata empirical workflow: run `/data-analysis-stata data/your_file.dta`
- R empirical workflow: run `/data-analysis-r data/your_file.csv`
- Manuscript quality audit: run `/review-paper paper.tex` or `/seven-pass-review paper.tex`

**Compatibility notes**

- `.agents/skills/` is the Codex skill surface for this repo.
- `.claude/` remains the legacy source of rules, hooks, references, and Claude-specific settings. Do not delete it.
- `.codex/agents/` holds Codex-native reusable reviewer and verifier roles.

---

## Beamer Custom Environments

| Environment | Effect | Use Case |
| --- | --- | --- |
| `[your-env]` | [Description] | [When to use] |
| `keybox` | Gold background box | Key points |
| `definitionbox[Title]` | Blue-bordered titled box | Formal definitions |

## Quarto CSS Classes

| Class | Effect | Use Case |
| --- | --- | --- |
| `[.your-class]` | [Description] | [When to use] |
| `.smaller` | 85% font | Dense content |
| `.positive` | Green bold | Good annotations |

---

## Current Project State

| Lecture | Beamer | Quarto | Key Content |
| --- | --- | --- | --- |
| HelloWorld | `HelloWorld.tex` | `HelloWorld.qmd` | Minimal deck to verify setup |
| 1: [Topic] | `Lecture01_Topic.tex` | `Lecture1_Topic.qmd` | [Brief description] |
