---
paths:
  - "scripts/stata/**/*.do"
  - "explorations/**/*.do"
---

# Stata Code Standards

**Standard:** Reproducible, well-documented do-files for data processing and analysis.

---

## 1. Header Block (Required)

Every do-file starts with:

```stata
/*==============================================================================
  Script:   descriptive_name.do
  Purpose:  What this script does
  Inputs:   data/raw/form_ap.dta
  Outputs:  data/processed/cleaned_partners.dta
  Author:   [name]
  Date:     YYYY-MM-DD
  Notes:    Any special dependencies or assumptions
==============================================================================*/
```

## 2. Setup Block

```stata
clear all
set more off
cap log close

* Set project root (relative paths from here)
global root "."

* Start log
log using "${root}/scripts/stata/logs/descriptive_name.log", replace text
```

## 3. Path Conventions

- Use `global root` set once at top; all subsequent paths relative to it
- Never hardcode absolute paths (e.g., `C:\Users\...`)
- Store intermediate data in `${root}/data/processed/`
- Store final output in `${root}/data/output/`

## 4. Merge Diagnostics (Critical)

After every merge, report diagnostics:

```stata
merge m:1 partner_name firm_name using "${root}/data/processed/revelio_lookup.dta"
tab _merge
* Log unmatched observations
count if _merge == 1
count if _merge == 2
count if _merge == 3
drop _merge
```

- Never drop `_merge` without first inspecting it
- Log match rates at each merge step

## 5. Data Quality Checks

- `describe` and `summarize` after loading data
- Check for duplicates: `duplicates report` or `isid`
- Check for missing values in key variables
- Assert expected conditions: `assert _N > 0`, `assert partner_id != .`

## 6. Reproducibility

- `set seed [number]` before any randomized operations
- Version control: `version 17` (or your Stata version) at top if needed
- Save datasets with `compress` before `save`

## 7. Code Quality Checklist

```
[ ] Header block with purpose, inputs, outputs
[ ] log using at start, log close at end
[ ] Relative paths only (global root)
[ ] Merge diagnostics (tab _merge) after every merge
[ ] Duplicate checks on key identifiers
[ ] No hardcoded absolute paths
[ ] Comments explain WHY, not WHAT
```
