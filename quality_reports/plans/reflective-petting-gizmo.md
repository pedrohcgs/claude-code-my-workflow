# Plan: Adapt Workflow Configuration for Financial Intermediary Shocks Project

**Status:** COMPLETED
**Date:** 2026-04-14
**Scope:** Configuration adaptation only — no content creation (no slides, no do-files, no paper)

---

## Context

This repo was forked from pedrohcgs/claude-code-my-workflow, a generic academic workflow template. It needs to be adapted for a specific PhD project:

- **Project:** Financial Intermediary Shocks and Firm Heterogeneity
- **Institution:** University College London, Department of Economics
- **Primary tool:** Stata (empirical), Beamer/Quarto (presentations)
- **Goal:** Publication + seminar/job market slides
- **Stata policy:** .do files tracked in repo; .dta data files excluded

---

## Changes

### Step 1: Update CLAUDE.md (fill placeholders + adapt structure)

**File:** `CLAUDE.md`

- Replace `[YOUR PROJECT NAME]` → "Financial Intermediary Shocks and Firm Heterogeneity"
- Replace `[YOUR INSTITUTION]` → "University College London"
- Update folder structure diagram: add `scripts/Stata/` for do-files, `output/` for tables/figures
- Add Stata commands section (how to run do-files from CLI)
- Keep LaTeX commands as-is (still needed for Beamer slides)
- Update "Current Project State" table with planned deliverables (paper + slides, TBD)
- Keep Beamer environments and Quarto CSS class tables as placeholders (no custom envs yet)
- Remove the HTML comments (template instructions) since this is now a working project

### Step 2: Update .gitignore (add Stata + data exclusions)

**File:** `.gitignore`

Add:
```
# Stata
*.dta
*.smcl
*.gph
*.sthlp
*.ster

# Data (too large or sensitive for git)
data/raw/
data/intermediate/
```

Keep existing LaTeX, R, Python, OS, IDE entries (R might be used for figures later).

### Step 3: Create Stata-oriented folder structure

Create directories:
- `scripts/Stata/` — for .do files (with .gitkeep)
- `data/raw/` — for raw datasets (gitignored)
- `data/intermediate/` — for cleaned/merged data (gitignored)
- `data/README.md` — document data sources and how to obtain them (tracked)
- `output/tables/` — for Stata-generated tables (with .gitkeep)
- `output/figures/` — for Stata-generated figures (with .gitkeep)

### Step 4: Add Stata code conventions rule

**File (new):** `.claude/rules/stata-code-conventions.md`

Parallel to `r-code-conventions.md`. Cover:
- Header block conventions (project, author, date, purpose)
- Relative paths only (no `cd "C:\Users\..."`)
- Version control: `version 17` (or user's version) at top
- Logging: `log using`, `log close`
- Reproducibility: `set seed`, `clear all`, `set more off`
- Output: `esttab`/`outreg2` for tables, `graph export` for figures
- Variable naming conventions
- Comment style (`//`, `/* */`, `///` for line continuation)

### Step 5: Update Quarto theme colors to UCL

**File:** `Quarto/theme-template.scss`

Replace Emory colors with UCL brand:
- Primary: `#500778` (UCL Purple)
- Secondary: `#002855` (UCL Dark Blue)
- Accent: `#AC145A` (UCL Bright Pink — for highlights)
- Light background: `#F3F1F5` (light purple tint)
- Keep font choices generic (user can customize later)

### Step 6: Populate knowledge base template with financial economics content

**File:** `.claude/rules/knowledge-base-template.md`

Fill the notation registry with:
- Greek letters: beta (factor loading), alpha (abnormal return), sigma (volatility)
- Key variables: leverage, Tobin's Q, investment/capital ratio, cash flow, credit spreads
- Firm characteristics: size, age, credit rating, financial constraints indices (KZ, WW, SA)
- Intermediary variables: bank capital ratio, broker-dealer leverage, AEM/HKM factors
- Econometric notation: DID, IV, panel FE, clustering conventions

### Step 7: Update memory files

**File:** `C:\Users\S1y\.claude\projects\F--Research-my-project\memory\user_profile.md`

Update institution to UCL, Department of Economics.

---

## Files Modified (summary)

| File | Action | Type |
|------|--------|------|
| `CLAUDE.md` | Edit | Fill placeholders + adapt |
| `.gitignore` | Edit | Add Stata entries |
| `scripts/Stata/.gitkeep` | Create | New directory |
| `data/README.md` | Create | Document data sources |
| `data/raw/.gitkeep` | Create | New directory (gitignored) |
| `data/intermediate/.gitkeep` | Create | New directory (gitignored) |
| `output/tables/.gitkeep` | Create | New directory |
| `output/figures/.gitkeep` | Create | New directory |
| `.claude/rules/stata-code-conventions.md` | Create | New rule |
| `Quarto/theme-template.scss` | Edit | UCL colors |
| `.claude/rules/knowledge-base-template.md` | Edit | Financial econ content |

---

## What We Are NOT Doing

- Not creating any actual Stata do-files, slides, or paper content
- Not removing R infrastructure (scripts/R/, r-code-conventions rule) — may use R for figures
- Not modifying agents or skills — they're generic and work as-is
- Not changing the quality gates, orchestrator, or plan-first rules
- Not populating Bibliography_base.bib (user will add papers as needed)
- Not modifying hooks or settings.json

---

## Verification

1. Confirm CLAUDE.md has no remaining `[BRACKETED PLACEHOLDERS]`
2. Confirm .gitignore correctly excludes .dta files: `git check-ignore test.dta`
3. Confirm all new directories exist
4. Confirm Stata rule loads correctly (path-scoped to scripts/Stata/)
5. Confirm knowledge base has financial economics notation
6. Confirm Quarto theme has UCL colors
