---
paths:
  - "scripts/Stata/**/*.do"
  - "scripts/Stata/**/*.ado"
  - "Data/**/*.dta"
---

# Stata Code Conventions

**Goal:** Clean, reproducible, publication-ready Stata code.

---

## File Organization

```
scripts/Stata/
├── 01_clean_data.do     # Data cleaning and preparation
├── 02_eda.do            # Exploratory data analysis
├── 03_main_tests.do     # Primary hypothesis tests
├── 04_robustness.do    # Robustness checks
├── 05_tables.do        # Generate publication tables
└── ado/                 # Personal ado-files
```

**Rule:** One main script per phase. Numbered prefix ensures execution order.

---

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variables | lowercase_underscore | `total_assets`, `roa` |
| Globals | descriptive_caps | `$main_controls`, `$firm_fe` |
| Scalars | descriptive | `scalar N_main = 1234` |
| Matrices | MAT_ descriptive | `matrix MAT_coefs = J(3,4,0)` |
| Programs | camelCase | `program define myprogram` |
| Files | descriptive.dta | `panel_clean.dta` |

---

## Header Block

Every .do file must begin with:

```stata
********************************************************************************
* [Brief description of what this script does]
* Author: [Your Name]
* Date: [YYYY-MM-DD]
* Input:  [data files used]
* Output: [data files created, tables generated]
********************************************************************************

version 18.0
clear all
set more off

* Set working directory
cd "/path/to/project"

* Load required packages
* ssc install [package]
```

---

## Variable Documentation

Document every constructed variable in comments:

```stata
* Variable: roa
* Definition: Return on Assets = NI / Total Assets
* Source: Compustat items (ni, at)
* Sample: FY 1990-2020, exclude financial firms (sic 6000-6999)
gen roa = ni / at
```

---

## Regression Standards

### Standard Error Types

| Type | Code | When to Use |
|------|------|-------------|
| Robust | `, robust` | Heteroskedasticity |
| Cluster | `, cluster(id)` | Cross-sectional dependence |
| Double-cluster | `, cluster(id year)` | Two-way dependence |
| Driscoll-Kraay | `, vce(driscoll-kraay)` | Panel serial correlation |

### Regression Header

```stata
* Table X, Column (1): Main specification
* Dependent:    [dependent variable]
* Sample:      [sample restrictions]
* FE:          [fixed effects]
* SE:          [standard error type]
reg y x control1 control2, absorb(firm_id) vce(robust)
eststo m1
```

---

## Output Standards

Use `eststo` for regression storage, `esttab` for tables:

```stata
* Export to LaTeX
esttab m1 m2 m3 using "$tables/table1.tex" ///
    , booktabs replace ///
    se(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Main Results") ///
    mtitles("Model 1" "Model 2" "Model 3")
```

---

## Error Handling

```stata
* Check required data exists
capture confirm file "$data/panel_clean.dta"
if _rc != 0 {
    di as error "Required data file not found"
    exit 111
}
```

---

## Self-Contained Scripts

- Use relative paths via globals, not hardcoded absolute paths
- Include all data dependencies in header comments
- No interactive commands (browse, edit) in final scripts
