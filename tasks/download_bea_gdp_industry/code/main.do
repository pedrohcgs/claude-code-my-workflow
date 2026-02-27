* ============================================================
* Download BEA GDP-by-Industry Data
* Project: Capital and Labor Shares in Healthcare
* Purpose: Import BEA data via API (primary) or NIPA bulk (fallback),
*          save as .dta files for downstream analysis
* Inputs:  inputs/bea_api_key.txt (user provides)
* Outputs: outputs/bea_va_panel.dta       (API: VA components by industry)
*          outputs/nipa_comp.dta           (NIPA fallback: compensation)
*          outputs/nipa_natl_income.dta    (NIPA fallback: national income)
*          outputs/nipa_prop_income.dta    (NIPA fallback: prop income)
*          outputs/nipa_self_employed.dta  (NIPA fallback: self-employed)
*          outputs/nipa_fte_employees.dta  (NIPA fallback: FTE employees)
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "output/download_bea_gdp_industry.log", replace

* --- 0. Setup ---
local task_root = c(pwd)

* --- 1. Try BEA API first ---
display "Attempting BEA API download..."
capture confirm file "input/bea_api_key.txt"
if _rc == 0 {
    * Always re-run API fetch if key exists (may have been activated)
    shell python3 code/fetch_bea_api.py
}

* --- 2. Preprocess API data if available ---
capture confirm file "output/bea_va_components.csv"
local api_success = 0
if _rc == 0 {
    * Check that the CSV has actual data (not just headers)
    quietly import delimited using "output/bea_va_components.csv", clear
    if _N > 100 {
        local api_success = 1
        clear
        * Run preprocessing to create clean panel
        display "Preprocessing API data..."
        shell python3 code/preprocess_bea_api.py
    }
    else {
        display "API CSV has too few rows (_N = " _N "). Falling back to NIPA."
        clear
    }
}

* --- 3. Import BEA VA panel (from API) ---
capture confirm file "output/bea_va_panel.csv"
if _rc == 0 {
    display _n "=== Importing BEA GDP-by-Industry Panel ==="
    import delimited using "output/bea_va_panel.csv", clear varnames(1) ///
        stringcols(1 3)

    * Convert value_added etc from billions to millions for consistency with NIPA
    foreach var in value_added comp_employees gos topi {
        replace `var' = `var' * 1000
        label variable `var' "`var' (millions of current $)"
    }
    label variable value_added "Value added (millions of current $)"
    label variable comp_employees "Compensation of employees (millions of current $)"
    label variable gos "Gross operating surplus (millions of current $)"
    label variable topi "Taxes on production & imports less subsidies (millions $)"
    label variable naics_code "NAICS industry code"
    label variable year "Year"
    label variable industry_label "Industry description"

    * Compute labor share directly from VA components
    gen labor_share_va = comp_employees / value_added if value_added > 0
    gen capital_share_va = gos / value_added if value_added > 0
    gen topi_share_va = topi / value_added if value_added > 0
    label variable labor_share_va "Labor share (CE/VA)"
    label variable capital_share_va "Capital share (GOS/VA)"
    label variable topi_share_va "Tax share (TOPI/VA)"

    * Verify: shares should sum to ~1
    gen share_sum = labor_share_va + capital_share_va + topi_share_va
    summarize share_sum
    assert abs(share_sum - 1) < 0.005 if !missing(share_sum)
    drop share_sum

    * Add industry_group for downstream compatibility
    gen str20 industry_group = ""
    replace industry_group = "construction"       if naics_code == "23"
    replace industry_group = "manufacturing"       if naics_code == "31-33"
    replace industry_group = "retail"              if naics_code == "44-45"
    replace industry_group = "information"         if naics_code == "51"
    replace industry_group = "finance"             if naics_code == "52"
    replace industry_group = "professional"        if naics_code == "54"
    replace industry_group = "education"           if naics_code == "61"
    replace industry_group = "educ_health"         if naics_code == "61-62"
    replace industry_group = "healthcare_total"    if naics_code == "62"
    replace industry_group = "ambulatory"          if naics_code == "621"
    replace industry_group = "hospitals"           if naics_code == "622"
    replace industry_group = "nursing"             if naics_code == "623"
    replace industry_group = "social_assistance"   if naics_code == "624"
    replace industry_group = "private_industries"  if naics_code == "private"
    replace industry_group = "total_economy"       if naics_code == "total"
    label variable industry_group "Industry group label"

    * Validation
    display _n "=== BEA VA Panel Validation ==="
    isid naics_code year
    tab naics_code, missing
    summarize year
    summarize labor_share_va capital_share_va

    * Healthcare summary
    display _n "Healthcare labor shares (CE/VA):"
    list naics_code year labor_share_va capital_share_va ///
        if inlist(naics_code, "62", "621", "622", "623") & year >= 2020, ///
        noobs sepby(naics_code)

    label data "BEA GDP-by-Industry VA components panel"
    compress
    save "output/bea_va_panel.dta", replace
    display "Saved: bea_va_panel.dta (" _N " observations)"
}
else {
    display as error "BEA VA panel not available."
}

* --- 4. NIPA bulk fallback (always run for supplementary data) ---
* The NIPA tables provide proprietors' income, self-employment, and FTE data
* that the GDP-by-Industry dataset does not include.

display _n "=== NIPA Supplementary Data ==="

* Download NIPA bulk data if not present
capture confirm file "output/NipaDataA.txt"
if _rc != 0 {
    display "Downloading NipaDataA.txt from BEA..."
    shell curl -sS -o "output/NipaDataA.txt" "https://apps.bea.gov/national/Release/TXT/NipaDataA.txt"
}
capture confirm file "output/SeriesRegister.txt"
if _rc != 0 {
    display "Downloading SeriesRegister.txt..."
    shell curl -sS -o "output/SeriesRegister.txt" "https://apps.bea.gov/national/Release/TXT/SeriesRegister.txt"
}

* Run NIPA extraction (produces compensation, NI, prop income, self-employed, FTE)
capture confirm file "output/nipa_comp.csv"
if _rc != 0 {
    display "Extracting supplementary data from NIPA bulk file..."
    shell python3 code/extract_nipa_bulk.py
}

* Import NIPA supplementary datasets
foreach dataset in nipa_comp nipa_natl_income nipa_prop_income nipa_self_employed nipa_fte_employees {
    capture confirm file "output/`dataset'.csv"
    if _rc == 0 {
        import delimited using "output/`dataset'.csv", clear varnames(1) stringcols(1 4 5)

        * Rename value column based on dataset
        if "`dataset'" == "nipa_comp" {
            rename value comp_employees
            label variable comp_employees "Compensation of employees (millions, NIPA)"
        }
        else if "`dataset'" == "nipa_natl_income" {
            rename value natl_income
            label variable natl_income "National income (millions, NIPA)"
        }
        else if "`dataset'" == "nipa_prop_income" {
            rename value prop_income
            label variable prop_income "Nonfarm proprietors' income (millions, NIPA)"
        }
        else if "`dataset'" == "nipa_self_employed" {
            rename value n_self_employed
            label variable n_self_employed "Nonfarm self-employed (thousands, NIPA)"
        }
        else if "`dataset'" == "nipa_fte_employees" {
            rename value fte_employees
            label variable fte_employees "Full-time equivalent employees (thousands, NIPA)"
        }

        compress
        save "output/`dataset'.dta", replace
        display "  `dataset': " _N " observations"
    }
    else {
        display "  `dataset'.csv: not found (skipping)"
    }
}

* --- 5. Final verification ---
display _n "=== Final Verification ==="

* BEA VA panel
capture confirm file "output/bea_va_panel.dta"
if _rc == 0 {
    quietly use "output/bea_va_panel.dta", clear
    quietly count if inlist(naics_code, "62", "621", "622", "623")
    display "  bea_va_panel.dta: " _N " obs, " r(N) " healthcare"
    display "  STATUS: GDP-by-Industry VA data AVAILABLE"
}
else {
    display as error "  bea_va_panel.dta: MISSING"
    display as error "  STATUS: Using NIPA fallback only (limited factor shares)"
}

* NIPA supplementary
foreach dataset in nipa_prop_income nipa_self_employed nipa_fte_employees {
    capture confirm file "output/`dataset'.dta"
    if _rc == 0 {
        quietly use "output/`dataset'.dta", clear
        quietly count if naics_code == "62"
        display "  `dataset': " _N " obs, " r(N) " healthcare"
    }
    else {
        display "  `dataset': MISSING"
    }
}

display _n "Download and import complete."
log close
