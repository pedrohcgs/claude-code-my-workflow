* ============================================================
* Build Industry-Year Panel with Factor Shares
* Project: Capital and Labor Shares in Healthcare
* Purpose: Create a comprehensive industry-year panel using:
*          (1) BEA GDP-by-Industry VA components (primary)
*          (2) NIPA supplementary data (prop income, self-employment)
* Inputs:  ../input/bea_gdp_industry/bea_va_panel.dta     (VA, CE, GOS, TOPI)
*          ../input/bea_gdp_industry/nipa_prop_income.dta  (proprietors' income)
*          ../input/bea_gdp_industry/nipa_self_employed.dta
*          ../input/bea_gdp_industry/nipa_fte_employees.dta
*          ../input/bea_gdp_industry/nipa_natl_income.dta  (fallback)
*          ../input/bea_gdp_industry/nipa_comp.dta         (fallback)
* Outputs: ../output/nipa_industry_year_panel.dta
*          ../output/naics_concordance.dta
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "../output"
log using "build_nipa_shares.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Define target industries (concordance) ---
clear
input str10 naics_code str40 industry_group str60 industry_label
"23"      "construction"       "Construction"
"31-33"   "manufacturing"      "Manufacturing"
"44-45"   "retail"             "Retail trade"
"51"      "information"        "Information"
"52"      "finance"            "Finance and insurance"
"54"      "professional"       "Professional, scientific, and technical"
"61"      "education"          "Educational services"
"62"      "healthcare_total"   "Health care and social assistance"
"621"     "ambulatory"         "Ambulatory health care services"
"622"     "hospitals"          "Hospitals"
"623"     "nursing"            "Nursing and residential care"
"61-62"   "educ_health"        "Educational services, health care, and social assistance"
"private" "private_industries" "Private industries"
"total"   "total_economy"      "Domestic industries"
end

label variable naics_code "NAICS industry code"
label variable industry_group "Industry group label"
label variable industry_label "Full industry description"
compress
save "../output/naics_concordance.dta", replace
display "Target industries: " _N

* --- 2. Check for BEA VA panel (primary data source) ---
capture confirm file "../input/bea_gdp_industry/bea_va_panel.dta"
local has_api_data = (_rc == 0)

if `has_api_data' {
    display _n "=== Using BEA GDP-by-Industry VA data (primary) ==="

    * --- 3A. Load VA panel ---
    use "../input/bea_gdp_industry/bea_va_panel.dta", clear
    display "BEA VA panel: " _N " observations"
    tab naics_code, missing

    * Keep core variables
    keep naics_code year industry_group industry_label ///
        value_added comp_employees gos topi ///
        labor_share_va capital_share_va topi_share_va

    * Rename for downstream compatibility
    * labor_share_va is the proper CE/VA measure
    rename labor_share_va labor_share_raw
    rename capital_share_va capital_share_raw
    label variable labor_share_raw "Labor share, raw (CE/VA)"
    label variable capital_share_raw "Capital share, raw (GOS/VA)"

    tempfile panel
    save `panel'

    * --- 4A. Merge NIPA supplementary data ---
    * Proprietors' income (for Gollin adjustments)
    display _n "Merging NIPA proprietors' income..."
    capture {
        use "../input/bea_gdp_industry/nipa_prop_income.dta", clear
        keep naics_code year prop_income
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        tab _merge
        drop _merge
        save `panel', replace
    }
    if _rc != 0 {
        display "  Proprietors' income not available."
        use `panel', clear
        gen prop_income = .
        save `panel', replace
    }

    * Self-employed counts
    display _n "Merging NIPA self-employed..."
    capture {
        use "../input/bea_gdp_industry/nipa_self_employed.dta", clear
        keep naics_code year n_self_employed
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        tab _merge
        drop _merge
        save `panel', replace
    }
    if _rc != 0 {
        display "  Self-employed data not available."
        use `panel', clear
        gen n_self_employed = .
        save `panel', replace
    }

    * FTE employees
    display _n "Merging NIPA FTE employees..."
    capture {
        use "../input/bea_gdp_industry/nipa_fte_employees.dta", clear
        keep naics_code year fte_employees
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        tab _merge
        drop _merge
        save `panel', replace
    }
    if _rc != 0 {
        display "  FTE employees data not available."
        use `panel', clear
        gen fte_employees = .
        save `panel', replace
    }

    * National income (for reference / comparison)
    display _n "Merging NIPA national income..."
    capture {
        use "../input/bea_gdp_industry/nipa_natl_income.dta", clear
        keep naics_code year natl_income
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        tab _merge
        drop _merge
        save `panel', replace
    }
    if _rc != 0 {
        display "  National income data not available."
        use `panel', clear
        gen natl_income = .
        save `panel', replace
    }

    use `panel', clear
}
else {
    * --- FALLBACK: Use NIPA data only (limited) ---
    display _n "=== BEA VA panel not available. Using NIPA fallback ==="
    display "WARNING: Factor shares limited to industries with national income data."

    * Load compensation
    use "../input/bea_gdp_industry/nipa_comp.dta", clear
    keep naics_code year comp_employees
    isid naics_code year
    tempfile panel
    save `panel'

    * Merge national income
    use "../input/bea_gdp_industry/nipa_natl_income.dta", clear
    keep naics_code year natl_income
    isid naics_code year
    merge 1:1 naics_code year using `panel'
    drop _merge
    save `panel', replace

    * Merge prop income
    capture {
        use "../input/bea_gdp_industry/nipa_prop_income.dta", clear
        keep naics_code year prop_income
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        drop _merge
        save `panel', replace
    }

    * Merge self-employed
    capture {
        use "../input/bea_gdp_industry/nipa_self_employed.dta", clear
        keep naics_code year n_self_employed
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        drop _merge
        save `panel', replace
    }

    * Merge FTE employees
    capture {
        use "../input/bea_gdp_industry/nipa_fte_employees.dta", clear
        keep naics_code year fte_employees
        isid naics_code year
        merge 1:1 naics_code year using `panel'
        drop _merge
        save `panel', replace
    }

    use `panel', clear

    * Merge concordance
    merge m:1 naics_code using "../output/naics_concordance.dta", keep(master match)
    drop _merge

    * Compute NIPA-based shares
    gen labor_share_raw = comp_employees / natl_income if natl_income > 0
    gen capital_share_raw = .
    gen value_added = .
    gen gos = .
    gen topi = .
    gen topi_share_va = .
    label variable labor_share_raw "Labor share, raw (CE/NI, NIPA fallback)"
}

* --- 5. Compute derived measures ---
display _n "Computing derived measures..."

* Average compensation per FTE employee (thousands)
capture gen comp_per_fte = comp_employees / fte_employees if fte_employees > 0
label variable comp_per_fte "Comp. per FTE employee (thousands of $)"

* Proprietors' income share of VA (if available)
capture gen prop_share_va = prop_income / value_added if value_added > 0
capture label variable prop_share_va "Proprietors' income / VA"

* For backward compatibility: also compute CE/NI if NI available
capture gen labor_share_ni = comp_employees / natl_income if natl_income > 0
capture label variable labor_share_ni "Labor share (CE / national income, reference)"

capture gen prop_share_ni = prop_income / natl_income if natl_income > 0
capture label variable prop_share_ni "Proprietors' income / national income"

capture gen capital_share_ni = 1 - labor_share_ni - prop_share_ni ///
    if !missing(labor_share_ni) & !missing(prop_share_ni)
capture label variable capital_share_ni "Residual capital share (NI-based)"

* --- 6. Validate ---
display _n "=== Validation ==="

* Check year range
summarize year
local min_year = r(min)
local max_year = r(max)
display "Year range: `min_year' to `max_year'"

* Check healthcare data
count if naics_code == "62"
local n_hc = r(N)
display "Healthcare (62) observations: `n_hc'"
assert `n_hc' > 0

* Check labor share is plausible
display _n "Healthcare labor share (CE/VA):"
summarize labor_share_raw if naics_code == "62"
if r(N) > 0 {
    display "  Mean: " %5.3f r(mean) "  Min: " %5.3f r(min) "  Max: " %5.3f r(max)
}

* Display recent data
display _n "Healthcare (NAICS 62) recent data:"
list naics_code year comp_employees value_added labor_share_raw ///
    if naics_code == "62" & year >= 2018, noobs

* All industry averages
display _n "Average labor share by industry (CE/VA):"
tabstat labor_share_raw, by(industry_group) stat(mean sd N) format(%5.3f)

* --- 7. Save ---
order naics_code year industry_group industry_label ///
    value_added comp_employees gos topi ///
    labor_share_raw capital_share_raw topi_share_va ///
    prop_income prop_share_va ///
    natl_income labor_share_ni prop_share_ni capital_share_ni ///
    fte_employees n_self_employed comp_per_fte

label data "NIPA industry-year panel, target NAICS industries"
compress
save "../output/nipa_industry_year_panel.dta", replace

display _n "Panel built: " _N " observations"

if `has_api_data' {
    display "Data source: BEA GDP-by-Industry API (CE/VA labor shares)"
    count if !missing(labor_share_raw)
    display "Industries with factor shares: " r(N) " obs"
}
else {
    display "Data source: NIPA bulk tables (CE/NI fallback)"
    display "WARNING: Limited factor share coverage without API data."
}

log close
