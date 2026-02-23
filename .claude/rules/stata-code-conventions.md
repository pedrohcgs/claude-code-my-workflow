---
paths:
  - "**/*.do"
  - "scripts/stata/**/*.do"
---

# Stata Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

---

## 1. Script Header

Every .do file MUST start with a header block:

```stata
* ============================================================
* Title:   [Descriptive Title]
* Author:  [Author Name]
* Date:    [YYYY-MM-DD]
* Purpose: [What this script does]
* Input:   [Data files used]
* Output:  [Files created]
* ============================================================
```

## 2. Initialization

```stata
clear all
set more off
capture log close
log using "scripts/stata/logs/analysis_YYYYMMDD.smcl", replace

* Set seed for reproducibility
set seed 12345
```

## 3. Path Management

Use globals for all paths---never hardcode absolute paths (e.g., `C:/Users/...` or `/home/...`). Every path must be relative to the project root so scripts work on any machine:

```stata
global root    "."
global data    "$root/data"
global raw     "$data/raw"
global proc    "$data/processed"
global output  "$root/output"
global tables  "$output/tables"
global figures "$output/figures"
```

Never use `c(pwd)` to build absolute paths for file output. Use globals instead.

## 4. Estimation & Output

- Use `eststo` / `esttab` for regression tables
- Store estimates with `estimates store`
- Export tables to LaTeX: `esttab using "$tables/table1.tex", ...`

```stata
eststo clear
eststo: reg y x1 x2, robust
eststo: reg y x1 x2 x3, cluster(id)
esttab using "$tables/main_results.tex", ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label replace booktabs
```

## 5. Logging

- Always log output to `scripts/stata/logs/`
- Close log at end of script: `log close`
- Use `.smcl` format (Stata default)

## 6. Figure Standards

```stata
graph export "$figures/figure1.pdf", replace as(pdf)
graph export "$figures/figure1.png", replace as(png) width(3600)
```

## 7. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `clear all` | Residual data contamination | Always start with `clear all` |
| Hardcoded absolute paths | Breaks on other machines | Use relative globals; reject any `C:/`, `/home/`, or `c(pwd)` in file paths |
| Missing `log close` | Log file stays locked | Always close log at end |
| No `set seed` | Non-reproducible bootstrap/simulation | Set seed after `clear all` |

## 8. Code Quality Checklist

```
[ ] Header block with all fields
[ ] clear all + set more off at top
[ ] Log opened and closed
[ ] set seed if stochastic
[ ] Paths via globals, all relative
[ ] eststo/esttab for regression tables
[ ] Figures exported as PDF and PNG
[ ] Comments explain WHY not WHAT
```
