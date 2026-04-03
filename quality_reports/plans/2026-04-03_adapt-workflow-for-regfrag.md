# Plan: Adapt Workflow Configuration for RegFrag Project

**Status:** COMPLETED
**Date:** 2026-04-03

---

## Context

This repo was forked from `pedrohcgs/claude-code-my-workflow` — a template for academic projects with Claude Code. It needs to be customized for the **Regulatory Fragmentation and Voluntary Disclosure** research project (accounting journal paper targeting TAR/JAR/JAE).

**Key decisions from user:**
- Manuscript (LaTeX paper) will live in this repo
- This repo IS the main project; `Ji_RegFrag_Replication/` is legacy pipeline (Steps 1-9)
- Keep all slide infrastructure (for future conference presentations)
- Target: Top-3 Accounting journals

---

## Changes

### 1. Update CLAUDE.md — Fill Placeholders & Adapt for Research

**File:** `CLAUDE.md`

- Replace `[YOUR PROJECT NAME]` → "Regulatory Fragmentation and Voluntary Disclosure"
- Replace `[YOUR INSTITUTION]` → "Boston College"
- Update folder structure diagram to reflect actual project layout (add `Manuscript/`, `Data/`, `scripts/R/`, `scripts/Python/`)
- Replace Beamer/Quarto environment tables with a note: "Slide environments TBD — see template defaults for when conference presentations begin"
- Replace lecture state table with **research milestone table**:
  - Data Pipeline (complete — in Ji_RegFrag_Replication/)
  - Literature Review, Manuscript Draft, Analysis, Robustness
- Add **project-specific context** section: server info, data locations, relationship to replication repo (pull key info from root `~/CLAUDE.md`)
- Update LaTeX commands section: add manuscript compilation (pdflatex or xelatex for `Manuscript/main.tex`), keep existing Beamer commands
- Update Skills Quick Reference to highlight research-relevant skills at top

### 2. Create Folder Structure

Create these new directories (with `.gitkeep` where empty):

```
Manuscript/           # LaTeX paper
  sections/           # \input{} files (intro, lit review, methodology, results, etc.)
Data/                 # Data storage
  raw/                # Not committed (large/sensitive)
  processed/          # Not committed
  metadata/           # Data dictionaries — committed
scripts/
  R/                  # R analysis scripts
  Python/             # Python scripts (if needed)
  shell/              # HPC/SLURM scripts
```

Keep existing: `Slides/`, `Quarto/`, `Figures/`, `Preambles/` (for future presentations).

### 3. Update .gitignore — Add Research Data Patterns

**File:** `.gitignore`

Add sections for:
- `Data/raw/**` and `Data/processed/**` (keep `.gitkeep` and README)
- `*.rds` (large R objects)
- SLURM outputs (`slurm-*.out`)
- Unblinded manuscripts
- Python venv

### 4. Customize r-code-conventions.md — BC Colors & Manuscript Dimensions

**File:** `.claude/rules/r-code-conventions.md`

- Replace Emory palette with **Boston College colors** (maroon `#872034`, gold `#EAAA00`)
- Update figure dimensions: `width = 6.5, height = 4, dpi = 300` (single-column journal format)
- Add accounting/finance common pitfalls (e.g., winsorization, clustering at firm level)

### 5. Customize domain-reviewer.md — Accounting/Finance Focus

**File:** `.claude/agents/domain-reviewer.md`

Update the 5 review lenses for accounting research:
1. **Econometric specification** — correct estimators, proper controls, endogeneity concerns
2. **Regulatory accuracy** — SEC rule interpretations, regulatory timeline correctness
3. **Disclosure measurement** — earnings guidance coding, voluntary disclosure proxies
4. **Citation fidelity** — engagement with RegFrag and guidance literatures
5. **Internal consistency** — hypotheses align with tests, results support conclusions

### 6. Update quality-gates.md — Add Research Tolerance Thresholds

**File:** `.claude/rules/quality-gates.md`

Fill in the tolerance thresholds section:
- Point estimates: `< 0.001` (accounting studies report 3 decimal places)
- Standard errors: `< 0.01` (clustered SEs can vary slightly)
- Sample sizes: exact match

### 7. Update Bibliography

**File:** `Bibliography_base.bib`

Keep the filename (it's referenced by existing infrastructure). Add a header comment noting this is for the RegFrag project and the naming convention.

### 8. Save User Profile & Project Memories

Create memory files in `.claude/projects/...`:
- **User memory:** PhD student at Boston College, accounting/finance, R + Python + LaTeX, targets top-3 journals, values precision and rigor
- **Project memory:** RegFrag project details — replication pipeline status, server info, data locations
- **Feedback memory:** Structured/precise collaboration style, publication-ready visuals, don't repeat guidance

### 9. Update MEMORY.md — Add Project-Specific Section

**File:** `MEMORY.md`

Append a "RegFrag Project" section with initial context about the research setup. Keep all existing generic learnings.

---

## Files Modified

| File | Action |
|------|--------|
| `CLAUDE.md` | Major rewrite — fill placeholders, adapt structure |
| `.gitignore` | Add research data patterns |
| `.claude/rules/r-code-conventions.md` | BC colors, manuscript dims, accounting pitfalls |
| `.claude/agents/domain-reviewer.md` | Accounting/finance review lenses |
| `.claude/rules/quality-gates.md` | Research tolerance thresholds |
| `Bibliography_base.bib` | Add project header |
| `MEMORY.md` | Append project section |

## Directories Created

| Directory | Purpose |
|-----------|---------|
| `Manuscript/` | LaTeX paper |
| `Manuscript/sections/` | Input files for paper sections |
| `Data/raw/` | Raw data (gitignored) |
| `Data/processed/` | Processed data (gitignored) |
| `Data/metadata/` | Data dictionaries |
| `scripts/R/` | R analysis scripts |
| `scripts/Python/` | Python scripts |
| `scripts/shell/` | HPC/SLURM scripts |

## NOT Changed (Intentional)

- Slide-specific agents, skills, rules — kept for future conference use
- `Slides/`, `Quarto/`, `Preambles/` directories — kept
- Hooks and settings.json — already well-configured
- Generic MEMORY.md entries — still applicable

---

## Verification

1. All `[BRACKETED PLACEHOLDERS]` removed from CLAUDE.md
2. New directories exist with `.gitkeep` files
3. `.gitignore` correctly excludes `Data/raw/`, `Data/processed/`
4. R color palette references BC maroon/gold
5. Domain reviewer references accounting/finance concepts
6. Memory files created and indexed in MEMORY.md
