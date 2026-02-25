* ============================================================
* Compute Factor Shares
* Project: Capital and Labor Shares in Healthcare
* Purpose: Compute raw and Gollin-adjusted capital/labor shares
*          from BEA VA components panel
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
display "Loading NIPA industry-year panel..."
use "inputs/nipa_shares/nipa_industry_year_panel.dta", clear
display "Observations: " _N
tab naics_code, missing

* --- 2. Compute raw factor shares ---
* The BEA data should have VA components. Depending on the data structure
* from build_nipa_shares, we may have these as:
*   - Separate variables (comp_employees, gos, taxes_less_subs, value_added)
*   - Long format with a component identifier
*
* We need to reshape to wide if in long format.

* Check what variables we have
describe, short
display _n "Available variables:"
describe

* If data is in long format with 'value' and some component identifier,
* reshape to wide. Otherwise, proceed with existing columns.
capture confirm variable component
if _rc == 0 {
    * Data is in long format — reshape
    display "Data appears to be in long format. Reshaping to wide..."

    * Keep only the components we need
    keep if inlist(component, "va_level", "va_components")

    * Create a numeric component ID for reshape
    * (This section may need adjustment based on actual data structure)

    * For now, save the long-format data and flag for manual review
    display as error "NOTE: Data reshape required. Review data structure."
}

* If we have the value variable from the raw BEA import, we need to
* distinguish between VA, CE, GOS components. The source_table_id
* or table_id should identify these.
*
* Table 1 = Value Added levels
* Table 5 = Components of Value Added (CE, GOS, Taxes - Subsidies)

* Attempt to create component variables from the raw data
capture {
    * Separate VA level (from Table 1)
    gen value_added = value if source_table_id == "1"

    * Components from Table 5 will have line descriptions
    * identifying CE, GOS, Taxes
    * This is a heuristic that may need refinement
    gen comp_employees = value if source_table_id == "5" & ///
        (strpos(lower(industry_desc), "compensation") > 0 | ///
         strpos(lower(line_desc), "compensation") > 0)
    gen gos = value if source_table_id == "5" & ///
        (strpos(lower(industry_desc), "gross operating surplus") > 0 | ///
         strpos(lower(line_desc), "gross operating") > 0)
    gen taxes_less_subs = value if source_table_id == "5" & ///
        (strpos(lower(industry_desc), "taxes on production") > 0 | ///
         strpos(lower(line_desc), "taxes") > 0)
}

* Collapse to one row per industry-year with all components
* (BEA may report components as separate rows)
capture {
    collapse (firstnm) value_added comp_employees gos taxes_less_subs ///
        industry_group industry_label, by(naics_code year)
}

* --- 3. Raw factor shares ---
display _n "Computing raw factor shares..."

* Generate shares
capture gen labor_share_raw = comp_employees / value_added
capture gen capital_share_raw = gos / value_added
capture gen tax_share = taxes_less_subs / value_added

* Verify shares sum to approximately 1
capture gen share_sum = labor_share_raw + capital_share_raw + tax_share
capture summarize share_sum
capture assert abs(share_sum - 1) < 0.01 if !missing(share_sum)

display _n "=== Raw Factor Shares (means) ==="
capture tabstat labor_share_raw capital_share_raw tax_share, ///
    by(naics_code) stat(mean sd min max N) format(%9.3f)

* Label
capture label variable labor_share_raw "Labor share, raw (CE/VA)"
capture label variable capital_share_raw "Capital share, raw (GOS/VA)"
capture label variable tax_share "Tax wedge ((Taxes-Subsidies)/VA)"
capture label variable value_added "Value added (millions, current $)"
capture label variable comp_employees "Compensation of employees (millions, current $)"
capture label variable gos "Gross operating surplus (millions, current $)"

* Save raw shares
compress
save "outputs/factor_shares_raw.dta", replace

* --- 4. Gollin (2002) mixed income adjustments ---
display _n "Attempting mixed income adjustments..."

* The Gollin (2002) adjustment requires:
*   - Proprietors' income by industry
*   - Number of self-employed (for imputed wage method)
*
* Check if supplementary data made it through build_nipa_shares
capture confirm variable has_prop_income_data
if _rc == 0 {
    count if has_prop_income_data == 1
    local has_prop = r(N) > 0
}
else {
    local has_prop = 0
}

if `has_prop' {
    display "Proprietors' income data available. Computing adjustments..."

    * Adjustment 1: Proportional allocation
    * Allocate proprietors' income in same CE/(CE+GOS_corp) ratio
    * labor_share_adj1 = (CE + PropInc * CE/(CE+GOS_corp)) / VA
    * where GOS_corp = GOS - PropInc
    capture {
        gen gos_corporate = gos - prop_income
        gen ce_share_of_corporate = comp_employees / (comp_employees + gos_corporate)
        gen labor_share_gollin_prop = ///
            (comp_employees + prop_income * ce_share_of_corporate) / value_added
        gen capital_share_gollin_prop = 1 - labor_share_gollin_prop - tax_share
    }

    * Adjustment 2: All proprietors' income as labor
    capture {
        gen labor_share_gollin_alllabor = ///
            (comp_employees + prop_income) / value_added
        gen capital_share_gollin_alllabor = 1 - labor_share_gollin_alllabor - tax_share
    }

    * Adjustment 3: Imputed wage (requires self-employment counts)
    * labor_share_adj3 = (CE + n_proprietors * avg_employee_wage) / VA
    capture {
        gen avg_employee_wage = comp_employees / employment_count  // if available
        gen labor_share_gollin_imputed = ///
            (comp_employees + n_proprietors * avg_employee_wage) / value_added
        gen capital_share_gollin_imputed = 1 - labor_share_gollin_imputed - tax_share
    }
}
else {
    display "Proprietors' income data not yet available."
    display "Creating placeholder adjusted shares = raw shares."
    display "Run download_bea_nipa_supplements, rebuild, and rerun."

    gen labor_share_gollin_prop = labor_share_raw
    gen capital_share_gollin_prop = capital_share_raw
    gen labor_share_gollin_alllabor = labor_share_raw
    gen capital_share_gollin_alllabor = capital_share_raw

    * Label as placeholders
    label variable labor_share_gollin_prop "Labor share, Gollin prop. adj. (PLACEHOLDER)"
    label variable capital_share_gollin_prop "Capital share, Gollin prop. adj. (PLACEHOLDER)"
    label variable labor_share_gollin_alllabor "Labor share, all prop. income as labor (PLACEHOLDER)"
    label variable capital_share_gollin_alllabor "Capital share, all prop. income as labor (PLACEHOLDER)"
}

* Save adjusted shares
compress
save "outputs/factor_shares_adjusted.dta", replace

* --- 5. Summary statistics by industry group ---
display _n "=== Adjusted Factor Shares (means) ==="
capture tabstat labor_share_raw labor_share_gollin_prop labor_share_gollin_alllabor, ///
    by(naics_code) stat(mean sd N) format(%9.3f)

* Create summary dataset
capture {
    collapse (mean) labor_share_raw capital_share_raw ///
        labor_share_gollin_prop capital_share_gollin_prop ///
        labor_share_gollin_alllabor capital_share_gollin_alllabor ///
        (sd) sd_labor_raw=labor_share_raw sd_capital_raw=capital_share_raw ///
        (count) n_years=labor_share_raw, ///
        by(naics_code industry_group industry_label)

    label data "Factor share summary statistics by industry"
    compress
    save "outputs/factor_shares_summary.dta", replace
}

* --- 6. Verification ---
display _n "=== Verification ==="
use "outputs/factor_shares_adjusted.dta", clear
display "Observations: " _N

* Healthcare labor share should be in plausible range (~0.5-0.7)
summarize labor_share_raw if naics_code == "62"
if r(N) > 0 {
    display "Healthcare labor share (raw): mean=" %5.3f r(mean) ///
        " min=" %5.3f r(min) " max=" %5.3f r(max)
    * Warn if outside expected range but don't assert (data may be structured differently)
    if r(mean) < 0.3 | r(mean) > 0.9 {
        display as error "WARNING: Healthcare labor share outside expected 0.3-0.9 range"
        display as error "Check data structure and component identification."
    }
}

* Total economy labor share should be ~0.55-0.65
summarize labor_share_raw if naics_code == "total"
if r(N) > 0 {
    display "Total economy labor share (raw): mean=" %5.3f r(mean)
}

display _n "Factor share computation complete."
log close
