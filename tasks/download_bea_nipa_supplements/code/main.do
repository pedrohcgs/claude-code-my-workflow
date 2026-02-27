* ============================================================
* Download BEA NIPA Supplementary Tables
* Project: Capital and Labor Shares in Healthcare
* Purpose: Fetch proprietors' income and CFC by industry,
*          import CSVs, save as .dta
* Inputs:  BEA API key (shared with download_bea_gdp_industry)
* Outputs: ../output/proprietors_income_by_industry_raw.dta
*          ../output/cfc_by_industry_raw.dta
*          ../output/data_vintage.txt
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "../output"
log using "download_bea_nipa_supplements.log", replace

* --- 0. Setup ---
local task_root = c(pwd)

* --- 1. Check for API key (shared with main BEA download) ---
local key_found = 0
capture confirm file "../input/bea_api_key.txt"
if _rc == 0 {
    local key_found = 1
}
capture confirm file "../../download_bea_gdp_industry/input/bea_api_key.txt"
if _rc == 0 {
    local key_found = 1
}
if `key_found' == 0 {
    display as error "ERROR: BEA API key not found."
    display as error "Place at: ../input/bea_api_key.txt"
    display as error "Or at: ../../download_bea_gdp_industry/input/bea_api_key.txt"
    log close
    error 601
}

* --- 2. Run Python helper ---
capture confirm file "../output/nipa_proprietors_income.csv"
local need_download = _rc != 0

if `need_download' {
    display "Running Python NIPA supplements helper..."
    shell python3 fetch_nipa_supplements.py
}
else {
    display "CSVs already exist. Skipping download."
    display "Delete ../output/*.csv to force re-download."
}

* --- 3. Import proprietors' income ---
capture confirm file "../output/nipa_proprietors_income.csv"
if _rc == 0 {
    display _n "Importing proprietors' income by industry..."
    import delimited using "../output/nipa_proprietors_income.csv", clear varnames(1) stringcols(_all)

    * Standardize variable names
    capture rename tablename table_name
    capture rename seriescode series_code
    capture rename linenumber line_number
    capture rename linedescription line_desc
    capture rename timelabel time_label
    capture rename datavalue data_value

    * Clean values
    capture gen str data_value_clean = subinstr(data_value, ",", "", .)
    capture destring data_value_clean, gen(value) force
    capture destring year, replace force

    capture label variable value "Proprietors' income (millions of current dollars)"

    display "=== Proprietors' Income Summary ==="
    display "Observations: " _N
    capture tab table_name, missing

    compress
    save "../output/proprietors_income_by_industry_raw.dta", replace
}
else {
    display as error "WARNING: No proprietors' income CSV found."
    display as error "Manual download may be needed. See BEA NIPA Table 6.12D."
}

* --- 4. Import consumption of fixed capital ---
capture confirm file "../output/nipa_cfc.csv"
if _rc == 0 {
    display _n "Importing consumption of fixed capital by industry..."
    import delimited using "../output/nipa_cfc.csv", clear varnames(1) stringcols(_all)

    capture rename tablename table_name
    capture rename seriescode series_code
    capture rename linenumber line_number
    capture rename linedescription line_desc
    capture rename datavalue data_value

    capture gen str data_value_clean = subinstr(data_value, ",", "", .)
    capture destring data_value_clean, gen(value) force
    capture destring year, replace force

    capture label variable value "Consumption of fixed capital (millions of current dollars)"

    display "=== CFC Summary ==="
    display "Observations: " _N

    compress
    save "../output/cfc_by_industry_raw.dta", replace
}
else {
    display as error "WARNING: No CFC CSV found."
    display as error "Manual download may be needed. See BEA Fixed Assets Table 6.2."
}

* --- 5. Verification ---
display _n "=== Verification ==="
local all_ok = 1

capture confirm file "../output/proprietors_income_by_industry_raw.dta"
if _rc == 0 {
    use "../output/proprietors_income_by_industry_raw.dta", clear
    display "Proprietors' income: " _N " observations"
}
else {
    display as error "Proprietors' income: MISSING"
    local all_ok = 0
}

capture confirm file "../output/cfc_by_industry_raw.dta"
if _rc == 0 {
    use "../output/cfc_by_industry_raw.dta", clear
    display "CFC: " _N " observations"
}
else {
    display as error "CFC: MISSING"
    local all_ok = 0
}

if `all_ok' {
    display _n "All supplementary NIPA tables downloaded successfully."
}
else {
    display _n as error "Some tables missing. Check API table names or download manually."
}

log close
