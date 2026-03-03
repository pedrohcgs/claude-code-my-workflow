* ============================================================
* Import BEA GDP-by-Industry Data
* Project: Capital and Labor Shares in Healthcare
* Purpose: Import BEA CSVs (produced by Python scripts) and
*          save as .dta files for downstream analysis
* Inputs:  ../output/bea_va_panel.csv         (from preprocess_bea_api.py)
*          ../output/nipa_comp.csv             (from extract_nipa_bulk.py)
*          ../output/nipa_natl_income.csv      (from extract_nipa_bulk.py)
*          ../output/nipa_prop_income.csv      (from extract_nipa_bulk.py)
*          ../output/nipa_self_employed.csv    (from extract_nipa_bulk.py)
*          ../output/nipa_fte_employees.csv    (from extract_nipa_bulk.py)
* Outputs: ../output/bea_va_panel.dta
*          ../output/nipa_comp.dta
*          ../output/nipa_natl_income.dta
*          ../output/nipa_prop_income.dta
*          ../output/nipa_self_employed.dta
*          ../output/nipa_fte_employees.dta
* ============================================================

version 18
clear all
set seed 20260225

log using "download_bea_gdp_industry.log", replace

* --- 1. Import BEA VA panel ---
display _n "=== Importing BEA GDP-by-Industry Panel ==="
import delimited using "../output/bea_va_panel.csv", clear varnames(1) ///
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
save "../output/bea_va_panel.dta", replace
display "Saved: bea_va_panel.dta (" _N " observations)"

* --- 2. Import NIPA supplementary datasets ---
display _n "=== NIPA Supplementary Data ==="

foreach dataset in nipa_comp nipa_natl_income nipa_prop_income nipa_self_employed nipa_fte_employees {
    import delimited using "../output/`dataset'.csv", clear varnames(1) stringcols(1 4 5)

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
    save "../output/`dataset'.dta", replace
    display "  `dataset': " _N " observations"
}

* --- 3. Verification ---
display _n "=== Final Verification ==="

quietly use "../output/bea_va_panel.dta", clear
quietly count if inlist(naics_code, "62", "621", "622", "623")
display "  bea_va_panel.dta: " _N " obs, " r(N) " healthcare"

foreach dataset in nipa_prop_income nipa_self_employed nipa_fte_employees {
    quietly use "../output/`dataset'.dta", clear
    quietly count if naics_code == "62"
    display "  `dataset': " _N " obs, " r(N) " healthcare"
}

display _n "Import complete."
log close
