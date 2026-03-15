---
paths:
  - "data/**"
  - "code/**/*.py"
  - "code/**/*.do"
---

# Data Management

**Data sources:** CSMAR (China Stock Market & Accounting Research), CNRDS (China National Research Data Service)

---

## Data Lifecycle

```
data/raw/          ← Original downloads — READ ONLY, gitignored
    ↓ (Python cleaning scripts)
data/processed/    ← Cleaned intermediate files
    ↓ (Stata merge/construct scripts)
data/final/        ← Analysis-ready datasets (.dta)
    ↓ (Stata analysis do-files)
output/tables/     ← Regression tables
output/figures/    ← Charts and graphs
```

**Rule:** Raw data is never modified. Every transformation step is documented in code.

---

## Raw Data (`data/raw/`)

- **Gitignored** — proprietary CSMAR/CNRDS data cannot be committed
- Directory tracked via `.gitkeep` placeholder
- Document in `data/raw/README.md`: source, download date, variable coverage, any access restrictions
- Filename convention: `[source]_[content]_[years].csv` (e.g., `csmar_financials_2005_2022.csv`)

---

## Processed Data (`data/processed/`)

- Output of Python cleaning scripts
- Format: `.parquet` for large files, `.csv` for small/readable
- Naming: `[step]_[content].parquet` (e.g., `01_csmar_cleaned.parquet`)
- Each file should have a corresponding Python script that produces it

---

## Final Data (`data/final/`)

- Analysis-ready Stata datasets (`.dta`)
- Naming: `[project_abbrev]_[unit]_[years].dta` (e.g., `citb_firm_year_2010_2022.dta`)
- Must be reproducible from `data/processed/` via Stata merge do-files
- Document variable list and construction in `data/final/codebook.md`

---

## Variable Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Outcome | descriptive noun | `patent_count`, `rd_intensity` |
| Treatment/indicator | `d_` prefix | `d_HighTech`, `d_applied` |
| Continuous controls | descriptive | `firm_size`, `leverage`, `roa` |
| Lagged variables | `_l1`, `_l2` suffix | `rd_intensity_l1` |
| Winsorized | `_w` suffix | `leverage_w` |
| Standardized | `_std` suffix | `firm_size_std` |
| Industry code | `ind_` prefix | `ind_csrc2`, `ind_sic` |
| Year variable | `year` | always integer (2010, 2011, ...) |
| Firm ID | `firm_id` | string, 6-digit CSMAR code |

---

## CSMAR-Specific Conventions

- **Firm ID:** 6-digit stock code (e.g., `000001`), stored as string to preserve leading zeros
- **Fiscal year:** Use `tyear` (CSMAR) or construct from announcement date — document which
- **Financial variables:** Use consolidated statements (`A` suffix in CSMAR) unless paper specifies parent-only
- **Industry classification:** Document which version (CSRC 2012, CSRC 2001, or SIC) and vintage
- **Exchange:** `exchange = "SH"` (Shanghai) or `"SZ"` (Shenzhen) — derive from first digit of firm ID if needed

## CNRDS-Specific Conventions

- **Patent data:** Document which patent type (invention, utility model, design) is included
- **Innovation tax benefit data:** Document the specific CNRDS table and variable used for application records
- **Date fields:** Standardize all dates to `YYYY-MM-DD` format before merging

---

## Merge Discipline

Before every merge, log the pre- and post-merge observation counts:

```stata
di "Before merge: `=_N' obs"
merge m:1 firm_id year using "$DATA/controls.dta", keep(3) nogen
di "After merge: `=_N' obs"
```

Document the expected merge rate in comments. Investigate unexpected drops > 5%.

---

## Missing Data

- Document which variables are missing and why in do-file comments
- Use `misstable summarize` to audit missingness after constructing key variables
- Never silently drop observations — always `keep if` with a comment explaining why

---

## Winsorization

- Standard threshold: 1st and 99th percentile per year (unless paper specifies otherwise)
- Use `winsor2` package:
  ```stata
  winsor2 leverage roa, cuts(1 99) by(year) suffix(_w)
  ```
- Document winsorization level in variable label: `label var leverage_w "Leverage (winsorized 1/99)"`
