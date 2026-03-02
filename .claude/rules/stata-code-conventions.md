---
paths:
  - "code/stata/**/*.do"
---

# Stata Code Standards

**Standard:** Senior economist / replication-ready quality

---

## 1. File Header Block

Every do-file must begin with a standard header:

```stata
/*===========================================================================
  File:    [filename].do
  Purpose: [one sentence]
  Inputs:  data/processed/[input files]
  Outputs: data/outputs/[output files] or data/processed/[output files]
  Author:  [author]
  Date:    [YYYY-MM-DD]
  Notes:   [any important caveats]
===========================================================================*/
```

---

## 2. Reproducibility

- `set seed 20260101` called **once at the top** (stochastic simulations only; include it always for safety)
- All paths relative to repository root via a global:
  ```stata
  global root "path/to/repo"   // set once; adjust for machine
  ```
- No hardcoded absolute paths anywhere else in the file
- `capture mkdir` for output directories before writing

---

## 3. Panel Data Setup

Always declare panel structure **before any panel command**:

```stata
xtset countrycode year, yearly
```

Failure to call `xtset` causes Stata to silently run pooled OLS instead of panel regression.

---

## 4. Standard Errors

**Default for this project:** Country-level clustering.

```stata
vce(cluster countrycode)
```

Use `vce(robust)` only for cross-sectional regressions. Document any deviation from clustering.

---

## 5. Variable Labels and Documentation

- `label variable varname "description (units if applicable)"` for every generated variable
- `label define` + `label values` for all categorical variables
- Use `notes varname: ...` to document non-obvious transformations:
  ```stata
  notes exposure_chl: "FVA-weighted average seg score, OECD ICIO 2025, Chile only"
  ```

---

## 6. Merge Safety

Always verify merges explicitly:

```stata
merge 1:1 countrycode year using "data/processed/geopolitics_scores.dta"
assert _merge == 3   // hard fail if any unmatched
drop _merge
```

If partial merge is expected, document with a comment and explicitly handle `_merge != 3`.

---

## 7. Regression Tables

Use `esttab` / `estout` for all regression tables. Never construct tables manually.

```stata
eststo clear
eststo m1: xtreg exposure_chl gdpgrowth trade_openness, fe vce(cluster countrycode)
eststo m2: xtreg exposure_chl gdpgrowth trade_openness seg_chl, fe vce(cluster countrycode)
esttab m1 m2 using "data/outputs/table1.tex", ///
    replace booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 1: Geopolitical Exposure and Economic Outcomes")
```

---

## 8. `gen` vs `replace` Pattern

Always `capture drop` before `gen` to avoid "variable already defined" errors:

```stata
capture drop exposure_index
gen exposure_index = .
```

Or use `replace` explicitly when updating existing variables.

---

## 9. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Forgetting `xtset` before `xtreg` | Silent pooled OLS | Always call `xtset countrycode year` at do-file top |
| `gen` without `capture drop` | "already defined" error if re-run | Use `capture drop varname` before `gen` |
| Silent `_merge == 2` rows | Unmatched rows kept, corrupt dataset | Always `assert _merge == 3` after merge |
| Hardcoded paths | Breaks on other machines | Use `global root` for all paths |
| Using default SE (no clustering) | Understated SE in panel data | Always `vce(cluster countrycode)` |
| Missing `label variable` | Unreadable output tables | Label every generated variable |
| Running `xtreg` without FE specification | Wrong model (pooled vs FE) | Always explicitly write `, fe` or `, re` |

---

## 10. Code Quality Checklist

```
[ ] Header block present (file, purpose, inputs, outputs, author, date)
[ ] set seed 20260101 at top
[ ] global root defined; no hardcoded absolute paths
[ ] xtset called before any panel command
[ ] vce(cluster countrycode) on all panel regressions
[ ] All generated variables labeled
[ ] All merges verified with assert _merge == 3 (or documented)
[ ] Regression tables via esttab (not manual)
[ ] Output files written to data/outputs/ or Figures/
[ ] Script runs cleanly from top to bottom on a clean dataset
```
