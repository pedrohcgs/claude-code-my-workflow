* ============================================================
* Import BLS QCEW Annual Averages
* Project: Capital and Labor Shares in Healthcare
* Purpose: Import raw QCEW CSVs (downloaded by download_qcew.sh),
*          filter to national level, append all years, save .dta
* Inputs:  ../output/raw/*.annual.singlefile.csv (from download_qcew.sh)
* Outputs: ../output/qcew_annual_national_raw.dta
* ============================================================

version 18
clear all
set seed 20260225

log using "download_bls_qcew.log", replace

* --- 1. Import and append all years ---
local start_year = 1997
local end_year = 2024

display _n "Importing and appending QCEW files..."

tempfile master
save `master', emptyok

forvalues y = `start_year'/`end_year' {
    local csv_file = "../output/raw/`y'.annual.singlefile.csv"
    capture confirm file "`csv_file'"
    if _rc == 0 {
        display "  Importing `y'..."
        quietly {
            import delimited using "`csv_file'", clear varnames(1) stringcols(_all)

            * Strip quotes from area_fips (BLS CSVs are quoted)
            replace area_fips = subinstr(area_fips, `"""', "", .)

            * Filter to national level immediately to save memory
            keep if area_fips == "US000"

            append using `master'
            save `master', replace
        }
    }
    else {
        display "  `y': file not found, skipping"
    }
}

use `master', clear
display _n "Total national-level observations: " _N

* --- 2. Clean and standardize ---
display _n "Cleaning variables..."

* Strip quotes from string variables (BLS CSVs quote everything)
foreach var of varlist _all {
    capture confirm string variable `var'
    if _rc == 0 {
        quietly replace `var' = subinstr(`var', `"""', "", .)
    }
}

* Destring numeric variables
foreach var in own_code agglvl_code size_code year qtr disclosure_code ///
    annual_avg_estabs annual_avg_emplvl total_annual_wages ///
    taxable_annual_wages annual_contributions annual_avg_wkly_wage ///
    avg_annual_pay lq_annual_avg_estabs lq_annual_avg_emplvl ///
    lq_total_annual_wages lq_taxable_annual_wages lq_annual_contributions ///
    lq_annual_avg_wkly_wage lq_avg_annual_pay ///
    oty_annual_avg_estabs_chg oty_annual_avg_estabs_pct_chg ///
    oty_annual_avg_emplvl_chg oty_annual_avg_emplvl_pct_chg ///
    oty_total_annual_wages_chg oty_total_annual_wages_pct_chg ///
    oty_taxable_annual_wages_chg oty_taxable_annual_wages_pct_chg ///
    oty_annual_contributions_chg oty_annual_contributions_pct_chg ///
    oty_annual_avg_wkly_wage_chg oty_annual_avg_wkly_wage_pct_chg ///
    oty_avg_annual_pay_chg oty_avg_annual_pay_pct_chg {
    capture destring `var', replace force
}

* Label key variables
capture label variable area_fips "FIPS area code"
capture label variable own_code "Ownership code (0=all, 5=private)"
capture label variable industry_code "NAICS industry code"
capture label variable agglvl_code "Aggregation level code"
capture label variable year "Year"
capture label variable annual_avg_estabs "Annual average establishments"
capture label variable annual_avg_emplvl "Annual average employment level"
capture label variable total_annual_wages "Total annual wages (dollars)"
capture label variable avg_annual_pay "Average annual pay (dollars)"
capture label variable annual_avg_wkly_wage "Average weekly wage (dollars)"

* --- 3. Validation ---
display _n "=== QCEW Summary ==="
display "Total observations: " _N

tab year, missing
tab own_code, missing

* Check healthcare industries
count if industry_code == "62"
display "NAICS 62 (Healthcare total) rows: " r(N)

count if industry_code == "621"
display "NAICS 621 (Ambulatory) rows: " r(N)

count if industry_code == "622"
display "NAICS 622 (Hospitals) rows: " r(N)

count if industry_code == "623"
display "NAICS 623 (Nursing) rows: " r(N)

* --- 4. Save ---
compress
save "../output/qcew_annual_national_raw.dta", replace

display _n "=== Verification ==="
display "Observations: " _N

quietly summarize year
display "Year range: " r(min) " to " r(max)
assert r(min) <= 2000
assert r(max) >= 2020

count if industry_code == "62" & own_code == 5
assert r(N) > 0

display _n "QCEW import complete."
log close
