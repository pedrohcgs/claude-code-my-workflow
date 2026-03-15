---
name: data-analysis
description: End-to-end Python + Stata data analysis workflow from raw data through cleaning, regression, and publication-ready tables and figures
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis: load/clean data with Python, analyze with Stata, produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/final/citb_firm_year_2010_2022.dta`) or a description of the analysis goal (e.g., "probit regression of innovation tax benefit application on firm characteristics with industry and year FE").

---

## Constraints

- **Follow conventions** in `.claude/rules/python-conventions.md` and `.claude/rules/stata-conventions.md`
- **Follow data rules** in `.claude/rules/data-management.md`
- **Python scripts** → `code/python/` with descriptive names
- **Stata do-files** → `code/stata/` with descriptive names
- **All outputs** → `output/tables/` or `output/figures/`
- **Run reviewers** on generated code before presenting results

---

## Workflow Phases

### Phase 1: Understand the Data

1. Read `.claude/rules/stata-conventions.md` and `.claude/rules/data-management.md`
2. If starting from raw data: check `data/raw/README.md` for source documentation
3. Load and inspect the dataset: `describe`, `summarize`, `misstable summarize`
4. Note: firm ID format, sample period, key variables present

### Phase 2: Data Cleaning (Python, if needed)

If raw data requires cleaning before Stata analysis:

1. Create Python script in `code/python/` with proper header
2. Set `ROOT` / `RAW` / `PROC` path constants
3. Log row counts at each transformation step
4. Output to `data/processed/` as `.parquet` or `.csv`
5. Run python-reviewer agent on the script

### Phase 3: Stata — Variable Construction and Summary Statistics

Create a Stata do-file with proper header, version, and log. Sections:

1. **Load and merge** — load final dataset, merge auxiliary data if needed; log merge rates
2. **Variable construction** — winsorize, create indicators, lags; document each variable
3. **Summary statistics** — `estpost summarize` → `esttab` to `output/tables/tab01_summary.tex`
4. **Correlation table** if relevant

### Phase 4: Stata — Main Regressions

Based on the research question:

- **Binary outcome** (e.g., application = 0/1): Probit/Logit with `margins` for average marginal effects
- **Continuous outcome**: OLS with `reghdfe` for fixed effects
- **Standard errors**: cluster at firm level; document in comments
- **Multiple specifications**: baseline → add controls → add FE → preferred specification

### Phase 5: Publication-Ready Output

**Tables (Stata):**
```stata
esttab m1 m2 m3 using "$TABLES/tab02_main.tex", ///
    replace booktabs label ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2_p, fmt(%9.0fc %9.3f) labels("N" "Pseudo R²"))
```

**Figures (Stata or Python):**
- Export at 300 DPI minimum
- Use `.emf` for Word insertion, `.pdf` for archival
- Label axes clearly (sentence case, units in parentheses)

### Phase 6: Review and Verify

1. Run stata-reviewer agent on the generated do-file:
   ```
   Delegate to stata-reviewer: "Review code/stata/[dofile].do"
   ```
2. If Python cleaning script was written, run python-reviewer agent
3. Address any Critical or Major issues before presenting results
4. Verify outputs exist and have non-zero size

---

## Do-File Structure Template

```stata
/*
Do-file: [name].do
Purpose: [description]
Inputs:  data/final/[file].dta
Outputs: output/tables/[table].tex, output/figures/[fig].emf
Author:  [from project context]
Date:    YYYY-MM-DD
*/

version 19
clear all
set more off

global DATA    "data/final"
global TABLES  "output/tables"
global FIGURES "output/figures"

cap log close
log using "output/logs/[name]_${S_DATE}.log", replace text

*=============================================================================
* 1. Load data
*=============================================================================

use "$DATA/citb_firm_year_2010_2022.dta", clear

*=============================================================================
* 2. Variable construction
*=============================================================================

*=============================================================================
* 3. Summary statistics
*=============================================================================

*=============================================================================
* 4. Main regressions
*=============================================================================

*=============================================================================
* 5. Export tables and figures
*=============================================================================

log close
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to regression.
- **Use relative paths.** All paths relative to repository root.
- **No hardcoded values.** Use globals/locals for sample restrictions, date ranges, etc.
- **Document every sample restriction** in a comment before the `keep` or `drop`.
