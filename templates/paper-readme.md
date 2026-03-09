# Replication Package: [Paper Title]

**Author:** [Your Name]
**Institution:** [Your Institution]
**Date:** [YYYY-MM-DD]

---

## Paper Abstract

[Brief abstract of the paper - 150-200 words]

---

## Data Availability

| Dataset | Source | Access Date | Variables Used |
|---------|--------|-------------|----------------|
| [Dataset 1] | [Vendor/Author] | [YYYY-MM-DD] | var1, var2 |
| [Dataset 2] | [Vendor/Author] | [YYYY-MM-DD] | var3, var4 |

### Required Registrations
- [ ] [Vendor] data access agreement
- [ ] [Other requirements]

---

## Code Files

| File | Description |
|------|-------------|
| `scripts/Stata/01_clean_data.do` | Data cleaning and variable construction |
| `scripts/Stata/02_eda.do` | Exploratory data analysis |
| `scripts/Stata/03_main_tests.do` | Main regression results |
| `scripts/Stata/04_robustness.do` | Robustness checks |
| `scripts/Stata/05_tables.do` | Generate publication tables |

---

## Output Files

| File | Description |
|------|-------------|
| `Tables/table1.tex` | Descriptive statistics |
| `Tables/table2.tex` | Main results |
| `Tables/table3.tex` | Robustness checks |

---

## Computational Requirements

- **Software:** Stata 18+
- **Packages:** estout, reghdfe, cluster2 (list all)
- **Runtime:** ~[X] minutes on [specs]

---

## Instructions to Replicate

1. Place raw data files in `Data/raw/`
2. Run scripts in order:
   ```bash
   cd scripts/Stata
   stata-mp -b do 01_clean_data.do
   stata-mp -b do 02_eda.do
   stata-mp -b do 03_main_tests.do
   stata-mp -b do 04_robustness.do
   stata-mp -b do 05_tables.do
   ```
3. Tables will be generated in `Tables/`

---

## Results Summary

| Table | Key Finding |
|-------|-------------|
| Table 1 | [Main result] |
| Table 2 | [Robustness] |

---

## Deviations from Original Paper

[List any differences from the original analysis and justify]

---

## References

- Original paper: [Citation]
- Data sources: [Citations]
