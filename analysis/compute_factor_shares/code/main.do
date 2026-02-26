* ============================================================
* Compute Factor Shares
* Project: Capital and Labor Shares in Healthcare
* Purpose: Compute raw and Gollin-adjusted capital/labor shares
*          from industry-year panel
* Inputs:  inputs/nipa_shares/nipa_industry_year_panel.dta
* Outputs: outputs/factor_shares_raw.dta
*          outputs/factor_shares_adjusted.dta
*          outputs/factor_shares_summary.dta
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "outputs/compute_factor_shares.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Load clean panel ---
display "Loading industry-year panel..."
use "inputs/nipa_shares/nipa_industry_year_panel.dta", clear
display "Observations: " _N
tab naics_code, missing

describe, short

* --- 2. Raw factor shares ---
* The panel already has labor_share_raw (CE/VA) from build_nipa_shares.
* If built from API data: labor_share_raw = CE / Value Added (preferred)
* If built from NIPA fallback: labor_share_raw = CE / National Income

display _n "=== Raw Factor Shares ==="

* Check which denominator was used
capture confirm variable value_added
local has_va = (_rc == 0)

if `has_va' {
    quietly count if !missing(value_added) & value_added > 0
    if r(N) > 0 {
        display "Denominator: Value Added (GDP-by-Industry)"
    }
    else {
        display "Denominator: National Income (NIPA fallback)"
    }
}
else {
    display "Denominator: National Income (NIPA fallback)"
}

label variable labor_share_raw "Labor share, raw (CE/VA)"
label variable capital_share_raw "Capital share, raw (GOS/VA)"

* Display shares by industry
display _n "Raw labor shares by industry:"
tabstat labor_share_raw, by(industry_group) stat(mean sd min max N) format(%5.3f)

* Save raw shares
compress
save "outputs/factor_shares_raw.dta", replace

* --- 3. Gollin (2002) mixed income adjustments ---
display _n "=== Gollin (2002) Adjustments ==="

* The Gollin adjustments address the treatment of proprietors' (mixed) income.
* In healthcare, this is significant for ambulatory care (physician practices).
*
* We use VA as the denominator when available, otherwise NI.
* VA = CE + GOS + TOPI
* NI ≈ VA - CFC (consumption of fixed capital)
*
* For Gollin, we need:
*   Corporate capital income = VA - CE - PropInc - TOPI (if VA available)
*   or = NI - CE - PropInc (if only NI available)

* Determine best denominator for each observation
gen denom = value_added if `has_va' & !missing(value_added) & value_added > 0
capture replace denom = natl_income if missing(denom) & !missing(natl_income) & natl_income > 0
label variable denom "Denominator (VA or NI)"

* Taxes share to exclude from capital income calculation when using VA
gen topi_adj = topi if `has_va' & !missing(topi)
replace topi_adj = 0 if missing(topi_adj)

* Method 1: Proportional allocation
* Allocate proprietors' income in same CE/(CE+CapitalIncome) ratio
* CapitalIncome = denom - CE - PropInc - TOPI
* Corporate labor share = CE / (CE + CapitalIncome) = CE / (denom - PropInc - TOPI)
* Adjusted CE = CE + PropInc * CE/(denom - PropInc - TOPI)
* Adjusted labor share = Adjusted CE / denom

gen labor_share_gollin_prop = .
replace labor_share_gollin_prop = ///
    (comp_employees + prop_income * (comp_employees / (denom - prop_income - topi_adj))) / denom ///
    if !missing(comp_employees) & !missing(prop_income) & !missing(denom) ///
    & (denom - prop_income - topi_adj) > 0
label variable labor_share_gollin_prop "Labor share, Gollin proportional adj."

* Method 2: All proprietors' income as labor
gen labor_share_gollin_alllabor = .
replace labor_share_gollin_alllabor = ///
    (comp_employees + prop_income) / denom ///
    if !missing(comp_employees) & !missing(prop_income) & !missing(denom) ///
    & denom > 0
label variable labor_share_gollin_alllabor "Labor share, all prop. income as labor"

* Method 3: Imputed wage (proprietors earn avg employee wage)
gen labor_share_gollin_imputed = .
replace labor_share_gollin_imputed = ///
    (comp_employees + n_self_employed * comp_per_fte) / denom ///
    if !missing(comp_employees) & !missing(n_self_employed) & !missing(comp_per_fte) ///
    & !missing(denom) & denom > 0
label variable labor_share_gollin_imputed "Labor share, imputed wage for proprietors"

* Capital shares (residual after Gollin adjustment)
* After Gollin, prop income is fully allocated between labor and capital.
* Capital share = 1 - adjusted labor share (minus tax share if using VA).
gen capital_share_gollin_prop = 1 - labor_share_gollin_prop ///
    if !missing(labor_share_gollin_prop)
gen capital_share_gollin_alllabor = 1 - labor_share_gollin_alllabor ///
    if !missing(labor_share_gollin_alllabor)

label variable capital_share_gollin_prop "Capital share, Gollin proportional"
label variable capital_share_gollin_alllabor "Capital share, after Gollin all-labor"

drop denom topi_adj

* Display adjusted shares
display _n "Adjusted labor shares by industry (Gollin proportional):"
tabstat labor_share_gollin_prop, by(industry_group) stat(mean sd N) format(%5.3f)

display _n "Adjusted labor shares by industry (all prop. income as labor):"
tabstat labor_share_gollin_alllabor, by(industry_group) stat(mean sd N) format(%5.3f)

* Save adjusted shares
compress
save "outputs/factor_shares_adjusted.dta", replace

* --- 4. Summary statistics by industry ---
display _n "=== Summary Statistics ==="

preserve
    keep if !missing(labor_share_raw)

    collapse (mean) labor_share_raw capital_share_raw ///
        labor_share_gollin_prop capital_share_gollin_prop ///
        labor_share_gollin_alllabor labor_share_gollin_imputed ///
        (sd) sd_labor_raw=labor_share_raw sd_capital_raw=capital_share_raw ///
        (count) n_years=labor_share_raw, ///
        by(naics_code industry_group industry_label)

    label data "Factor share summary statistics by industry"

    display _n "Summary table:"
    list naics_code industry_group labor_share_raw labor_share_gollin_prop ///
        labor_share_gollin_alllabor n_years, noobs

    compress
    save "outputs/factor_shares_summary.dta", replace
restore

* --- 5. Industries without data ---
display _n "=== Data Coverage ==="
count if !missing(labor_share_raw)
display "Industries with raw factor shares: " r(N) " obs"

count if !missing(labor_share_gollin_prop)
display "Industries with Gollin proportional: " r(N) " obs"

count if missing(labor_share_raw) & !missing(comp_employees)
if r(N) > 0 {
    display _n "Industries with compensation only (need VA denominator):"
    preserve
        keep if missing(labor_share_raw) & !missing(comp_employees)
        collapse (mean) comp_employees, by(naics_code industry_group)
        list naics_code industry_group comp_employees, noobs
    restore
}
else {
    display "All industries have factor shares."
}

* --- 6. Verification ---
display _n "=== Verification ==="
display "Total observations: " _N

* Shares should be in [0, 1] where available
summarize labor_share_raw capital_share_raw
count if labor_share_raw < 0 | labor_share_raw > 1 & !missing(labor_share_raw)
display "Out-of-range labor shares: " r(N)

* Gollin shares should also be reasonable
summarize labor_share_gollin_prop labor_share_gollin_alllabor

display _n "Factor share computation complete."
log close
