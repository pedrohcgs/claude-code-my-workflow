# Plan: Configure Workflow for "Climate, Coffee & Migration" Thesis

**Status:** COMPLETED
**Date:** 2026-03-31
**Branch:** claude/suspicious-almeida

---

## Context

The user is starting a PhD thesis using satellite data from Google Earth Engine (GEE) to study whether climate degradation, coffee cultivation conditions, or infrastructure changes drive migration to Hawassa Industrial Park in Ethiopia. Their stack is Python (GEE + ML for satellite image analysis), R (statistical analysis), and LaTeX (thesis document — not Beamer presentations).

The forked workflow is configured for lecture-slide development (Beamer + Quarto). We need to re-orient it entirely toward a research thesis while keeping all the infrastructure that still applies (quality gates, plan-first workflow, review agents, orchestrator protocol).

---

## Files to Modify

| File | Change |
|------|--------|
| `CLAUDE.md` | Fill all placeholders; adapt for thesis structure |
| `.claude/agents/domain-reviewer.md` | Customize 5 review lenses for dev econ + satellite ML |
| `.claude/rules/knowledge-base-template.md` | Seed with thesis notation and domain concepts |
| `.claude/rules/single-source-of-truth.md` | Change authoritative artifact from Beamer → thesis .tex |

## Files to Create

| File | Purpose |
|------|---------|
| `.claude/rules/python-conventions.md` | Python code quality rule (GEE, ML, scientific computing) |

---

## Detailed Changes

### 1. CLAUDE.md

Replace template placeholders and restructure for a thesis project:

- **Project:** `Climate, Coffee & Migration: Evidence from Hawassa Industrial Park, Ethiopia`
- **Institution:** `[YOUR INSTITUTION]` — user did not specify; leave as placeholder
- **Core Principles:** Change "Beamer .tex is authoritative; Quarto .qmd derives from it" → "LaTeX thesis chapters are authoritative; figures/tables derive from Python and R scripts"
- **Folder Structure:** Replace `Slides/` with `Chapters/`, add `Data/` for satellite data documentation and `output/` for generated tables/figures. Remove Quarto/ (not needed)
- **Commands block:** Replace Beamer compilation with thesis compilation; add Python GEE command pattern; remove `sync_to_docs.sh` deploy
- **Skills Quick Reference:** Keep research/analysis/writing skills; annotate slide-specific skills as "presentations only" rather than removing (user may need them for thesis defense later)
- **Current Project State:** Replace lecture table with thesis chapters table (seeded with expected chapters)
- **Beamer Environments / Quarto CSS:** Replace with "LaTeX Thesis Environments" and "Python/R Conventions" quick reference
- **Add Python** to the tool stack note

### 2. `.claude/rules/python-conventions.md` (NEW)

Scope: `**/*.py, scripts/**/*.py, scripts/python/**/*.py, gee/**/*.py`

Rules adapted for scientific Python in this domain:
- **Reproducibility:** Pin random seeds (`np.random.seed`, `torch.manual_seed`); use relative paths; no hardcoded credentials or GEE project IDs in code (use config files)
- **GEE patterns:** Always `.getInfo()` only at export time; prefer batch exports over interactive; document temporal windows and spatial resolutions; name assets descriptively
- **ML conventions:** Separate data prep, model training, and evaluation scripts; save model checkpoints to `output/models/`; log confusion matrices and accuracy metrics to `output/metrics/`
- **Code quality:** snake_case functions; docstrings for non-obvious functions; type hints for function signatures; ≤100 char lines (relaxed to 120 for GEE filter chains)
- **Satellite data specifics:** Always document CRS and resolution in comments; clip before processing (not after); assert nodata values before computing indices

### 3. `.claude/agents/domain-reviewer.md`

Customize the 5 lenses for development economics + satellite ML:

- **Lens 1 (Assumption Stress Test):** Add migration/push-pull factor identification checks; SUTVA assumptions for village-level treatment; spatial spillover assumptions; whether climate → migration channel is clearly distinguished from coffee price → migration
- **Lens 2 (Derivation/ML Verification):** Add ML-specific checks: train/test leakage (spatial cross-validation required for satellite data); label quality for image classification; class imbalance in degradation detection; temporal autocorrelation
- **Lens 3 (Citation Fidelity):** Cross-reference against `master_supporting_docs/`; add specific pitfall list for migration/GEE literature (common misattributions in Harris-Todaro lineage)
- **Lens 4 (Code-Data Alignment):** Check Python GEE scripts against analysis description; verify spatial resolution stated in text matches what GEE actually exports; R regressions match estimating equations
- **Lens 5 (Backward Logic Check):** Same structure; add check that migration outcome measure is consistently defined across all chapters

### 4. `.claude/rules/knowledge-base-template.md`

Seed the notation registry with thesis-specific content:

- Migration variables: `m_i` (migration indicator), `d_it` (destination location/firm), `t` (time in years/seasons)
- Climate variables: NDVI (vegetation index), SPEI (drought index), temperature anomaly, precipitation deficit
- Coffee cultivation: yield per hectare, arabica coverage share, altitude band
- Infrastructure: road access (hours to nearest city), industrial park proximity
- Key locations: Sidama zone / SNNPR, Hawassa (treatment), control woredas
- Empirical approach: TBD (leave "ASSUMED: reduced form" with override note)
- Key papers placeholder list for citation verification

### 5. `.claude/rules/single-source-of-truth.md`

Update the authoritative artifact:

- **Authoritative:** `Chapters/*.tex` (LaTeX thesis chapters)
- **Derived:** `Figures/` (generated by Python/R scripts), `output/` (tables generated by R)
- **Script traceability rule:** Every figure in `Figures/` must have a corresponding script in `scripts/`; every table in the thesis must trace to an R script
- Remove TikZ freshness protocol and Beamer/Quarto sync references; add figure provenance tracking

---

## Memory to Save (after plan approval + execution)

- Save user memory: thesis project on Ethiopia migration + GEE + Python + R + LaTeX
- Save project memory: project title, empirical strategy (TBD/ML), stack

---

## Out of Scope for This Plan

- Creating actual `Chapters/`, `Data/`, `output/` directories (they'll be created when first needed)
- Adding data to the bibliography (done when user starts writing)
- Choosing or configuring a LaTeX thesis class (to be decided when user begins writing Chapter 1)
- Configuring GitHub Pages / Quarto deploy (not needed for thesis)

---

## Verification

After execution:
1. Read `CLAUDE.md` and confirm no `[YOUR...]` placeholders remain (except institution)
2. Read `.claude/rules/python-conventions.md` and confirm it exists and is properly scoped
3. Read `domain-reviewer.md` and confirm it references satellite data and migration
4. Check that `single-source-of-truth.md` no longer mentions Beamer as authoritative
5. Read `knowledge-base-template.md` and confirm thesis notation is present
