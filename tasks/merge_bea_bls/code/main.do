* ============================================================
* Merge BEA and BLS Data
* Project: Capital and Labor Shares in Healthcare
* Purpose: Cross-validate BEA compensation vs BLS wages;
*          enrich factor share panel with employment data
* Inputs:  ../input/nipa_shares/nipa_industry_year_panel.dta
*          ../input/bls_employment/bls_employment_panel.dta
* Outputs: ../output/merged_bea_bls_panel.dta
*          ../output/cross_validation_report.txt
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "../output"
log using "merge_bea_bls.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Load BEA panel ---
display "Loading BEA NIPA panel..."
use "../input/nipa_shares/nipa_industry_year_panel.dta", clear
display "BEA observations: " _N

* Keep key variables for merge
* (variable names depend on build_nipa_shares output structure)
capture keep naics_code year value_added comp_employees gos ///
    taxes_less_subs industry_group industry_label value source_table_id
capture keep naics_code year value industry_group industry_label ///
    source_table_id component

* Verify uniqueness for merge
* BEA data may have multiple rows per industry-year (different components)
* We need one row per naics_code-year for the merge
capture isid naics_code year
if _rc != 0 {
    display "BEA data has multiple rows per industry-year."
    display "Collapsing for merge (keeping first observation per group)."
    * For cross-validation, we mainly need compensation of employees
    * Keep the comp_employees value if available
    capture {
        bysort naics_code year: keep if _n == 1
    }
}

tempfile bea
save `bea'

* --- 2. Load BLS panel ---
display _n "Loading BLS employment panel..."
use "../input/bls_employment/bls_employment_panel.dta", clear
display "BLS observations: " _N

* Keep private ownership as primary
keep if own_code == 5
display "After filtering to private (own_code=5): " _N

* Verify uniqueness
isid naics_code year

tempfile bls
save `bls'

* --- 3. Merge ---
display _n "Merging BEA and BLS..."
use `bea', clear
merge 1:1 naics_code year using `bls'

display _n "=== Merge Results ==="
tab _merge

* Document unmatched
count if _merge == 1
local n_bea_only = r(N)
count if _merge == 2
local n_bls_only = r(N)
count if _merge == 3
local n_matched = r(N)

display "BEA only (no BLS match): `n_bea_only'"
display "BLS only (no BEA match): `n_bls_only'"
display "Matched: `n_matched'"

* Keep matched for analysis; preserve all for documentation
gen byte merge_status = _merge
label define merge_lbl 1 "BEA only" 2 "BLS only" 3 "Matched"
label values merge_status merge_lbl
drop _merge

* --- 4. Cross-validation: BEA CE vs BLS wages ---
display _n "=== Cross-Validation: CE vs QCEW Wages ==="

* BEA compensation of employees (CE) should exceed BLS total wages
* because CE includes employer-paid supplements (~25% of wages):
*   - Employer contributions to social insurance
*   - Employer contributions to pension/insurance funds
*
* Expected ratio: CE / BLS_wages ~ 1.25-1.35

* BEA data is in millions; BLS total_annual_wages is in dollars
capture gen ce_bea_millions = comp_employees
capture gen wages_bls_millions = wage_bill_millions

capture gen ce_wage_ratio = ce_bea_millions / wages_bls_millions ///
    if merge_status == 3 & wages_bls_millions > 0

display _n "CE/Wage Ratio by Industry:"
capture tabstat ce_wage_ratio, by(naics_code) stat(mean sd min max N) format(%9.3f)

* Flag outliers (ratio outside 1.1-1.5)
capture gen byte ce_wage_flag = (ce_wage_ratio < 1.1 | ce_wage_ratio > 1.5) ///
    if !missing(ce_wage_ratio)
capture count if ce_wage_flag == 1
if _rc == 0 {
    display "Flagged outlier ratios: " r(N)
    capture list naics_code year ce_wage_ratio if ce_wage_flag == 1, noobs
}

* --- 5. Write cross-validation report ---
capture file close report
file open report using "../output/cross_validation_report.txt", write replace

file write report "Cross-Validation Report: BEA CE vs BLS QCEW Wages" _n
file write report "=======================================================" _n
file write report "Date: $S_DATE" _n _n

file write report "Merge Results:" _n
file write report "  BEA only: `n_bea_only'" _n
file write report "  BLS only: `n_bls_only'" _n
file write report "  Matched:  `n_matched'" _n _n

file write report "Expected: CE/Wages ~ 1.25-1.35 (supplements ~25%)" _n
file write report "Outlier threshold: ratio < 1.1 or > 1.5" _n _n

file write report "CE/Wage Ratio by Industry (matched obs, private ownership):" _n

capture {
    levelsof naics_code if merge_status == 3, local(industries)
    foreach ind in `industries' {
        quietly summarize ce_wage_ratio if naics_code == "`ind'"
        if r(N) > 0 {
            file write report "  `ind': mean=" %5.3f (r(mean)) ///
                " sd=" %5.3f (r(sd)) " N=" (r(N)) _n
        }
    }
}

file close report
display "Cross-validation report saved to ../output/cross_validation_report.txt"

* --- 6. Label and save ---
capture label variable ce_wage_ratio "BEA CE / BLS total wages ratio"
capture label variable ce_wage_flag "CE/wage ratio outside 1.1-1.5 range"
capture label variable merge_status "BEA-BLS merge status"

label data "Merged BEA-BLS panel, target NAICS industries, national"
compress
save "../output/merged_bea_bls_panel.dta", replace

* --- 7. Verification ---
display _n "=== Verification ==="
display "Total observations: " _N
display "Matched observations: `n_matched'"

* At least some matches should exist
assert `n_matched' > 0

display _n "Merge complete."
log close
