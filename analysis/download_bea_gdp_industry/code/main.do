* ============================================================
* Download BEA GDP-by-Industry Data
* Project: Capital and Labor Shares in Healthcare
* Purpose: Call Python API helper, import CSVs, save as .dta
* Inputs:  inputs/bea_api_key.txt (user provides)
* Outputs: outputs/bea_va_components_raw.dta
*          outputs/bea_chain_indexes_raw.dta
*          outputs/data_vintage.txt
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "outputs/download_bea_gdp_industry.log", replace

* --- 0. Setup ---
local task_root = c(pwd)

* --- 1. Check for API key ---
capture confirm file "inputs/bea_api_key.txt"
if _rc != 0 {
    display as error "ERROR: BEA API key not found at inputs/bea_api_key.txt"
    display as error "Sign up for a free key at: https://apps.bea.gov/api/signup/"
    display as error "Save the key (plain text, one line) to inputs/bea_api_key.txt"
    log close
    error 601
}

* --- 2. Run Python API helper ---
* Check if CSVs already exist (skip download if so)
capture confirm file "outputs/bea_va_components.csv"
local need_download = _rc != 0

if `need_download' {
    display "Running Python BEA API helper..."
    shell python3 code/fetch_bea_api.py

    * Verify download succeeded
    capture confirm file "outputs/bea_va_components.csv"
    if _rc != 0 {
        display as error "ERROR: Python API helper did not produce bea_va_components.csv"
        display as error "Check outputs/ for error logs. Try manual download (see code/README_manual.md)"
        log close
        error 601
    }
}
else {
    display "CSVs already exist in outputs/. Skipping download."
    display "Delete outputs/*.csv to force re-download."
}

* --- 3. Import VA components ---
display _n "Importing VA components..."
import delimited using "outputs/bea_va_components.csv", clear varnames(1) stringcols(_all)

* Standardize variable names (BEA API uses varying capitalization)
capture rename tableid table_id
capture rename sourcetableid source_table_id
capture rename industryid industry_id
capture rename industrydescription industry_desc
capture rename datavalue data_value
capture rename year year_str

* Clean data values: remove commas, handle suppressed values
capture gen str data_value_clean = subinstr(data_value, ",", "", .)
capture destring data_value_clean, gen(value) force
capture destring year_str, gen(year) force
capture destring year, replace force

* Label variables
capture label variable table_id "BEA table ID"
capture label variable industry_id "NAICS industry code"
capture label variable industry_desc "Industry description"
capture label variable value "Data value (millions of current dollars)"
capture label variable year "Year"

* Document what we have
display _n "=== VA Components Summary ==="
display "Observations: " _N
capture tab source_table_id, missing
capture tab year if !missing(year), missing
capture tab industry_id if strpos(industry_id, "62") > 0

compress
save "outputs/bea_va_components_raw.dta", replace

* --- 4. Import chain-type quantity indexes ---
capture confirm file "outputs/bea_chain_indexes.csv"
if _rc == 0 {
    display _n "Importing chain-type quantity indexes..."
    import delimited using "outputs/bea_chain_indexes.csv", clear varnames(1) stringcols(_all)

    * Same standardization
    capture rename tableid table_id
    capture rename industryid industry_id
    capture rename industrydescription industry_desc
    capture rename datavalue data_value

    capture gen str data_value_clean = subinstr(data_value, ",", "", .)
    capture destring data_value_clean, gen(value) force
    capture destring year, replace force

    capture label variable industry_id "NAICS industry code"
    capture label variable value "Chain-type quantity index (2017=100)"
    capture label variable year "Year"

    display _n "=== Chain Indexes Summary ==="
    display "Observations: " _N

    compress
    save "outputs/bea_chain_indexes_raw.dta", replace
}
else {
    display "No chain index CSV found. Skipping."
}

* --- 5. Verification ---
display _n "=== Verification ==="
use "outputs/bea_va_components_raw.dta", clear
display "VA components: " _N " observations"

* Check healthcare industries present
count if strpos(industry_id, "62") > 0
local n_healthcare = r(N)
display "Healthcare-related rows: `n_healthcare'"
assert `n_healthcare' > 0

* Check year range
quietly summarize year
display "Year range: " r(min) " to " r(max)
assert r(min) <= 2000
assert r(max) >= 2020

display _n "Download and import complete."
log close
