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

**Rule:** 
- One main script per research phase
- Scripts must run sequentially
- Numbered prefixes enforce execution order
- Raw data must never be overwritten. 
- Derived datasets should be saved in a processed directory.
---

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variables | lowercase_underscore | `stkcd`, `year`, `total_asset` |
| Globals | descriptive_caps | `$controls`, `$main_spec` |
| Scalars | descriptive | `scalar N_main = 1234` |
| Matrices | MAT_ descriptive | `matrix MAT_coefs = J(3,4,0)` |
| Files | descriptive.dta | `clean.dta` |

### Variable Suffix Patterns (from examples)

| Suffix | Meaning | Example |
|--------|---------|---------|
| `_REV` | Scaled by revenue | `RPT_a_REV` = RPT / Revenue |
| `_TA` | Scaled by total assets | `guarantee_TA` = Guarantee / Total Assets |
| `_ln` | Log transformed | `ln_asset` = ln(assets) |
| `_sd` | Standard deviation | `ROS_sd` = ROS standard deviation |

### Indicator Variable Patterns

| Prefix | Source | Example |
|--------|--------|---------|
| `d_` | Manual dummy | `d_soe` |
| `_I` | From `tab` command | `_Iyear*`, `_Iind2*` |

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

clear

* Set working directory
cd "/path/to/project"

* Load required packages
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

---

## Control Variables

Do not assume a fixed set of control variables.

Control variables should always be specified by the researcher for each regression.

Use globals only as containers when the researcher provides a control set.

Example:

global controls "var1 var2 var3"
xtreg y x $controls, fe cluster(firm)

---
## Research Design Confirmation

Before generating any regression code, always confirm the following with the researcher:

- dependent variable
- key independent variable(s)
- control variables
- whether panel data methods are required
- panel identifier and time variable, if panel regression is used
- fixed effects structure
- clustering level
- sample restrictions, if any

Do not assume any of the above from previous examples.

Do not choose an econometric model without researcher confirmation.

If any of these are not explicitly provided, ask first before writing final code.

---

## Common Regression Commands (from examples)

| Model | Command | SE Options |
|-------|---------|------------|
| OLS | `reg y x, vce(robust)` | cluster, robust |
| Panel FE | `xtreg y x, fe vce(cluster)` | cluster(id), robust |
| Probit | `probit y x, vce(cluster)` | cluster(id) |
| DProbit | `dprobit y x, vce(cluster)` | Marginal effects |
| IV | `ivreg2 y (x = z), first ivregress 2sls` | cluster, robust |
| Cox | `stcox x, vce(cluster)` | hazard model |


---

## Output Export: outreg2 (from examples)

Standard outreg2 patterns:

```stata
* Basic regression output
outreg2 using "table1", replace word dec(4) ///
    title("Table X: Title") ///
    keep(var1 var2 var3) ///
    addstat("Pseudo R2", e(r2_p))

* With fixed effects
outreg2 using "table1", replace word dec(4) ///
    keep(var1 var2) ///
    addstat("Adj R2", e(r2_a)) ///
    addtext("Year FE", "YES", "Industry FE", "YES")

* Clustered SE indication
outreg2 using "table1", replace word dec(4) ///
    ctitle(Column Title) ///
    addtext(Controls, YES, Clustered SE, Firm)
```

### Common outreg2 Options

| Option | Purpose | Example |
|--------|---------|---------|
| `dec(4)` | Decimal places | 4 decimals |
| `replace` | Overwrite file | replace |
| `word` | Word format | word |
| `keep()` | Keep variables | keep(var1 var2) |
| `drop()` | Drop variables | drop(_I*) |
| `addstat()` | Add statistics | addstat("R2", e(r2)) |
| `addtext()` | Add text notes | addtext("FE", "YES") |
| `ctitle()` | Column title | ctitle(Main) |

## Reproducibility Rules

Scripts must run from start to finish without manual intervention.

Avoid:

browse
edit
pause
display prompts requiring user input

## Two-Step Regression Workflow

1. propose regression specification
2. wait for researcher confirmation
3. generate final Stata code
