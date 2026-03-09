# Table Specification: [Table Number]

**Paper:** [Paper Title]
**Date Created:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]

---

## Table Overview

| Element | Specification |
|---------|---------------|
| Title | [Exact title for publication] |
| Label | `tab:[descriptive]` |
| Panel Structure | [Single / Multi-panel] |

---

## Data Source

| Source | File | Variables |
|--------|------|-----------|
| Main data | `Data/clean/panel.dta` | var1, var2 |

---

## Column Definitions

| Column | (1) | (2) | (3) |
|--------|-----|-----|-----|
| Label | {Sample Description} | {Sample Description} | {Sample Description} |
| Dependent Var | [var] | [var] | [var] |
| Key Independent | [var] | [var] | [var] |
| Fixed Effects | [None/FE] | [None/FE] | [None/FE] |
| SE Type | [Robust/Cluster] | [Robust/Cluster] | [Robust/Cluster] |

---

## Panel A: [Panel Title]

### Variables to Display

| Variable | Statistic | Format |
|----------|-----------|--------|
| [var1] | Mean | (2) |
| [var1] | SD | (2) |
| [var2] | Mean | (2) |
| [var2] | SD | (2) |

---

## Panel B: [Panel Title] (if applicable)

[Same structure as Panel A]

---

## Formatting Standards

| Element | Standard |
|---------|----------|
| Alignment | DECimal (D{.}{.}{-1}) |
| Significance | * p<0.10, ** p<0.05, *** p<0.01 |
| Parentheses | (SE) below coefficients |
| Observations | Below each column |
| R-squared | Below observations (if applicable) |
| Font size | \small or \normalsize |
| Table width | \maxwidth (auto-fit) |

---

## Notes to Reviewer

[Any methodological notes or clarifications for referees]

---

## Stata Code

```stata
* Load data
use "$data/clean/panel.dta", clear

* Generate Table X
eststo clear

* Column (1): [Specification]
reg y x1, vce(robust)
eststo col1

* Column (2): [Specification]
reg y x1 x2, vce(robust)
eststo col2

* Export
esttab col1 col2 using "$tables/tableX.tex" ///
    , booktabs replace ///
    se(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table X: [Title]") ///
    mtitles("(1)" "(2)") ///
    fragment
```

---

## Expected Output Preview

```
                    (1)         (2)
                [Sample]    [Sample]
----------------------------------------
Variable       0.123***    0.098***
               (0.041)      (0.039)

Observations    1,234       1,234
R-squared       0.234       0.312
----------------------------------------
```

---

## Status

- [ ] Draft written
- [ ] Code implemented
- [ ] Numbers verified
- [ ] Peer reviewed
- [ ] Publication-ready
