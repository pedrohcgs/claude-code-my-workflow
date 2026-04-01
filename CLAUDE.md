# CLAUDE.MD -- RetPartner: PCAOB Engagement Partner-Revelio LinkedIn Linkage

**Project:** RetPartner
**Institution:** MIT
**Branch:** main
**Languages:** Python, Stata

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- run scripts and confirm outputs at the end of every task
- **Single source of truth** -- raw data in `data/raw/` is authoritative; all processed data derives from it via reproducible scripts
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to MEMORY.md

---

## Project Goal

Link engagement partners in PCAOB Form AP filings to their Revelio Labs LinkedIn IDs. Maximize the number of matched partners with high confidence.

### Data Pipeline Stages

1. **Ingest** -- parse/clean Form AP data from PCAOB
2. **Standardize** -- normalize partner names, firm names, locations
3. **Match** -- link partners to Revelio LinkedIn profiles (fuzzy matching, firm+name combos)
4. **Validate** -- manual review of uncertain matches, quality metrics
5. **Output** -- final linked dataset for downstream analysis

---

## Folder Structure

```
RetPartner/
+-- CLAUDE.MD                    # This file
+-- .claude/                     # Rules, skills, agents, hooks
+-- data/
|   +-- raw/                     # Original Form AP + Revelio data (never modify)
|   +-- processed/               # Cleaned/intermediate datasets
|   +-- output/                  # Final matched datasets
+-- scripts/
|   +-- python/                  # Python scripts (.py)
|   +-- stata/                   # Stata do-files (.do)
+-- output/
|   +-- figures/                 # Publication-ready figures
|   +-- tables/                  # Publication-ready tables
+-- explorations/                # Research sandbox (see rules)
+-- quality_reports/             # Plans, session logs, merge reports
+-- templates/                   # Session log, quality report templates
+-- master_supporting_docs/      # Reference papers and documentation
+-- docs/                        # Project documentation
```

---

## Commands

```bash
# Python
python scripts/python/script_name.py

# Stata (adjust binary name for your installation)
stata-mp -b do scripts/stata/script_name.do

# Quality score
python scripts/quality_score.py scripts/python/file.py
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for review |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/commit [msg]` | Stage, commit, PR, merge |
| `/data-analysis [dataset]` | End-to-end Python analysis |
| `/data-linkage [task]` | Run matching pipeline, report match rates |
| `/review-python [file]` | Python code quality review |
| `/review-stata [file]` | Stata code quality review |
| `/deep-audit` | Repository-wide consistency audit |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |

---

## Python Conventions (Summary)

- PEP 8 style, `snake_case` naming
- Type hints for public function signatures
- Docstrings for all public functions (Google style)
- `pathlib.Path` for all file paths, relative to project root
- Logging via `logging` module (not `print()` for status messages)
- All packages imported at top of file
- `if __name__ == "__main__":` guard for executable scripts
- See `.claude/rules/python-code-conventions.md` for full standards

## Stata Conventions (Summary)

- Standard header block (purpose, author, date, inputs, outputs)
- `log using` at start, `log close` at end
- Relative paths only (no hardcoded absolute paths)
- `set seed` for any randomized operations
- See `.claude/rules/stata-code-conventions.md` for full standards

---

## Current Project State

| Stage | Status | Key Files | Notes |
|-------|--------|-----------|-------|
| 1: Ingest | Not started | -- | Form AP data already downloaded |
| 2: Standardize | Not started | -- | Name/firm normalization |
| 3: Match | Not started | -- | Core linkage logic |
| 4: Validate | Not started | -- | Quality review |
| 5: Output | Not started | -- | Final dataset |
