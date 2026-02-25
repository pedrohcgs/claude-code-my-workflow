# Plan: Obtain and Analyze Data for Capital and Labor Shares

**Date:** 2026-02-25
**Status:** DRAFT

## Context

We need to compute the best possible measures of capital and labor shares in healthcare and compare them to other industries. The primary data source is BEA GDP-by-Industry accounts (value added, compensation of employees, gross operating surplus by NAICS industry). BLS QCEW provides supplementary employment/wage data for cross-validation.

The analysis infrastructure is already in place: Stata task-based DAG convention, healthcare knowledge base, domain-specific coding standards, and two scaffolded task directories (`build_nipa_shares/`, `build_bls_employment/`).

**User decisions:**
- BEA API as primary download method (Python helper, free key)
- Separate tasks for supplementary NIPA data (proprietors' income, fixed assets/CFC)
- National-level only for BLS QCEW
- Comparison industries: Healthcare subsectors + Manufacturing, Finance, Retail, Professional Services, Education, Information, Construction, Total Economy

---

## Task DAG (9 tasks, 4 layers)

```
Layer 0 — Raw Data:
  download_bea_gdp_industry   download_bea_nipa_supplements   download_bls_qcew
         │                            │                            │
Layer 1 — Build/Clean:                │                            │
  build_nipa_shares ──────────────────┘                   build_bls_employment
         │                                                    │    │
Layer 2 — Analysis:                                           │    │
  compute_factor_shares                                  merge_bea_bls
         │         │                                          │
Layer 3 — Output:  │                                          │
  sensitivity_analysis                                        │
         │                                                    │
  figures_and_tables ─────────────────────────────────────────┘
```

### Dependency Table

| Task | Inputs (symlinks from) |
|------|----------------------|
| `download_bea_gdp_industry` | None (BEA API) |
| `download_bea_nipa_supplements` | None (BEA API, same key) |
| `download_bls_qcew` | None (direct CSV download) |
| `build_nipa_shares` | `download_bea_gdp_industry/outputs/`, `download_bea_nipa_supplements/outputs/` |
| `build_bls_employment` | `download_bls_qcew/outputs/` |
| `compute_factor_shares` | `build_nipa_shares/outputs/` |
| `merge_bea_bls` | `build_nipa_shares/outputs/`, `build_bls_employment/outputs/` |
| `sensitivity_analysis` | `compute_factor_shares/outputs/` |
| `figures_and_tables` | `compute_factor_shares/outputs/`, `sensitivity_analysis/outputs/`, `merge_bea_bls/outputs/` |

---

## Task Details

### Task 1: `download_bea_gdp_industry`

**Purpose:** Fetch raw BEA GDP-by-Industry data (VA and its components by NAICS).

**Approach:** Python helper script queries the BEA API (`GDPbyIndustry` dataset). Requires a free API key from `apps.bea.gov/api/signup/`. Key stored in `inputs/bea_api_key.txt` (gitignored). Fallback: manual CSV download from BEA interactive tables with instructions in `code/README_manual.md`.

**Why Python helper?** BEA API returns JSON; Stata can't parse JSON natively. Python's `json` stdlib handles it trivially.

**Outputs:** `bea_va_components_raw.dta`, `bea_va_levels_raw.dta`, `bea_chain_indexes_raw.dta`, `data_vintage.txt`

**Code files:** `main.do` (entry point, imports CSVs into Stata), `fetch_bea_api.py` (API queries), `README_manual.md` (fallback instructions)

### Task 2: `download_bea_nipa_supplements`

**Purpose:** Fetch supplementary NIPA tables needed for adjustments: proprietors' income by industry (for Gollin mixed-income adjustment) and consumption of fixed capital by industry (for gross-vs-net sensitivity).

**Approach:** Same BEA API + Python helper pattern as Task 1 (shares the same API key). Key tables:
- Proprietors' income by industry (NIPA Table 6.12D or equivalent)
- Consumption of fixed capital by industry (Fixed Assets Table 6.2 or equivalent)
- Number of self-employed by industry (for imputed-wage Gollin method)

**Outputs:** `proprietors_income_by_industry_raw.dta`, `cfc_by_industry_raw.dta`, `data_vintage.txt`

**Code files:** `main.do`, `fetch_nipa_supplements.py`

### Task 3: `download_bls_qcew`

**Purpose:** Fetch BLS QCEW annual averages (employment, wages by NAICS industry, national level).

**Approach:** Shell script downloads annual CSVs via URL pattern `data.bls.gov/cew/data/files/{YEAR}/csv/{YEAR}_annual_singlefile.zip`. No API key needed.

**Outputs:** `qcew_annual_national_raw.dta`, `data_vintage.txt`

**Code files:** `main.do`, `download_qcew.sh`

### Task 4: `build_nipa_shares` (already scaffolded)

**Purpose:** Clean BEA data into industry-year panel of VA components. Merges GDP-by-Industry data with supplementary NIPA tables.

**Key logic:**
- Create consistent NAICS codes across BEA industry groupings
- Define industry groups: Healthcare (62, 621, 622, 623), Manufacturing (31-33), Finance (52), Retail (44-45), Professional Services (54), Education (61), Information (51), Construction (23), Total Economy
- Verify accounting identity: VA = CE + GOS + Taxes - Subsidies (within rounding)
- Handle suppressed/missing values; flag NAICS revision years
- Merge VA levels with chain-type quantity indexes for real measures

**Outputs:** `nipa_industry_year_panel.dta`, `naics_concordance.dta`

### Task 5: `build_bls_employment` (already scaffolded)

**Purpose:** Clean QCEW into industry-year employment/wage panel.

**Key logic:**
- Filter to national level (`area_fips == "US000"`), target NAICS industries
- Keep private ownership (`own_code == 5`) as primary; all-ownership for sensitivity
- Match NAICS codes to same scheme as `build_nipa_shares`

**Outputs:** `bls_employment_panel.dta`

### Task 6: `compute_factor_shares`

**Purpose:** Compute raw and adjusted capital/labor shares.

**Key logic:**
- Raw shares: `labor_share = CE / VA`, `capital_share = GOS / VA`
- Verify shares sum to ~1 (with tax wedge)
- **Gollin (2002) mixed income adjustments** (3 methods):
  1. Proportional: allocate proprietors' income in same ratio as corporate labor/capital split
  2. All-labor: treat all proprietors' income as labor
  3. Imputed wage: assign proprietors average employee wage
- Uses proprietors' income from `build_nipa_shares` (sourced from `download_bea_nipa_supplements`)

**Outputs:** `factor_shares_raw.dta`, `factor_shares_adjusted.dta`, `factor_shares_summary.dta`

### Task 7: `merge_bea_bls`

**Purpose:** Cross-validate BEA compensation vs BLS wages; enrich with employment data.

**Key logic:**
- Merge on `naics_code year`; document unmatched industries
- CE should exceed QCEW wages by ~25% (supplements); flag outliers
- Generate CE/wage ratio as data quality check

**Outputs:** `merged_bea_bls_panel.dta`, `cross_validation_report.txt`

### Task 8: `sensitivity_analysis`

**Purpose:** Test robustness across specifications.

**Specifications tested:**
1. Mixed income: raw / Gollin proportional / all-labor / imputed wage
2. Nonprofit handling: treat GOS as capital return / net out depreciation / treat as cost recovery
3. Gross vs net: GOS/VA vs NOS/NVA (requires CFC from BEA Fixed Assets tables)

**Outputs:** `sensitivity_results.dta`, `sensitivity_summary.tex`

### Task 9: `figures_and_tables`

**Purpose:** Publication-ready output for Beamer slides.

**Figures (UChicago palette, 2400x1600 PNG):**
- Labor share time series: healthcare vs manufacturing, finance, total economy (1997-present)
- Capital share time series
- Healthcare subsectors (Ambulatory vs Hospitals vs Nursing)
- Cross-industry bar chart of average labor shares
- Sensitivity range plot
- Employment growth vs labor share change scatter

**Tables (LaTeX via `esttab`):**
- Summary factor shares by industry
- Sensitivity analysis comparison

**Outputs:** 6 `.png` figures, 2 `.tex` tables

---

## Data Download Strategy

| Source | Method | Key Needed? | Notes |
|--------|--------|------------|-------|
| BEA GDP-by-Industry | Python → BEA API (primary) | Yes, free signup | JSON response parsed to CSV |
| BEA GDP-by-Industry | Manual CSV (fallback) | No | Interactive tables download |
| BEA NIPA supplements | Manual CSV or API | Same key | Proprietors' income tables |
| BLS QCEW | Shell script → direct CSV | No | Simple URL pattern |

---

## Comparison Industries

| NAICS | Industry | Why |
|-------|----------|-----|
| 62 | Healthcare total | Primary subject |
| 621 | Ambulatory care | Healthcare subsector (physician-heavy, high labor) |
| 622 | Hospitals | Healthcare subsector (capital-intensive) |
| 623 | Nursing/residential | Healthcare subsector |
| 31-33 | Manufacturing | Classic capital-intensive benchmark |
| 52 | Finance/Insurance | High GOS, interesting comparison |
| 44-45 | Retail trade | Labor-intensive benchmark |
| 54 | Professional services | High human capital, like healthcare |
| 61 | Education | Similar human-capital intensity to healthcare |
| 51 | Information | Technology-intensive; interesting capital share dynamics |
| 23 | Construction | Physical-capital intensive; contrasts with healthcare |
| Total | All industries | Economy-wide benchmark |

---

## Implementation Sequence

| Step | Tasks | Parallelizable? |
|------|-------|----------------|
| 1 | Create 8 new task directories + symlinks | — |
| 2 | `download_bea_gdp_industry` + `download_bea_nipa_supplements` + `download_bls_qcew` | Yes (all 3 parallel) |
| 3 | `build_nipa_shares` + `build_bls_employment` | Yes (parallel) |
| 4 | `compute_factor_shares` + `merge_bea_bls` | Yes (parallel) |
| 5 | `sensitivity_analysis` | — |
| 6 | `figures_and_tables` | — |
| 7 | Update `analysis/README.md` with full DAG | — |

**Note:** User must sign up for BEA API key before Step 2 can run.

---

## Files to Create

**New directories (8):**
- `analysis/download_bea_gdp_industry/{code,inputs,outputs}`
- `analysis/download_bea_nipa_supplements/{code,inputs,outputs}`
- `analysis/download_bls_qcew/{code,inputs,outputs}`
- `analysis/compute_factor_shares/{code,inputs,outputs}`
- `analysis/merge_bea_bls/{code,inputs,outputs}`
- `analysis/sensitivity_analysis/{code,inputs,outputs}`
- `analysis/figures_and_tables/{code,inputs,outputs}`
- (existing: `analysis/build_nipa_shares/`, `analysis/build_bls_employment/`)

**New code files (~15):**
- 10 `main.do` files (one per task, including 2 existing scaffolds)
- 2 Python scripts (`fetch_bea_api.py`, `fetch_nipa_supplements.py`)
- 1 `download_qcew.sh` (BLS download script)
- 1 `README_manual.md` (manual download fallback)
- Symlinks connecting all task dependencies

**Files to modify:**
- `analysis/README.md` — update DAG documentation
- `.gitignore` — add `bea_api_key.txt`

---

## Verification

| Task | Check |
|------|-------|
| `download_bea_gdp_industry` | Obs > 0; NAICS 62 present; years 1997-2024; vintage logged |
| `download_bea_nipa_supplements` | Proprietors' income + CFC present for target industries |
| `download_bls_qcew` | Obs > 0; national totals present; years 1997-2024 |
| `build_nipa_shares` | VA = CE + GOS + Taxes (within 0.1); `isid naics_code year` |
| `build_bls_employment` | `isid naics_code year own_code`; employment > 0 for targets |
| `compute_factor_shares` | Shares sum to ~1; healthcare labor share ~0.5-0.7 |
| `merge_bea_bls` | CE/wage ratio ~1.25; merge rate documented |
| `sensitivity_analysis` | All shares in [0,1]; LaTeX compiles |
| `figures_and_tables` | All 6 PNGs + 2 TEX files created; correct dimensions |

**End-to-end:** Healthcare labor share should land in ~55-70% range (consistent with literature). Capital share should show meaningful variation across healthcare subsectors (hospitals more capital-intensive than ambulatory).

---

## Prerequisites

1. **BEA API key:** User must sign up at `apps.bea.gov/api/signup/` (free, instant) and place key in `analysis/download_bea_gdp_industry/inputs/bea_api_key.txt`
2. **Python 3:** Required for BEA API helper scripts (uses only stdlib: `json`, `urllib`)
3. **Stata:** stata-mp (or stata-se) must be available on PATH
