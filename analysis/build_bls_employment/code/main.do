* ============================================================
* Build BLS Employment Panel
* Project: Capital and Labor Shares in Healthcare
* Purpose: Clean QCEW data into an industry-year panel of
*          employment and wages for target industries
* Inputs:  inputs/bls_qcew_raw/qcew_annual_national_raw.dta
* Outputs: outputs/bls_employment_panel.dta
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "outputs/build_bls_employment.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Load raw QCEW ---
display "Loading raw QCEW data..."
use "inputs/bls_qcew_raw/qcew_annual_national_raw.dta", clear
display "Raw observations: " _N

* --- 2. Filter to target industries and aggregation level ---
* QCEW has multiple aggregation levels. We want:
*   agglvl_code = 14 (NAICS 2-digit, national, by ownership)
*   agglvl_code = 15 (NAICS 3-digit, national, by ownership)
*   agglvl_code = 10 (total, all industries, national, by ownership)
* Some industry codes like "31-33" are supersectors

* Keep relevant aggregation levels:
*   agglvl_code 10 = total, all industries, national, by ownership
*   agglvl_code 14 = NAICS sector (2-digit), national, by ownership
*   agglvl_code 15 = NAICS subsector (3-digit), national, by ownership
* Exclude supersector levels (11-13, 16) to avoid duplicates
keep if inlist(agglvl_code, 10, 14, 15)

display "After aggregation level filter: " _N

* --- 3. Map to target NAICS codes ---
gen str10 naics_code = ""

* Healthcare
replace naics_code = "62"    if industry_code == "62"   & agglvl_code == 14
replace naics_code = "621"   if industry_code == "621"  & agglvl_code == 15
replace naics_code = "622"   if industry_code == "622"  & agglvl_code == 15
replace naics_code = "623"   if industry_code == "623"  & agglvl_code == 15

* Comparison industries (all 2-digit NAICS sectors)
replace naics_code = "31-33" if industry_code == "31-33" & agglvl_code == 14
replace naics_code = "52"    if industry_code == "52"    & agglvl_code == 14
replace naics_code = "44-45" if industry_code == "44-45" & agglvl_code == 14
replace naics_code = "54"    if industry_code == "54"    & agglvl_code == 14
replace naics_code = "61"    if industry_code == "61"    & agglvl_code == 14
replace naics_code = "51"    if industry_code == "51"    & agglvl_code == 14
replace naics_code = "23"    if industry_code == "23"    & agglvl_code == 14

* Total economy
replace naics_code = "total" if industry_code == "10"    & agglvl_code == 10

* Keep only target industries
keep if naics_code != ""
display "After industry filter: " _N

* --- 4. Keep key variables ---
keep naics_code industry_code own_code year ///
    annual_avg_estabs annual_avg_emplvl total_annual_wages ///
    avg_annual_pay annual_avg_wkly_wage ///
    oty_annual_avg_emplvl_pct_chg oty_total_annual_wages_pct_chg

* --- 5. Create derived measures ---
* Total annual wage bill in millions (for comparability with BEA data in millions)
gen wage_bill_millions = total_annual_wages / 1000000
label variable wage_bill_millions "Total annual wages (millions of dollars)"

* Employment share of total economy
* Extract total economy employment into a year x own_code lookup
preserve
    keep if naics_code == "total"
    keep year own_code annual_avg_emplvl total_annual_wages
    rename annual_avg_emplvl total_empl
    rename total_annual_wages total_wages
    tempfile totals
    save `totals'
restore

merge m:1 year own_code using `totals', keep(master match) nogenerate

gen empl_share = annual_avg_emplvl / total_empl if total_empl > 0
label variable empl_share "Employment share of total economy"

gen wage_share = total_annual_wages / total_wages if total_wages > 0
label variable wage_share "Wage share of total economy"

drop total_empl total_wages

* --- 6. Label variables ---
label variable naics_code "NAICS industry code"
label variable industry_code "Original BLS industry code"
label variable own_code "Ownership (0=all, 5=private)"
label variable year "Year"
label variable annual_avg_estabs "Annual average establishments"
label variable annual_avg_emplvl "Annual average employment"
label variable total_annual_wages "Total annual wages (dollars)"
label variable avg_annual_pay "Average annual pay (dollars)"
label variable annual_avg_wkly_wage "Average weekly wage (dollars)"

* --- 7. Validate ---
display _n "=== Validation ==="

* Check uniqueness
isid naics_code year own_code

* Check all target industries present (for private ownership)
tab naics_code if own_code == 5, missing

* Check year range
summarize year
assert r(min) <= 2000
assert r(max) >= 2020

* Employment should be positive
count if annual_avg_emplvl <= 0 & own_code == 5
local n_nonpos = r(N)
display "Non-positive employment rows (private): `n_nonpos'"

* Healthcare specific
list naics_code year annual_avg_emplvl avg_annual_pay ///
    if naics_code == "62" & own_code == 5 & year >= 2020, noobs

* --- 8. Save ---
label data "BLS QCEW employment panel, target NAICS industries, national"
compress
save "outputs/bls_employment_panel.dta", replace

display _n "=== Final Summary ==="
display "Observations: " _N
tab naics_code own_code, missing

display _n "Build complete."
log close
