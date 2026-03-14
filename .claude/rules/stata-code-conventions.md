---
paths:
  - "do/**/*.do"
---

# Stata Code Conventions — mh_layoff

These conventions apply whenever you read, write, or review any `.do` file in the `do/` directory.

---

## File Header Standard

Every do-file must begin with a header block:

```stata
/*******************************************************************************
Project:  mh_layoff — Mental Health Effects of Layoffs
File:     [filename].do
Author:   [author name]
Created:  YYYY-MM-DD
Updated:  YYYY-MM-DD
Stata:    [version, e.g., 17.0]

Purpose:  [One-sentence description of what this file does]
Inputs:   [data files consumed]
Outputs:  [data/tables/figures produced]
*******************************************************************************/
```

---

## Master Do-File Pattern

`do/master.do` is the single entry point for all analysis. It must:

1. Set the global root path:
   ```stata
   global root "path/to/mh_layoff"   // ONLY absolute path in the codebase
   ```
2. Set seed once (never re-set in sub-files):
   ```stata
   set seed XXXXX
   ```
3. Call all sub-do-files in order:
   ```stata
   do "$root/do/01_clean.do"
   do "$root/do/02_analysis.do"
   // ...
   ```

---

## Path Management

- **No absolute paths** in any file except `do/master.do` (the `global root` line).
- All paths in sub-do-files use `$root`:
  ```stata
  use "$root/data/clean/hilda_panel.dta", clear
  estout using "$root/do/output/table1.tex", replace
  ```
- Never hardcode drive letters or usernames (breaks reproducibility across machines).

---

## Stata Settings

Before changing `set` options that affect other code, preserve and restore:

```stata
preserve
set more off
// ... your code ...
restore
```

Always include at the top of do-files (or in master):

```stata
set more off
set linesize 120
version 17   // or your Stata version
```

---

## Data Integrity

- **Never overwrite raw HILDA files.** All transformations work on copies.
- Raw data lives in `data/raw/` (gitignored); cleaned data in `data/clean/` (also gitignored).
- Document every transformation with a comment explaining why, not just what:
  ```stata
  // Drop observations with missing MH score in all waves (cannot impute, n=XXX)
  drop if mh_missing_all == 1
  ```
- Label all variables and value labels:
  ```stata
  label variable mh_ghq "GHQ-12 mental health score (0–36)"
  label define laid_off_lbl 0 "Not laid off" 1 "Laid off"
  label values laid_off laid_off_lbl
  ```

---

## Panel Data Setup

Always `xtset` before any panel commands; never assume it carries over from a prior do-file:

```stata
xtset id wave
```

Use `tsfill` carefully — document explicitly when filling gaps vs. leaving them:

```stata
// Fill balanced panel gaps; MH outcome coded as missing (.) for imputed periods
tsfill, full
```

---

## Estimation Commands

Comment every `reghdfe`, `csdid`, or `did_imputation` call with the model equation it implements:

```stata
// ATT: Y_{it} = alpha_i + delta_t + sum_l beta_l * D_{it}^l + epsilon_{it}
// FE: individual (id) + time (wave); SE clustered at individual level
reghdfe mh_ghq ibn.rel_time, absorb(id wave) cluster(id)

// Callaway-Sant'Anna ATT(g,t) — no-anticipation + parallel trends
// Ref: Callaway & Sant'Anna (2021, JoE)
csdid mh_ghq, ivar(id) tvar(wave) gvar(g_layoff) notyet
```

---

## Output Tables

- Always use `esttab` / `estout` with consistent options; never deliver raw `.log` as a result.
- Store estimates with meaningful names:
  ```stata
  eststo m1_baseline
  eststo m2_controls
  esttab m1_baseline m2_controls using "$root/do/output/table1.tex", ///
      replace booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
      title("Event-study estimates: Mental Health Effects of Layoffs")
  ```

---

## Factor Variables and Relative Time

Use factor variable syntax for event-study specifications:

```stata
// Relative time indicators (omit l = -1 as reference period)
reghdfe mh_ghq ibn.rel_time, absorb(id wave) cluster(id)

// OR explicit omit:
reghdfe mh_ghq ib(-1).rel_time, absorb(id wave) cluster(id)
```

Never manually create dummies when factor syntax is available — it is less error-prone and self-documenting.

---

## Known Pitfalls

| Pitfall | Impact | Fix |
|---------|--------|-----|
| Forgetting `xtset` before `xtreg`/`xtfill` | Error or wrong results | Always `xtset id wave` at top of estimation do-files |
| `tsfill` creates spurious obs | Inflates panel, wrong N | Only use when intentionally balancing; document why |
| Factor syntax `i.rel_time` vs `ibn.rel_time` | Collinearity / wrong omitted category | Use `ibn.` to omit base explicitly; check with `testparm` |
| Absolute paths in sub-do-files | Breaks on any other machine | All sub-file paths via `$root` global |
| Raw HILDA file overwrite | Irreversible data loss | Work on copies in `data/clean/`; never `save` to `data/raw/` |
| Missing `cluster()` option | Understated SEs in panel | Always cluster at individual (`id`) level unless theory says otherwise |
