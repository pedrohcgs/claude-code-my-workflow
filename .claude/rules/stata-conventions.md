---
paths:
  - "code/stata/**/*.do"
---

# Stata Conventions

**Stata version:** StataNow 19
**Scope:** Analysis do-files in `code/stata/`

---

## File Header (Required)

Every do-file must start with:

```stata
/*
Do-file: dofile_name.do
Purpose: [One-sentence description]
Inputs:  [data/final/... or data/processed/...]
Outputs: [output/tables/... or output/figures/...]
Author:  [from project context]
Date:    YYYY-MM-DD
*/

version 19
clear all
set more off
```

---

## Log Files

Open a log at the start, close at the end:

```stata
cap log close
log using "output/logs/dofile_name_${S_DATE}.log", replace text
/* ... do-file body ... */
log close
```

---

## Path Management

- **All paths relative to project root** — do-files are run from project root
- Define a global at the top for each major directory:

```stata
global ROOT    ""                         // empty = current directory (project root)
global DATA    "data/final"
global PROC    "data/processed"
global TABLES  "output/tables"
global FIGURES "output/figures"
```

- Reference with: `use "$DATA/firm_panel.dta", clear`
- **Never hardcode** `C:\`, `C:/`, or any drive letter

---

## Reproducibility

- Set seed before any stochastic command (bootstrap, simulate, permutation):
  ```stata
  set seed 20240101
  ```
- Use seed format `YYYYMMDD`
- Always specify `version 19` at the top

---

## Output Discipline

- Use `quietly` for intermediate operations that don't need to appear in the log:
  ```stata
  quietly: regress y x1 x2
  ```
- Use `noisily` or no prefix for output that belongs in the log
- Never leave unintended output (e.g., `list`, `browse`) in production do-files

---

## Table Export

For regression tables, use `estout` or `esttab`:

```stata
esttab m1 m2 m3 using "$TABLES/tab02_main.tex", ///
    replace booktabs label ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Baseline" "Controls" "FE") ///
    stats(N r2, fmt(%9.0fc %9.3f) labels("N" "R²"))
```

Conventions:
- **Star thresholds:** `* 0.10 ** 0.05 *** 0.01`
- **Coefficient format:** 3 decimal places
- **SE format:** 3 decimal places, in parentheses
- **N format:** integer with comma separator
- **booktabs:** always for `.tex` output

---

## Fixed Effects and Clustering

Use `reghdfe` for high-dimensional fixed effects:

```stata
reghdfe outcome controls, absorb(firm_id year) cluster(firm_id)
```

Always document in comments:
- What is absorbed (firm FE, year FE, industry×year FE)
- What level clustering is at, and why

---

## Variable Naming

- Lowercase, underscores: `rd_expense`, `patent_count`, `high_tech_dummy`
- Indicator variables: prefix with `d_` (e.g., `d_treated`)
- Standardized variables: suffix with `_std`
- Lagged variables: suffix with `_l1`, `_l2`
- Winsorized variables: suffix with `_w` (document percentile)

---

## Data Safety

- **Never save over files in `data/raw/`**
- Always use `preserve` / `restore` for temporary sample manipulations
- Document any sample restrictions in comments before the `keep` or `drop` command:
  ```stata
  // Keep firm-years with non-missing R&D expense (required by main model)
  keep if !missing(rd_expense)
  ```

---

## Section Structure

Divide do-files with section headers:

```stata
*==============================================================================
* 1. Load and merge data
*==============================================================================

*==============================================================================
* 2. Variable construction
*==============================================================================

*==============================================================================
* 3. Main regressions
*==============================================================================

*==============================================================================
* 4. Export tables
*==============================================================================
```
