---
paths:
  - "scripts/Stata/**/*.do"
  - "**/*.do"
---

# Stata Code Standards

**Standard:** Publication-quality, reproducible empirical research

---

## 1. Reproducibility

- `version 17` (or your version) at top of every do-file
- `clear all` + `set more off` + `set matsize 11000` at top
- `set seed YYYYMMDD` before any randomization or bootstrap
- All paths relative to project root — never `cd "C:\Users\..."`
- Use a global macro for project root: `global root "..."` set once in a master do-file

## 2. File Header

Every do-file starts with:
```stata
/*==============================================================================
  Project:  Financial Intermediary Shocks and Firm Heterogeneity
  File:     [filename].do
  Purpose:  [one-line description]
  Author:   [name]
  Date:     [YYYY-MM-DD]
  Input:    [list input files]
  Output:   [list output files]
==============================================================================*/
```

## 3. Naming Conventions

- **Variables:** `snake_case` — e.g., `log_assets`, `inv_capital_ratio`, `bank_leverage`
- **Macros:** `lowercase` for locals, `UPPERCASE` for globals
- **Do-files:** `NN_description.do` — e.g., `01_clean_compustat.do`, `02_merge_lender.do`
- **Temp files:** Always use `tempfile` and `tempvar`, never hardcoded temp names

## 4. Output

### Tables
- Use `eststo` + `esttab` (or `outreg2`) for regression tables
- Export to LaTeX: `esttab using "../output/tables/table_name.tex", replace booktabs`
- Always include: standard errors, N, R-squared, fixed effects indicators

### Figures
- Use `graph export "../output/figures/figure_name.pdf", replace`
- Set scheme: `set scheme s2color` or a custom scheme
- Explicit dimensions: `xsize(12) ysize(6)` for slides

## 5. Logging

```stata
log using "../output/logs/`filename'_$S_DATE.log", replace text
// ... analysis ...
log close
```

## 6. Comment Style

- `//` for inline comments
- `/* ... */` for block comments
- `///` for line continuation (align continuation lines)
- Comments explain WHY, not WHAT

## 7. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Hardcoded absolute paths | Breaks on other machines | Use `$root` global macro |
| Missing `replace` in output | Stale results persist | Always include `replace` option |
| Clustering at wrong level | Invalid standard errors | Document clustering choice |
| Not preserving sort order | Merge errors | `sort` before `merge`, use `assert` |
| Forgetting `clear` before `use` | Memory errors | `clear all` at top |

## 8. Code Quality Checklist

```
[ ] version statement at top
[ ] clear all / set more off
[ ] All paths relative (using $root)
[ ] Header block with purpose, input, output
[ ] Variables named in snake_case
[ ] Tables exported to LaTeX with booktabs
[ ] Figures exported as PDF
[ ] Log file created
[ ] Comments explain reasoning
[ ] assert statements after merges
```
