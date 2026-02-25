* ============================================================
* Build NIPA Industry-Year Panel
* Project: Capital and Labor Shares in Healthcare
* Purpose: Clean BEA GDP-by-Industry data and NIPA supplements
*          into a consistent industry-year panel of VA components
* Inputs:  inputs/bea_gdp_industry/bea_va_components_raw.dta
*          inputs/bea_gdp_industry/bea_chain_indexes_raw.dta
*          inputs/bea_nipa_supplements/proprietors_income_by_industry_raw.dta
*          inputs/bea_nipa_supplements/cfc_by_industry_raw.dta
* Outputs: outputs/nipa_industry_year_panel.dta
*          outputs/naics_concordance.dta
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "outputs/build_nipa_shares.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Define target industries ---
* We create a concordance of NAICS codes we want to track
clear
input str10 naics_code str40 industry_group str60 industry_label
"62"    "healthcare_total"   "Health care and social assistance"
"621"   "ambulatory"         "Ambulatory health care services"
"622"   "hospitals"          "Hospitals"
"623"   "nursing"            "Nursing and residential care"
"31-33" "manufacturing"      "Manufacturing"
"52"    "finance"            "Finance and insurance"
"44-45" "retail"             "Retail trade"
"54"    "professional"       "Professional, scientific, and technical"
"61"    "education"          "Educational services"
"51"    "information"        "Information"
"23"    "construction"       "Construction"
""      "total_economy"      "All industries"
end

label variable naics_code "NAICS industry code"
label variable industry_group "Industry group label"
label variable industry_label "Full industry description"
compress
save "outputs/naics_concordance.dta", replace
local n_industries = _N
display "Target industries: `n_industries'"

* --- 2. Load and clean VA components ---
display _n "Loading VA components..."
use "inputs/bea_gdp_industry/bea_va_components_raw.dta", clear

describe, short
display "Raw observations: " _N

* The BEA GDP-by-Industry data has different tables for different VA components.
* We need to identify which table/line corresponds to:
*   - Value added
*   - Compensation of employees (CE)
*   - Gross operating surplus (GOS)
*   - Taxes on production less subsidies (TPLS)
*
* Strategy: The data should have industry_id and a variable identifying the
* component type (table_id or similar). We reshape from long to wide.

* Examine structure
tab source_table_id if !missing(source_table_id), missing
tab table_id if !missing(table_id), missing

* List unique industry IDs to understand BEA's coding
display _n "Sample industry IDs:"
quietly levelsof industry_id, local(inds)
foreach i in `inds' {
    quietly count if industry_id == "`i'"
    if r(N) > 0 {
        quietly levelsof industry_desc if industry_id == "`i'", local(d) clean
        display "  `i': `d'"
    }
}

* --- 3. Identify VA component types ---
* BEA GDP-by-Industry Table 1 = Value Added
* BEA GDP-by-Industry Table 5 = Components of Value Added
*   (or similar -- exact numbering depends on API version)
*
* Within Table 5, components are identified by a line number or
* similar identifier. We need to parse the data to identify:
*   - Compensation of employees
*   - Gross operating surplus
*   - Taxes on production less subsidies

* Check for component identification
capture tab table_id, missing

* Create a component type variable based on available identifiers
* This may need adjustment based on actual API response format
gen str component = ""

* Try to identify from description or table structure
* (BEA data typically has line descriptions or IndustrYClassID)
capture {
    * If the data has different source_table_ids for different components:
    * Table 1 = VA levels, Table 5 = VA components, Table 6 = VA component shares
    replace component = "va_level" if source_table_id == "1"
    replace component = "va_components" if source_table_id == "5"
    replace component = "va_shares" if source_table_id == "6"
}

* --- 4. Reshape to industry-year panel ---
* The exact reshape depends on BEA's data structure.
* Key goal: one row per industry-year with columns for VA, CE, GOS, TPLS

* For now, keep the data in a flexible long format that downstream tasks
* can work with. The critical step is consistent industry coding.

* Map BEA industry codes to our target NAICS codes
gen str10 naics_code = ""
replace naics_code = "62"    if strpos(lower(industry_desc), "health care") > 0 & strlen(industry_id) <= 3
replace naics_code = "621"   if strpos(lower(industry_desc), "ambulatory") > 0
replace naics_code = "622"   if strpos(lower(industry_desc), "hospital") > 0
replace naics_code = "623"   if strpos(lower(industry_desc), "nursing") > 0
replace naics_code = "31-33" if strpos(lower(industry_desc), "manufacturing") > 0 & strlen(industry_id) <= 5
replace naics_code = "52"    if strpos(lower(industry_desc), "finance and insurance") > 0
replace naics_code = "44-45" if strpos(lower(industry_desc), "retail") > 0
replace naics_code = "54"    if strpos(lower(industry_desc), "professional") > 0 & strpos(lower(industry_desc), "scientific") > 0
replace naics_code = "61"    if strpos(lower(industry_desc), "educational") > 0
replace naics_code = "51"    if strpos(lower(industry_desc), "information") > 0 & strlen(industry_id) <= 3
replace naics_code = "23"    if strpos(lower(industry_desc), "construction") > 0 & strlen(industry_id) <= 3

* Total economy (GDP = all industries)
replace naics_code = "total" if strpos(lower(industry_desc), "all industries") > 0 ///
    | strpos(lower(industry_desc), "gross domestic product") > 0

* Keep only target industries
keep if naics_code != ""

display _n "After filtering to target industries:"
tab naics_code, missing

* --- 5. Merge with NAICS concordance ---
merge m:1 naics_code using "outputs/naics_concordance.dta", keep(master match)
tab _merge
drop _merge

* --- 6. Attempt to merge supplementary NIPA data ---
* Proprietors' income
capture confirm file "inputs/bea_nipa_supplements/proprietors_income_by_industry_raw.dta"
if _rc == 0 {
    display _n "Proprietors' income data available for merge."
    * The merge will happen in compute_factor_shares since the NIPA
    * supplementary tables use different industry classifications.
    * Flag availability here.
    gen byte has_prop_income_data = 1
}
else {
    display "Proprietors' income data not yet available."
    gen byte has_prop_income_data = 0
}

* CFC data
capture confirm file "inputs/bea_nipa_supplements/cfc_by_industry_raw.dta"
if _rc == 0 {
    display "CFC data available for merge."
    gen byte has_cfc_data = 1
}
else {
    display "CFC data not yet available."
    gen byte has_cfc_data = 0
}

* --- 7. Validate accounting identity ---
* If we have VA, CE, GOS, TPLS as separate variables, check:
* VA = CE + GOS + TPLS (within rounding)
* This check depends on the actual data structure after reshape.
* For now, document what variables we have.

display _n "=== Variables in final dataset ==="
describe, short
display _n "=== Year range ==="
summarize year

* --- 8. Save ---
label data "BEA GDP-by-Industry panel, target NAICS industries"
compress
save "outputs/nipa_industry_year_panel.dta", replace

* --- 9. Verification ---
display _n "=== Verification ==="
display "Observations: " _N

* Check all target industries present
levelsof naics_code, local(present)
display "Industries present: `present'"

* Check year range
summarize year
assert r(min) <= 2000
assert r(max) >= 2020

* Check healthcare specifically
count if naics_code == "62"
assert r(N) > 0
display "Healthcare total (NAICS 62) observations: " r(N)

display _n "Build complete."
log close
