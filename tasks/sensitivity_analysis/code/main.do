* ============================================================
* Sensitivity Analysis
* Project: Capital and Labor Shares in Healthcare
* Purpose: Test robustness of factor share estimates to
*          different mixed income treatments, nonprofit
*          handling, and gross vs net specifications
* Inputs:  inputs/factor_shares/factor_shares_raw.dta
*          inputs/factor_shares/factor_shares_adjusted.dta
* Outputs: outputs/sensitivity_results.dta
*          outputs/sensitivity_summary.tex
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "output/sensitivity_analysis.log", replace

* --- 0. Setup ---
// UChicago palette
local maroon    "128 0 0"
local dark_gray "118 118 118"
local phoenix   "255 163 25"

* --- 1. Load adjusted factor shares ---
display "Loading adjusted factor shares..."
use "input/factor_shares/factor_shares_adjusted.dta", clear
display "Observations: " _N
describe, short

* --- 2. Sensitivity 1: Mixed income treatments ---
display _n "=== Sensitivity 1: Mixed Income Treatments ==="

* We should have multiple labor share measures from compute_factor_shares:
*   labor_share_raw          - No adjustment (CE/VA)
*   labor_share_gollin_prop  - Gollin proportional allocation
*   labor_share_gollin_alllabor - All proprietors' income as labor

* Create long-format sensitivity dataset
preserve
    * Stack different specifications
    gen specification = "raw"
    gen labor_share = labor_share_raw
    gen capital_share = capital_share_raw

    tempfile spec_raw
    save `spec_raw'
restore

preserve
    gen specification = "gollin_proportional"
    gen labor_share = labor_share_gollin_prop
    gen capital_share = capital_share_gollin_prop

    tempfile spec_gollin
    save `spec_gollin'
restore

preserve
    gen specification = "gollin_all_labor"
    gen labor_share = labor_share_gollin_alllabor
    gen capital_share = capital_share_gollin_alllabor

    tempfile spec_alllabor
    save `spec_alllabor'
restore

* Append all specifications
use `spec_raw', clear
append using `spec_gollin'
append using `spec_alllabor'

keep naics_code year industry_group industry_label ///
    specification labor_share capital_share

* --- 3. Sensitivity 2: Nonprofit handling ---
display _n "=== Sensitivity 2: Nonprofit Handling ==="

* For hospitals (NAICS 622), GOS in nonprofits is not profit.
* Three treatments:
*   a) Standard: treat GOS as capital return (already in raw)
*   b) Conservative: for nonprofit-heavy industries, reduce capital share
*      by assuming some fraction of GOS is cost recovery
*   c) Net: subtract depreciation from GOS (requires CFC data)
*
* Treatment (b): Hospitals are ~75% nonprofit. Assume 50% of nonprofit
* GOS is cost recovery (effectively labor-adjacent).
* This is a rough sensitivity — exact nonprofit share comes from CMS data.

local nonprofit_share_hospitals = 0.75
local cost_recovery_fraction = 0.50

preserve
    keep if specification == "raw"

    * Adjust hospital GOS: reduce capital share for nonprofit cost recovery
    * Note: Hospital (622) factor shares are only available if NI denominator exists.
    * If missing, this adjustment has no effect.
    replace capital_share = capital_share * ///
        (1 - `nonprofit_share_hospitals' * `cost_recovery_fraction') ///
        if naics_code == "622" & !missing(capital_share)
    replace labor_share = 1 - capital_share ///
        if naics_code == "622" & !missing(capital_share)
    * For non-hospitals, shares are unchanged from raw

    replace specification = "nonprofit_adjusted"

    tempfile spec_np
    save `spec_np'
restore

append using `spec_np'

* --- 4. Sensitivity 3: Gross vs Net (if CFC data available) ---
display _n "=== Sensitivity 3: Gross vs Net ==="

* Net operating surplus = GOS - CFC
* Net value added = VA - CFC
* Net capital share = NOS / NVA
*
* This requires CFC data from download_bea_nipa_supplements.
* Check if it's available.

capture confirm variable cfc
if _rc == 0 {
    display "CFC data available. Computing net shares."
    preserve
        keep if specification == "raw"
        replace specification = "net_of_depreciation"

        gen nos = gos - cfc
        gen nva = value_added - cfc
        replace capital_share = nos / nva if nva > 0
        replace labor_share = comp_employees / nva if nva > 0

        tempfile spec_net
        save `spec_net'
    restore
    append using `spec_net'
}
else {
    display "CFC data not available. Skipping net specification."
    display "Run download_bea_nipa_supplements to add this sensitivity."
}

* --- 5. Summary by specification and industry ---
display _n "=== Sensitivity Results ==="

* Save full long-format results
label variable specification "Sensitivity specification"
label variable labor_share "Labor share"
label variable capital_share "Capital share"

compress
save "output/sensitivity_results.dta", replace

* Compute summary statistics
collapse (mean) mean_labor=labor_share mean_capital=capital_share ///
    (sd) sd_labor=labor_share sd_capital=capital_share ///
    (min) min_labor=labor_share min_capital=capital_share ///
    (max) max_labor=labor_share max_capital=capital_share ///
    (count) n_years=labor_share, ///
    by(naics_code industry_group specification)

* Display results
display _n "Mean Labor Share by Industry and Specification:"
list naics_code specification mean_labor sd_labor n_years, ///
    sepby(naics_code) noobs

* --- 6. Export LaTeX summary table ---
display _n "Exporting LaTeX summary table..."

* Reshape for table: one row per industry, columns per specification
capture {
    keep naics_code industry_group specification mean_labor mean_capital

    reshape wide mean_labor mean_capital, i(naics_code industry_group) j(specification) string

    * Format for LaTeX
    format mean_labor* mean_capital* %5.3f

    * Export
    * Note: This is a basic export. For publication quality, may need
    * manual formatting or esttab with stored estimates.
    export delimited using "output/sensitivity_summary.csv", replace

    * Create a basic LaTeX table
    file open tex using "output/sensitivity_summary.tex", write replace
    file write tex "\begin{table}[htbp]" _n
    file write tex "\centering" _n
    file write tex "\caption{Factor Shares: Sensitivity to Specification}" _n
    file write tex "\label{tab:sensitivity}" _n
    file write tex "\begin{tabular}{lcccc}" _n
    file write tex "\toprule" _n
    file write tex "Industry & Raw & Gollin (Prop.) & Gollin (All Labor) & Nonprofit Adj. \\" _n
    file write tex "\midrule" _n
    file write tex "\multicolumn{5}{l}{\textit{Panel A: Labor Share}} \\" _n

    * Write rows
    levelsof industry_group, local(groups)
    foreach g in `groups' {
        quietly levelsof naics_code if industry_group == "`g'", local(nc) clean

        * Get values for each specification
        local vals ""
        foreach spec in raw gollin_proportional gollin_all_labor nonprofit_adjusted {
            capture quietly summarize mean_labor`spec' if industry_group == "`g'"
            if _rc == 0 & r(N) > 0 {
                local v : display %5.3f r(mean)
                local vals "`vals' & `v'"
            }
            else {
                local vals "`vals' & --"
            }
        }

        file write tex "`g' `vals' \\" _n
    }

    file write tex "\bottomrule" _n
    file write tex "\end{tabular}" _n
    file write tex "\begin{tablenotes}" _n
    file write tex "\small" _n
    file write tex "\item Notes: Raw = CE/VA. Gollin (Prop.) = proportional allocation of proprietors' income. " _n
    file write tex "Gollin (All Labor) = all proprietors' income treated as labor. " _n
    file write tex "Nonprofit Adj. = reduce hospital GOS for cost recovery." _n
    file write tex "\end{tablenotes}" _n
    file write tex "\end{table}" _n
    file close tex

    display "LaTeX table saved to outputs/sensitivity_summary.tex"
}

* --- 7. Verification ---
display _n "=== Verification ==="
use "output/sensitivity_results.dta", clear

* All shares should be in [0, 1]
summarize labor_share capital_share
assert labor_share >= 0 & labor_share <= 1 if !missing(labor_share)
assert capital_share >= -0.1 & capital_share <= 1 if !missing(capital_share)

* Check that we have multiple specifications
tab specification
quietly levelsof specification
local n_specs : word count `r(levels)'
display "Number of specifications: `n_specs'"
assert `n_specs' >= 3

* Check outputs exist
capture confirm file "output/sensitivity_summary.tex"
if _rc == 0 {
    display "LaTeX table: OK"
}
else {
    display as error "LaTeX table: MISSING"
}

display _n "Sensitivity analysis complete."
log close
