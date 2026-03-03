* ============================================================
* Import BEA NIPA Supplementary Tables
* Project: Capital and Labor Shares in Healthcare
* Purpose: Import proprietors' income and CFC CSVs (produced
*          by fetch_nipa_supplements.py), save as .dta
* Inputs:  ../output/nipa_proprietors_income.csv
*          ../output/nipa_cfc.csv
* Outputs: ../output/proprietors_income_by_industry_raw.dta
*          ../output/cfc_by_industry_raw.dta
* ============================================================

version 18
clear all
set seed 20260225

log using "download_bea_nipa_supplements.log", replace

* --- 1. Import proprietors' income ---
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

* --- 2. Import consumption of fixed capital ---
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

* --- 3. Verification ---
display _n "=== Verification ==="

use "../output/proprietors_income_by_industry_raw.dta", clear
display "Proprietors' income: " _N " observations"

use "../output/cfc_by_industry_raw.dta", clear
display "CFC: " _N " observations"

display _n "All supplementary NIPA tables imported successfully."
log close
