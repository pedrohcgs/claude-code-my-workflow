# Fertilizer Quality in Kenya---Data Folder Description

**Generated:** 2026-02-24
**Source:** `project/` directory (synced from Dropbox PEDL/ folder)
**Total files:** ~1,581 (43 .do, 32 .dta, ~940 .csv, 352 .jpg, 63 .3gpp, 46 .pdf, 44 .html, 35 .xlsx)

---

## 1. What this project is

A PEDL-funded study on fertilizer quality in western Kenya (Homa Bay and Migori counties). The research design has two components:

1. An **input survey** of ~189 agro-dealer stores, collecting store characteristics, fertilizer inventory, pricing, supply chains, and perceptions of quality problems in the market.
2. A **mystery shopping** exercise where enumerators purchased fertilizer samples from these stores across two rounds, then sent the samples to ICRAF's soil-plant lab for spectroscopic analysis (MIR and pXRF) to measure actual nitrogen content.

The core research question: how does actual fertilizer nutrient content compare to what's advertised? The project measures this as "percent of expected nitrogen" for DAP (expected 18% N), CAN (expected 27% N), and Urea (expected 46% N).

---

## 2. Data pipeline overview

```
RAW DATA (build/input/)                    CLEANING CODE                      CLEANED DATA (build/output/)

InputSurvey.csv ──────────────┐
InputSurvey-fert_questions.csv┼── reshape_inputsurvey_fertilizerV2.do ──────► agrovet_survey_cleanish.dta
                              │                                               agrovet_survey_gps.dta
                              │                                               manufacturer_fertilizer.dta
                              │
MysteryShoppingr1.csv ────────┼── mysteryshopping_import_clean.do ──────────► MysteryShopping_r1V3.dta
MysteryShoppingr2.csv ────────┤                                               MysteryShopping_r2V3.dta
label_ids.csv ────────────────┤                                               MysteryShopping_all.dta
label_idsr2.csv ──────────────┘

raw_mir_spectra.dta ──────────┐
mir_predicted_*.dta ──────────┼── expected_nitrogen.do ─────────────────────► (merged into MysteryShopping)
                              │

CLEANED DATA                       ANALYSIS CODE                       OUTPUTS (function/output/)

manufacturer_fertilizer.dta ──┬── ff_stores_distance.do ───────────────────► addvars.dta (build/temp/)
                              │   (geodist calculations, asset dummies,       mystery_addvars.dta
                              │    quality perception vars)
                              │
mystery_addvars.dta ──────────┴── ff_summary_stats.do ─────────────────────► summary_stats.tex
                                  (balance tables, histograms)                hist_dap.png
                                                                              hist_can.png
                                                                              hist_urea.png
                                                                              hist_can_manuf.png
                                                                              purchases.png
                                                                              map_purchase.png
                                                                              map_round.png
```

---

## 3. Raw data inventory (`data/build/input/`)

| File | Date | Description |
|------|------|-------------|
| `InputSurvey.csv` | Sep 2017 | SurveyCTO export of the agro-dealer input survey (~189 stores) |
| `InputSurvey-fert_questions.csv` | Sep 2017 | Repeat-group export: fertilizer types, manufacturers, prices per store |
| `MysteryShoppingr1.csv` | Sep 2017 | Round 1 mystery shopping purchases (sealed bags, visual inspection) |
| `MysteryShoppingr2.csv` | Aug 2018 | Round 2 mystery shopping purchases |
| `label_ids.csv` | Dec 2017 | Mapping from store/bag IDs to lab sample IDs (Round 1) |
| `label_idsr2.csv` | Aug 2018 | Same mapping for Round 2 |
| `raw_mir_spectra.dta` | Dec 2017 | ICRAF MIR spectroscopy raw readings |
| `mir_predicted_tool_total_CN_reported.dta` | Dec 2017 | ICRAF lab results: predicted total carbon and nitrogen |
| `mir_predicted_total_CN_reported.dta` | Mar 2019 | Updated lab results (later copy, same size) |
| `MIR predicted total CN reported.csv` | Aug 2018 | CSV version of lab results |
| `Migori fertilizer cn_pxrf data.csv` | Aug 2018 | pXRF (portable X-ray fluorescence) nutrient data from Migori |
| `Raw MIR spectra.csv` | Nov 2019 | CSV version of raw spectra (5.3 MB) |
| `ken-popkenpopmap15adjv2b.zip` | May 2019 | WorldPop population density raster for Kenya (234 MB GeoTIFF) |

---

## 4. Cleaned/intermediate data (`data/build/output/`)

| File | Date | Source script | Description |
|------|------|---------------|-------------|
| `manufacturer_fertilizer.dta` | Aug 2018 | `reshape_inputsurvey_fertilizerV2.do` | Store-by-fertilizer-type panel: inventory, pricing, bag sizes, quality perceptions |
| `agrovet_survey_cleanish.dta` | Mar 2019 | `reshape_inputsurvey_fertilizerV2.do` | Renamed version of manufacturer_fertilizer with GPS subset |
| `agrovet_survey_gps.dta` | Mar 2019 | `reshape_inputsurvey_fertilizerV2.do` | GPS coordinates only (for GIS mapping) |
| `InputSurvey.dta` | Mar 2019 | (Stata import) | .dta version of InputSurvey.csv |
| `InputSurvey-fert_questions_r1.dta` | Mar 2019 | (Stata import) | .dta version of fert_questions, Round 1 only |
| `MysteryShopping_r1.dta` | Mar 2019 | `mysteryshopping_import_clean.do` | Round 1 mystery shopping, initial clean |
| `MysteryShopping_r1V2.dta` | Mar 2019 | Same | Round 1, second pass (more corrections) |
| `MysteryShopping_r1V3.dta` | Mar 2019 | Same | Round 1, final clean (30+ manual corrections) |
| `MysteryShopping_r2.dta` | Mar 2019 | Same | Round 2, initial clean |
| `MysteryShopping_r2V2.dta` | Mar 2019 | Same | Round 2, second pass |
| `MysteryShopping_r2V3.dta` | Mar 2019 | Same | Round 2, final clean |
| `MysteryShopping_all.dta` | Mar 2019 | Same | Both rounds appended + lab data merged |
| `mystery_addvars.dta` | Aug 2018 | `ff_stores_distance.do` | MysteryShopping_all + store characteristics + distance variables |
| `gps_coords_for_GIS.csv` | Mar 2019 | (manual export) | GPS coordinates for mapping |

---

## 5. Analysis outputs (`data/function/output/`)

| File | Date | Source script | Description |
|------|------|---------------|-------------|
| `summary_stats.tex` | Aug 2018 | `ff_summary_stats.do` | LaTeX table of store-level summary statistics (also copied to Overleaf) |
| `hist_dap.png` | Aug 2018 | Same | Histogram: % of expected nitrogen for DAP, by round |
| `hist_can.png` | Aug 2018 | Same | Histogram: % of expected nitrogen for CAN, by round |
| `hist_urea.png` | Aug 2018 | Same | Histogram: % of expected nitrogen for Urea, by round |
| `hist_can_manuf.png` | Aug 2018 | Same | Histogram: CAN nitrogen by manufacturer |
| `purchases.png` | Aug 2018 | Same | Histogram: number of samples obtained per store |
| `fertilizer_types.png` | Aug 2018 | Same | Bar chart of fertilizer types stocked |
| `map_purchase.png` | Aug 2018 | Same | Map of purchase locations |
| `map_round.png` | Aug 2018 | Same | Map by survey round |
| `maps.pptx` | Aug 2018 | (manual) | PowerPoint with maps |

---

## 6. Script-by-script description

### 6a. The canonical pipeline (data/build/code/ and data/function/code/)

**`data/build/code/ff_master.do`** --- Master orchestrator
- Sets `global dir` to Emilia's Dropbox path
- Calls `reshape_inputsurvey_fertilizerV2.do` (input survey cleaning)
- Calls `mysteryshopping_import_clean.do` (mystery shopping cleaning)
- References `agrovet_survey_addvars.do` and `agrovet_survey_addquality.do` (missing---likely renamed to `ff_stores_distance.do`)
- Log opening is commented out; no `clear all`

**`data/build/code/archive/reshape_inputsurvey_fertilizerV2.do`** --- Input survey cleaning (called by master)
- Reads: `InputSurvey-fert_questions.csv`, `InputSurvey.csv`
- Writes: `agrovet_survey_cleanish.dta`, `agrovet_survey_gps.dta`
- Reshapes fertilizer questions from wide to long
- Creates fertilizer type indicators (DAP, CAN, Urea), bag size availability
- Applies ~100 value labels (manufacturer, county, education, concern scales, store characteristics)
- Fixes duplicate store ID (store 134 = "Golden apples hardware")
- Creates supply chain indicator (13 stores identified as wholesalers)

**`data/build/code/archive/mysteryshopping_import_clean.do`** --- Mystery shopping cleaning (called by master)
- Reads: `MysteryShoppingr1.csv`, `MysteryShoppingr2.csv`, `label_ids.csv`, `label_idsr2.csv`
- Writes: `MysteryShopping_r1V3.dta`, `MysteryShopping_r2V3.dta`, `MysteryShopping_all.dta`
- Imports both rounds, adds `round` variable based on submission date
- Renames sealed bag variables (`bag4_*` → `bag_*`)
- 30+ manual corrections for specific store/bag combinations (enumerator errors)
- Merges lab sample IDs for linking to ICRAF results

**`data/build/code/archive/expected_nitrogen.do`** --- Lab data merge
- Reads: `raw_mir_spectra.dta`, `mir_predicted_tool_total_CN_reported.dta`
- Merges spectroscopy data with mystery shopping samples via `label_id`
- Calculates `expected` nitrogen by fertilizer type: DAP=18%, Urea=46%, CAN=27% (Spring CAN=26%)
- Computes `diff` (actual minus expected) and `percent` (diff/expected)

**`data/function/code/ff_stores_distance.do`** --- Store proximity and variable construction
- Reads: `manufacturer_fertilizer.dta`
- Writes: `addvars.dta`, `mystery_addvars.dta`
- Computes pairwise geodist between all 189 stores at 1km, 3km, 5km, and 10km radii
- Creates asset ownership dummies (cellphone, smartphone, computer, vehicle, truck, motorbike)
- Creates quality perception dummies (10 good/bad pairs: bag weight, package condition, labeling, supplier trust, etc.)
- Keeps one observation per store, merges onto `MysteryShopping_all.dta`
- Requires `geodist` package (`ssc install geodist`)

**`data/function/code/ff_summary_stats.do`** --- Summary statistics and figures
- Reads: `mystery_addvars.dta`
- Writes: `summary_stats.tex`, histograms (DAP, CAN, Urea, CAN by manufacturer), purchase distribution
- Also copies `summary_stats.tex` to Overleaf folder (hardcoded path)
- Creates `purchase_success` variable (did mystery shopper obtain a sample?)
- Generates education dummies, county dummies
- Creates physical quality indicators (clumps, dark, oily, foreign materials, powdered, wet, dry)
- Missing `log close` at end

### 6b. Earlier versions and working copies

**`Alison/ff_master.do`** --- Original master (Mar 2018)
- Points to `Alison\` subfolder for scripts instead of `data/build/code/`
- Calls `reshape_inputsurvey_fertilizer.do` and `mysteryshopping_import_clean.do`
- Directly merges lab data (raw MIR spectra + predicted CN)
- Generates `diff` and `percent` variables inline
- Uses `plottig` scheme instead of `plotplain`
- This is the earliest version of the analysis pipeline

**`Alison/Expected Nitrogen.do`** --- Alison's master (Jan 2018)
- Runs reshape then mystery shopping clean, then merges lab data
- Creates expected nitrogen variable
- Log opening commented out

**`Alison/Basic Input Survey_cleaned up_Summary Stats.do`** --- Standalone analysis (Mar 2019)
- 486 lines: geodist calculations + summary stats + RTF output
- Contains the same geodist loop as `ff_stores_distance.do` but hardcoded to 189 observations
- Duplicated identically in `data/` and `admin/` folders

### 6c. Survey/Stata/ folder---the reshape modules

These scripts each handle one repeat-group section of the SurveyCTO input survey:

| Script | Module | Output | Key variables |
|--------|--------|--------|---------------|
| `reshape_inputsurvey_fertilizer.do` | Fertilizer inventory | `manufacturer_fertilizer.dta` | fert_type, manufacturer, price, cost, bag sizes |
| `reshape_inputsurvey_names.do` | Supplier names | `inputsurvey_otherbusinesses.dta` | Other businesses, respondent info |
| `reshape_inputsurvey_otherstores.do` | Known competitors | `inputsurvey_otherstores_networkid.dta` | Other store names, distances, network IDs |
| `reshape_inputsurvey_storagecapacity.do` | Storage facilities | `inputsurvey_storagecapacity.dta` | Storage type, quantity, unit |
| `reshape_inputsurvey_supplierquestions.do` | Supplier relationships | `inputsurvey_supplierquestions.dta` | Supplier type, credit terms, supply months |
| `reshape_fertilizerandmanufV4.do` | Combined fert+manuf | `manufacturer_fertilizer.dta` | Most complete version with full labels |

The `reshape_fertilizerandmanuf*.do` files are versioned iterations:
- **V1** (Jun 28, 2017): Base version, minimal manufacturer handling
- **V2** (Jun 29, 2017): Adds string-matching for Spring/Thabiti/Mavuno/Ruiru manufacturers
- **V3** (Jul 2, 2017): Simplifies, removes GPS from keep statement
- **V4** (Jul 1, 2017): Most comprehensive---full variable labeling, GPS retained, all error corrections, concern/quality scales

**`clean_inputsurvey.do`** and **`clean_inputsurvey_ET.do`** --- identical files (Jun 27, 2017) that reshape the survey long on supplier, nesting fertilizer within supplier. Uses a different directory path (`D:/Kikis Stuff/...`), suggesting a different collaborator's machine.

### 6d. Round 2 scripts (`data/round 2/From Hilda 20180329/`)

| Script | Date | Description |
|--------|------|-------------|
| `fertilizer files.do` | May 2018 | Imports Round 2 fertilizer CSV using legacy `insheet`; renames bag variables |
| `mysteryshopping.do` | May 2018 | Imports Round 2 mystery shopping; basic variable renaming |
| `mysteryshoppingv2.do` | Aug 2018 | Adds reshape long attempt; ends with `stop` (unfinished) |

These appear to be Hilda's (a research assistant) initial processing of Round 2 field data before it was integrated into the main pipeline.

---

## 7. Timeline of development

| Date | Event | Evidence |
|------|-------|----------|
| **Apr 2017** | Field data collection begins | SurveyCTO media files dated Apr 13, 2017 |
| **Jun 2017** | First cleaning scripts written | `clean_inputsurvey.do` (Jun 27), `reshape_fertilizerandmanuf.do` (Jun 28) |
| **Jun--Jul 2017** | Rapid iteration on fertilizer reshape | V1→V2→V3→V4 over 4 days (Jun 28 -- Jul 2) |
| **Sep 2017** | Reshape modules finalized | All 5 `reshape_inputsurvey_*.do` files (Sep 6), plus raw CSVs deposited |
| **Sep--Oct 2017** | Summary stats analysis begins | `admin/Basic Input Survey...do` (Sep 30), `data/` copy (Oct 3) |
| **Dec 2017** | Alison joins / takes over cleaning | All `Alison/*.do` files dated Dec 20, 2017; lab data (.dta) arrives |
| **Jan 2018** | Lab data integration | `Alison/Expected Nitrogen.do` (Jan 5) |
| **Mar 2018** | Alison's master file; data/ copies created | `Alison/ff_master.do` (Mar 8); `data/*.do` copies (Mar 8) |
| **Mar--May 2018** | Round 2 field work | Round 2 mystery shopping data, Hilda's scripts (May 2018) |
| **Aug 2018** | Pipeline restructured into build/function | `ff_stores_distance.do`, `ff_summary_stats.do`, archive scripts all dated Aug 2018 |
| **Aug 2018** | Key outputs generated | All histograms, summary_stats.tex, mystery_addvars.dta dated Aug 18--20, 2018 |
| **Mar 2019** | Final cleaning pass | Archive scripts updated (Mar 12--18), final .dta outputs generated |
| **Mar 2019** | Last substantive work | `agrovet_survey_cleanish.dta` and `agrovet_survey_gps.dta` (Mar 18, 2019) |

The project appears dormant from **March 2019 to present** (7 years).

---

## 8. Duplication map

Many scripts exist in 3--5 locations with minor variations. The canonical version (most recent, most complete) is listed first:

| Script | Canonical | Duplicates |
|--------|-----------|------------|
| Input survey reshape | `data/build/code/archive/reshape_inputsurvey_fertilizerV2.do` (Mar 2019) | `Survey/Stata/reshape_fertilizerandmanufV4.do`, `data/reshape_inputsurvey_fertilizer.do`, `Alison/reshape_inputsurvey_fertilizer.do`, `Survey/Stata/reshape_inputsurvey_fertilizer.do` |
| Mystery shopping clean | `data/build/code/archive/mysteryshopping_import_clean.do` (Mar 2019) | `Survey/Stata/mysteryshopping_import_clean.do`, `data/mysteryshopping_import_clean.do`, `Alison/mysteryshopping_import_clean.do` |
| Summary stats | `data/function/code/ff_summary_stats.do` (Aug 2018) | `Alison/Basic Input Survey...do`, `data/Basic Input Survey...do`, `admin/Basic Input Survey...do` |
| Store distance | `data/function/code/ff_stores_distance.do` (Mar 2019) | Distance loop also embedded in `Alison/Basic Input Survey...do` |
| Master | `data/build/code/ff_master.do` | `Alison/ff_master.do`, `Alison/Expected Nitrogen.do` |
| Reshape: names | `Survey/Stata/reshape_inputsurvey_names.do` | `Alison/reshape_inputsurvey_names.do`, `data/reshape_inputsurvey_names.do` |
| Reshape: other stores | `Survey/Stata/reshape_inputsurvey_otherstores.do` | `Alison/reshape_inputsurvey_otherstores.do`, `data/reshape_inputsurvey_otherstores.do` |
| Reshape: storage | `Survey/Stata/reshape_inputsurvey_storagecapacity.do` | `Alison/reshape_inputsurvey_storagecapacity.do`, `data/reshape_inputsurvey_storagecapacity.do` |
| Reshape: suppliers | `Survey/Stata/reshape_inputsurvey_supplierquestions.do` | `Alison/reshape_inputsurvey_supplierquestions.do`, `data/reshape_inputsurvey_supplierquestions.do` |
| Summary stats (simple) | `Survey/Stata/inputsurvey_summarystats.do` | `Alison/inputsurvey_summarystats.do`, `data/inputsurvey_summarystats.do` |

---

## 9. What's missing or broken

### Missing files referenced by scripts
- `agrovet_survey_addvars.do` --- called by `ff_master.do` but doesn't exist (likely renamed to `ff_stores_distance.do`)
- `agrovet_survey_addquality.do` --- called by `ff_master.do` but doesn't exist
- `network_IDs` dataset --- referenced by `reshape_inputsurvey_otherstores.do` but not in `build/input/`
- Overleaf copy target (`C:\Users\Emilia\Dropbox\Apps\Overleaf/Fake fertilizer/Tables/`) --- hardcoded, won't work locally

### Code quality issues
- **No `clear all` in any script** --- all assume they're called from the master or have a clean workspace
- **Missing `log close`** in `ff_summary_stats.do` (opens log but never closes)
- **Log commented out** in `ff_master.do` and `Alison/Expected Nitrogen.do`
- **All paths hardcoded** to `C:\Users\Emilia\Dropbox\Fake fertilizer\PEDL\data` or `D:/Kikis Stuff/...`
- **Hardcoded loop limits** (189 in geodist calculations) will break if store count changes
- **30+ manual ID corrections** in mystery shopping clean --- fragile, undocumented rationale
- **`stop` command** in `mysteryshoppingv2.do` --- unfinished code

### Data gaps
- Population density raster (`ken-popkenpopmap15adjv2b`) is referenced by no script---may have been used in GIS software (ArcGIS/QGIS) outside Stata
- `Migori fertilizer cn_pxrf data.csv` is referenced by no script---pXRF data may not yet be integrated
- No script produces `map_purchase.png` or `map_round.png`---these may have been generated in a GIS tool or an untracked script
- The `Testing/` directory contains ICRAF lab protocols and results but no .do file processes them directly

### Structural issues
- The `ff_master.do` pipeline is broken: it references `reshape_inputsurvey_fertilizerV2.do` in `build/code/` but that file is in `build/code/archive/`
- The master also calls `agrovet_survey_addvars.do` which doesn't exist under that name
- Round 2 mystery shopping data (`MysteryShoppingr2.csv`) is integrated in the archive version of `mysteryshopping_import_clean.do` but not in the Survey/Stata version

---

## 10. Collaborator fingerprints

| Path pattern | Collaborator | Role |
|--------------|-------------|------|
| `C:\Users\Emilia\Dropbox\...` | Emilia Tjernstrom | PI, main analyst (Aug 2018 restructuring, function/ code) |
| `D:/Kikis Stuff/University of Wisconsin/...` | "Kiki" (RA) | Early survey cleaning (Jun 2017) |
| `Alison/` folder | Alison Hamm (RA) | Cleaning pipeline, lab data merge (Dec 2017 -- Mar 2018) |
| `data/round 2/From Hilda 20180329/` | Hilda (RA) | Round 2 data entry and initial processing (Mar--May 2018) |
| `Survey/Stata/` | Multiple | Shared working directory for survey cleaning scripts |
