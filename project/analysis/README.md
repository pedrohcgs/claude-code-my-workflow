# Analysis pipeline

Clean, portable Stata pipeline for the Fertilizer Quality in Kenya project. Built from the best versions of scripts scattered across `project/`, with hardcoded paths replaced by globals and several analytical bugs fixed.

## Quick start

```stata
* In Stata:
global root "C:/git/fake-fertilizer"   // edit for your machine
do "$root/project/analysis/master.do"
```

`master.do` sets `$root`, loads `config.do` (which derives all other paths), checks that required packages are installed, then runs scripts 1--4 in order.

## Prerequisites

- Stata 15+ (developed on v15.1)
- Raw data in `project/data/build/input/` (never modified by the pipeline)
- Internet connection on first run (to install packages from SSC)

---

## Scripts

### `config.do` --- path configuration

Derives all path globals from `$root`. Edit `$root` in `master.do` once per machine; everything else follows automatically.

| Global | Points to |
|--------|-----------|
| `$project` | `$root/project` |
| `$input` | `$project/data/build/input` (raw data, read-only) |
| `$output` | `$project/analysis/output` (final datasets) |
| `$temp` | `$project/analysis/temp` (intermediate files) |
| `$figures` | `$project/analysis/figures` (tables + graphs) |

### `0_setup.do` --- package checks

Checks for `geodist`, `estout`, and `blindschemes`. Installs any missing packages from SSC. Sets the graph scheme to `plotplain`.

### `1_clean_input_survey.do` --- agrodealer survey

Imports the agrodealer input survey (Homa Bay and Migori counties), reshapes fertilizer data to long format, merges survey responses with fertilizer-level records, and applies extensive cleaning: label definitions, enumerator error corrections, unit standardization, price/cost per-kg calculations, and markup computation.

Produces two datasets: the full cleaned survey (`agrovet_survey_cleanish.dta`) and a GPS-only extract with prices (`agrovet_survey_gps.dta`).

### `2_clean_mystery_shopping.do` --- mystery shopping + lab results

Imports mystery shopping data, splits by round, reshapes to long format (one row per bag purchased), and merges with bag label IDs. Round 1 lab results come from MIR spectroscopy; round 2 from pXRF. Applies enumerator corrections for sealed bag attributes, computes expected nitrogen by fertilizer type and manufacturer, and calculates the percentage deviation from expected nitrogen content.

Produces the combined mystery shopping dataset with lab results (`MysteryShopping_all.dta`).

### `3_store_distance.do` --- store proximity

Computes pairwise geodesic distances between all agrodealers and generates counts of stores within 1, 3, 5, and 10 km of each store. Also creates derived variables for asset ownership, quality perception indicators, storage, and business characteristics. Merges the store-level variables with mystery shopping data.

Produces the analysis-ready dataset (`mystery_addvars.dta`).

### `4_summary_stats.do` --- tables and figures

Generates a summary statistics table (`summary_stats.tex`) and histograms of nitrogen content deviation by fertilizer type, round, and manufacturer. Also creates indicator variables for physical quality issues (clumps, discoloration, foreign materials, etc.).

---

## Data flow

```
RAW INPUTS                         TEMPORARY                      FINAL OUTPUTS
($input/)                          ($temp/)                       ($output/)

InputSurvey.csv ──────────┐
                          ├─── [1_clean_input_survey.do] ──────── InputSurvey.dta
InputSurvey-fert_         │                                       InputSurvey-fert_questions_r1.dta
  questions.csv ──────────┘                                       agrovet_survey_cleanish.dta ─────┐
                                                                  agrovet_survey_gps.dta           │
                                                                                                   │
MysteryShoppingr2.csv ────┐                                                                        │
                          ├─── [2_clean_mystery_shopping.do]                                       │
label_ids.csv ────────────┤        │                                                               │
label_idsr2.csv ──────────┤        ├── MysteryShopping_r1.dta                                      │
raw_mir_spectra.dta ──────┤        ├── MysteryShopping_r1V2.dta                                    │
mir_predicted_tool_       │        ├── MysteryShopping_r1V3.dta                                    │
  total_CN_reported.dta ──┤        ├── MysteryShopping_r2.dta                                      │
Migori fertilizer         │        ├── MysteryShopping_r2V2.dta                                    │
  cn_pxrf data.csv ───────┘        ├── MysteryShopping_r2V3.dta                                    │
                                   │                              MysteryShopping_all.dta ────┐    │
                                   │                                                          │    │
                                   │                                                          │    │
                          [3_store_distance.do] ◄─────────────────────────────────────────────┘────┘
                                   │
                                   ├── addvars.dta
                                   │                              mystery_addvars.dta ────┐
                                   │                                                      │
                                                                                          │
                          [4_summary_stats.do] ◄──────────────────────────────────────────┘

                                                                  FIGURES ($figures/)
                                                                  ├── summary_stats.tex
                                                                  ├── purchases.png
                                                                  ├── hist_quality_by_type.png
                                                                  ├── hist_dap.png
                                                                  ├── hist_can.png
                                                                  ├── hist_urea.png
                                                                  └── hist_can_manuf.png
```

### File inventory

**Raw inputs** (8 files in `project/data/build/input/`, never modified):

| File | Used by | Contains |
|------|---------|----------|
| `InputSurvey.csv` | Step 1 | Agrodealer survey responses |
| `InputSurvey-fert_questions.csv` | Step 1 | Fertilizer-specific survey questions |
| `MysteryShoppingr2.csv` | Step 2 | Mystery shopping visits (both rounds) |
| `label_ids.csv` | Step 2 | Lab sample IDs for round 1 bags |
| `label_idsr2.csv` | Step 2 | Lab sample IDs for round 2 bags |
| `raw_mir_spectra.dta` | Step 2 | MIR spectra metadata (round 1) |
| `mir_predicted_tool_total_CN_reported.dta` | Step 2 | MIR-predicted nitrogen content (round 1) |
| `Migori fertilizer cn_pxrf data.csv` | Step 2 | pXRF nitrogen measurements (round 2) |

**Temporary files** (7 files in `analysis/temp/`, safe to delete):

| File | Created by | Purpose |
|------|-----------|---------|
| `MysteryShopping_r1.dta` | Step 2 | Round 1 reshaped, pre-label-merge |
| `MysteryShopping_r2.dta` | Step 2 | Round 2 reshaped, pre-label-merge |
| `MysteryShopping_r1V2.dta` | Step 2 | Round 1 with label IDs, deduped |
| `MysteryShopping_r1V3.dta` | Step 2 | Round 1 with MIR lab results |
| `MysteryShopping_r2V2.dta` | Step 2 | Round 2 with label IDs |
| `MysteryShopping_r2V3.dta` | Step 2 | Round 2 with pXRF lab results |
| `addvars.dta` | Step 3 | Store-level variables, pre-merge |

**Final datasets** (6 files in `analysis/output/`):

| File | Created by | Contains |
|------|-----------|----------|
| `InputSurvey.dta` | Step 1 | Basic survey data (store-level) |
| `InputSurvey-fert_questions_r1.dta` | Step 1 | Fertilizer questions, reshaped long |
| `agrovet_survey_cleanish.dta` | Step 1 | Full cleaned survey (store x fert type) |
| `agrovet_survey_gps.dta` | Step 1 | GPS + prices only (one row per store) |
| `MysteryShopping_all.dta` | Step 2 | Mystery shopping + lab results (both rounds) |
| `mystery_addvars.dta` | Step 3 | Analysis-ready: shopping + store characteristics |

**Figures and tables** (7 files in `analysis/figures/`):

| File | Created by | Contains |
|------|-----------|----------|
| `summary_stats.tex` | Step 4 | LaTeX summary statistics table |
| `purchases.png` | Step 4 | Histogram of samples per store |
| `hist_quality_by_type.png` | Step 4 | Nitrogen deviation by fertilizer type (round 1) |
| `hist_dap.png` | Step 4 | DAP nitrogen deviation by round |
| `hist_can.png` | Step 4 | CAN nitrogen deviation by round |
| `hist_urea.png` | Step 4 | Urea nitrogen deviation by round |
| `hist_can_manuf.png` | Step 4 | CAN nitrogen deviation by manufacturer |

---

## Changes from original scripts

### Path portability (all scripts)

All hardcoded Dropbox paths (`C:\Users\Emilia\Dropbox\...`, `C:\Users\etjernstrom\Dropbox\...`) and user-switching logic replaced with globals derived from a single `$root` variable. All backslash paths standardized to forward slashes.

### Bug fixes

| Issue | Script | Original | Fix |
|-------|--------|----------|-----|
| `percent` was a fraction, not a percentage | `2_clean_mystery_shopping.do` | `gen percent = diff / expected_nitrogen` (produces -0.167) | Multiplied by 100 to produce actual percentages (-16.7) |
| `flag` had redundant construction | `2_clean_mystery_shopping.do` | `gen flag = 1 == (!mi(comment))` | Simplified to `gen flag = !mi(comment)` |
| `bus_typeD` displayed wrong labels | `3_store_distance.do` | `lab val bus_typeD business_type` (1 showed "Seasonal" instead of "Permanent") | Created dedicated `bus_typeD` label definition with correct 0/1 mapping |
| Histogram never exported | `4_summary_stats.do` | `hist percent ... by(bag_type)` with no `graph export` | Added `graph export "$figures/hist_quality_by_type.png", replace` |
| Dead code: orphaned .dta save | `2_clean_mystery_shopping.do` | CSV imported and saved to .dta but the file was never used (merge used a different file) | Removed the unused import/save block |

### Structural improvements

| Change | Script | Detail |
|--------|--------|--------|
| Dynamic loop limits | `3_store_distance.do` | `forvalues i = 1(1)189` → `local N = _N` / `forvalues i = 1(1)\`N'`` (adapts to data size) |
| Removed redundant cleaning | `3_store_distance.do` | Dropped `drop intro1 intro2 business_note` and `recode facility_type` (already done in step 1) |
| Removed Overleaf copy | `4_summary_stats.do` | Hardcoded `copy ... Overleaf/...` command removed |
| Intermediate files separated | `2_clean_mystery_shopping.do` | Intermediate .dta files routed to `$temp/` instead of mixed into input/output |
| Single `$root` definition | `config.do` / `master.do` | `$root` defined only in `master.do`; `config.do` derives everything else |

---

## Source mapping

| New script | Original source |
|------------|----------------|
| `config.do` | New |
| `master.do` | New |
| `code/0_setup.do` | New |
| `code/1_clean_input_survey.do` | `project/data/build/code/archive/reshape_inputsurvey_fertilizerV2.do` |
| `code/2_clean_mystery_shopping.do` | `project/data/build/code/archive/mysteryshopping_import_clean.do` |
| `code/3_store_distance.do` | `project/data/function/code/ff_stores_distance.do` |
| `code/4_summary_stats.do` | `project/data/function/code/ff_summary_stats.do` |

Original files in `project/` are untouched.
