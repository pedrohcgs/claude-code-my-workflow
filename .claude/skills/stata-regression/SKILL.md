---
name: stata-regression
description: Create and run Stata regression scripts following the project's coding conventions. Generates publication-ready tables using outreg2 with proper formatting.
argument-hint: "[table name or 'new' or 'template']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash"]
---

# Stata Regression Workflow

Create, run, and export Stata regression results following project conventions.

## Usage

```
/stata-regression table1    # Create Table 1 regression script
/stata-regression new       # Create new regression from template
/stata-regression template  # Show regression template
/stata-regression run       # Run current regression script
```

## Steps

### 1. Specification

Before writing any Stata code, confirm the regression specification with the researcher.

| Element | Specification |
|---------|--------------|
| Dependent Var | [variable] |
| Key Independent | [variable] |
| Controls | Use `$controls` globals |
| FE | [firm, year] |
| SE | [cluster, robust] |

### 2. Template Structure

```stata
********************************************************************************
* Table X: [Title]
********************************************************************************

* Panel structure (confirm with researcher first)
xtset panel_id time_var
* Controls must be defined by the researcher
global controls "var1 var2 var3"

* Column (1): Main specification
xtreg dep_var indep_var $controls i.year, fe vce(cluster industry_code)
    est store col1

* Export
outreg2 [col1] using "Tables/tableX.doc", replace word dec(4) ///
    title("Table X: [Title]") ///
    keep(indep_var Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize)
```

### 3. Common Patterns
- ask me to specify the model before generating code

#### Fixed Effects with Clustered SE
```stata
xtreg dep_var indep $controls i.year, fe vce(cluster cluster_id)
```

#### Probit Model
```stata
probit dep_var indep $controls, vce(cluster firm_id)
dprobit dep_var indep $controls, vce(cluster firm_id)  // marginal effects
```

#### Two-Way Fixed Effects
```stata
reghdfe dep_var indep $controls, absorb(stkcd year) vce(cluster industry_code)
```

#### Interaction Effects
```stata
gen indepXmoderator = indep_var * moderator
xtreg dep_var indep_var moderator indepXmoderator $controls, fe vce(cluster industry_code)
```

### 4. Export Standards

| Element | Standard |
|---------|----------|
| Decimals | 4 for coefficients (dec(4)) |
| Keep variables | List explicitly |
| Stats to add | N, Pseudo R2, Adj R2 |
| Notes | Year FE, Cluster level |

## Checklist

- [ ] Define specification first
- [ ] Use global macros for controls
- [ ] Run with proper SE (cluster at right level)
- [ ] Export with outreg2
- [ ] Verify table matches paper