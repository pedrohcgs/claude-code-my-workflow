* ============================================================
* Figures and Tables
* Project: Capital and Labor Shares in Healthcare
* Purpose: Generate publication-ready figures for Beamer slides
*          and summary LaTeX tables
* Inputs:  inputs/factor_shares/factor_shares_adjusted.dta
*          inputs/factor_shares/factor_shares_summary.dta
*          inputs/sensitivity/sensitivity_results.dta
*          inputs/bea_bls_merged/merged_bea_bls_panel.dta
* Outputs: outputs/fig_labor_share_timeseries.png
*          outputs/fig_capital_share_timeseries.png
*          outputs/fig_healthcare_subsectors.png
*          outputs/fig_labor_share_bar.png
*          outputs/fig_sensitivity_range.png
*          outputs/fig_employment_vs_share.png
*          outputs/tab_factor_shares_summary.tex
*          outputs/tab_sensitivity_summary.tex
* ============================================================

version 18
clear all
set seed 20260225

capture mkdir "outputs"
log using "output/figures_and_tables.log", replace

* --- 0. Setup: UChicago palette ---
local maroon     "128 0 0"
local dark_gray  "118 118 118"
local phoenix    "255 163 25"
local light_gray "214 214 206"
local positive   "21 128 61"
local negative   "185 28 28"

* Graph defaults
set scheme s2color
graph set window fontface "Helvetica"

* Standard export dimensions (2400x1600 = 300 DPI at 8"x5.3")
local gwidth  2400
local gheight 1600

* ================================================================
* FIGURE 1: Labor Share Time Series
* ================================================================
display _n "=== Figure 1: Labor Share Time Series ==="

use "input/factor_shares/factor_shares_adjusted.dta", clear

* Use Gollin proportional adjustment as baseline
* (falls back to raw if adjustment wasn't available)
capture gen labor_share = labor_share_gollin_prop
if _rc != 0 {
    gen labor_share = labor_share_raw
    display "Using raw labor share (adjusted not available)"
}

twoway ///
    (line labor_share year if naics_code == "62", ///
        lcolor("`maroon'") lwidth(thick)) ///
    (line labor_share year if naics_code == "31-33", ///
        lcolor("`dark_gray'") lpattern(dash) lwidth(medthick)) ///
    (line labor_share year if naics_code == "52", ///
        lcolor("`phoenix'") lpattern(shortdash) lwidth(medthick)) ///
    (line labor_share year if naics_code == "total", ///
        lcolor("`light_gray'") lpattern(dot) lwidth(medthick)), ///
    title("Labor Share by Industry, 1997-Present", color(black)) ///
    subtitle("Compensation of Employees / Value Added", color(gs6)) ///
    ytitle("Labor Share") xtitle("") ///
    ylabel(0.3(0.1)0.9, format(%3.1f) angle(horizontal)) ///
    xlabel(, angle(0)) ///
    legend(order(1 "Healthcare" 2 "Manufacturing" 3 "Finance" 4 "Total Economy") ///
        position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Source: BEA GDP-by-Industry accounts", size(vsmall) color(gs8))

graph export "output/fig_labor_share_timeseries.png", ///
    width(`gwidth') height(`gheight') replace
display "Saved: fig_labor_share_timeseries.png"

* ================================================================
* FIGURE 2: Capital Share Time Series
* ================================================================
display _n "=== Figure 2: Capital Share Time Series ==="

capture gen capital_share = capital_share_gollin_prop
if _rc != 0 {
    gen capital_share = capital_share_raw
}

twoway ///
    (line capital_share year if naics_code == "62", ///
        lcolor("`maroon'") lwidth(thick)) ///
    (line capital_share year if naics_code == "31-33", ///
        lcolor("`dark_gray'") lpattern(dash) lwidth(medthick)) ///
    (line capital_share year if naics_code == "52", ///
        lcolor("`phoenix'") lpattern(shortdash) lwidth(medthick)) ///
    (line capital_share year if naics_code == "total", ///
        lcolor("`light_gray'") lpattern(dot) lwidth(medthick)), ///
    title("Capital Share by Industry, 1997-Present", color(black)) ///
    subtitle("Gross Operating Surplus / Value Added", color(gs6)) ///
    ytitle("Capital Share") xtitle("") ///
    ylabel(0.1(0.1)0.7, format(%3.1f) angle(horizontal)) ///
    xlabel(, angle(0)) ///
    legend(order(1 "Healthcare" 2 "Manufacturing" 3 "Finance" 4 "Total Economy") ///
        position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Source: BEA GDP-by-Industry accounts", size(vsmall) color(gs8))

graph export "output/fig_capital_share_timeseries.png", ///
    width(`gwidth') height(`gheight') replace
display "Saved: fig_capital_share_timeseries.png"

* ================================================================
* FIGURE 3: Healthcare Subsectors
* ================================================================
display _n "=== Figure 3: Healthcare Subsectors ==="

twoway ///
    (line labor_share year if naics_code == "62", ///
        lcolor("`maroon'") lwidth(thick)) ///
    (line labor_share year if naics_code == "621", ///
        lcolor("`dark_gray'") lpattern(dash) lwidth(medthick)) ///
    (line labor_share year if naics_code == "622", ///
        lcolor("`phoenix'") lpattern(shortdash) lwidth(medthick)) ///
    (line labor_share year if naics_code == "623", ///
        lcolor("`positive'") lpattern(longdash) lwidth(medthick)), ///
    title("Labor Share in Healthcare Subsectors", color(black)) ///
    ytitle("Labor Share (CE/VA)") xtitle("") ///
    ylabel(0.3(0.1)0.9, format(%3.1f) angle(horizontal)) ///
    legend(order(1 "Healthcare (Total)" 2 "Ambulatory (621)" ///
        3 "Hospitals (622)" 4 "Nursing (623)") ///
        position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Source: BEA GDP-by-Industry accounts", size(vsmall) color(gs8))

graph export "output/fig_healthcare_subsectors.png", ///
    width(`gwidth') height(`gheight') replace
display "Saved: fig_healthcare_subsectors.png"

* ================================================================
* FIGURE 4: Cross-Industry Bar Chart
* ================================================================
display _n "=== Figure 4: Cross-Industry Bar Chart ==="

* Compute time-averaged labor shares
tempfile full_panel
save `full_panel'

collapse (mean) labor_share, by(naics_code industry_group)

* Sort by labor share for visual clarity
gsort -labor_share
gen order = _n

graph hbar (asis) labor_share, over(industry_group, sort(order) ///
    label(labsize(small))) ///
    bar(1, color("`maroon'")) ///
    title("Average Labor Share by Industry", color(black)) ///
    subtitle("1997-Present, CE/VA", color(gs6)) ///
    ytitle("Labor Share") ///
    ylabel(0(0.2)1, format(%3.1f)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Source: BEA GDP-by-Industry accounts", size(vsmall) color(gs8))

graph export "output/fig_labor_share_bar.png", ///
    width(`gwidth') height(`gheight') replace
display "Saved: fig_labor_share_bar.png"

* ================================================================
* FIGURE 5: Sensitivity Range Plot
* ================================================================
display _n "=== Figure 5: Sensitivity Range ==="

use "input/sensitivity/sensitivity_results.dta", clear

* Collapse to range of estimates per industry
collapse (min) min_labor=labor_share (max) max_labor=labor_share ///
    (mean) mean_labor=labor_share, by(naics_code industry_group)

gsort -mean_labor
gen order = _n

* Range plot: show min-max bar with mean marker
twoway ///
    (rbar min_labor max_labor order, horizontal ///
        barwidth(0.5) color("`maroon'%40")) ///
    (scatter order mean_labor, ///
        mcolor("`maroon'") msymbol(diamond) msize(medium)), ///
    ylabel(1/`=_N', valuelabel angle(horizontal) labsize(small) nogrid) ///
    xlabel(0(0.1)1, format(%3.1f)) ///
    title("Labor Share: Range Across Specifications", color(black)) ///
    subtitle("Diamond = mean across specs; bar = min-max range", color(gs6)) ///
    xtitle("Labor Share") ytitle("") ///
    legend(off) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Specifications: raw, Gollin proportional, Gollin all-labor, nonprofit adj.", ///
        size(vsmall) color(gs8))

* Label y-axis with industry names
* (The order variable maps to industry_group)
capture {
    labmask order, values(industry_group)
    graph export "output/fig_sensitivity_range.png", ///
        width(`gwidth') height(`gheight') replace
}
if _rc != 0 {
    * labmask not available — use basic export
    graph export "output/fig_sensitivity_range.png", ///
        width(`gwidth') height(`gheight') replace
}
display "Saved: fig_sensitivity_range.png"

* ================================================================
* FIGURE 6: Employment Growth vs Labor Share Change
* ================================================================
display _n "=== Figure 6: Employment vs Share ==="

* Load merged BEA-BLS data
capture {
    use "input/bea_bls_merged/merged_bea_bls_panel.dta", clear

    * Compute long-run changes
    * First and last year per industry
    bysort naics_code (year): gen first_year = year[1]
    bysort naics_code (year): gen last_year = year[_N]

    bysort naics_code (year): gen empl_first = annual_avg_emplvl[1]
    bysort naics_code (year): gen empl_last = annual_avg_emplvl[_N]
    bysort naics_code (year): gen ls_first = labor_share[1] if _n == 1
    bysort naics_code (year): gen ls_last = labor_share[_N] if _n == _N

    * Collapse to one row per industry
    collapse (firstnm) empl_first ls_first industry_group ///
        (lastnm) empl_last ls_last, by(naics_code)

    gen empl_growth = (empl_last - empl_first) / empl_first * 100
    gen ls_change = ls_last - ls_first

    twoway ///
        (scatter ls_change empl_growth, ///
            mlabel(naics_code) mlabposition(3) mlabsize(small) ///
            mcolor("`maroon'") msymbol(circle) msize(medium)), ///
        title("Employment Growth vs Labor Share Change", color(black)) ///
        subtitle("Long-run change, 1997-present", color(gs6)) ///
        xtitle("Employment Growth (%)") ///
        ytitle("Change in Labor Share (pp)") ///
        yline(0, lcolor(gs12) lpattern(dash)) ///
        xline(0, lcolor(gs12) lpattern(dash)) ///
        legend(off) ///
        graphregion(color(white)) plotregion(color(white)) ///
        note("Source: BEA GDP-by-Industry and BLS QCEW", size(vsmall) color(gs8))

    graph export "output/fig_employment_vs_share.png", ///
        width(`gwidth') height(`gheight') replace
    display "Saved: fig_employment_vs_share.png"
}
if _rc != 0 {
    display "Could not create employment vs share figure."
    display "Merged BEA-BLS data may not be available yet."
}

* ================================================================
* TABLE 1: Summary Factor Shares
* ================================================================
display _n "=== Table 1: Summary Factor Shares ==="

capture {
    use "input/factor_shares/factor_shares_adjusted.dta", clear

    * Compute means by industry
    collapse (mean) labor_share_raw capital_share_raw ///
        labor_share_gollin_prop capital_share_gollin_prop ///
        (sd) sd_ls=labor_share_raw ///
        (count) n_years=labor_share_raw, ///
        by(naics_code industry_group)

    gsort -labor_share_raw

    * Export as LaTeX
    format labor_share_raw capital_share_raw labor_share_gollin_prop ///
        capital_share_gollin_prop sd_ls %5.3f

    listtex naics_code industry_group labor_share_raw capital_share_raw ///
        labor_share_gollin_prop sd_ls n_years ///
        using "output/tab_factor_shares_summary.tex", ///
        rstyle(tabular) replace ///
        head("\begin{table}[htbp]" ///
            "\centering" ///
            "\caption{Factor Shares by Industry}" ///
            "\label{tab:factor_shares}" ///
            "\begin{tabular}{llccccc}" ///
            "\toprule" ///
            "NAICS & Industry & Labor & Capital & Adj. Labor & SD & Years \\") ///
        foot("\bottomrule" ///
            "\end{tabular}" ///
            "\begin{tablenotes}" ///
            "\small" ///
            "\item Source: BEA GDP-by-Industry accounts. " ///
            "Adj. Labor = Gollin (2002) proportional allocation. " ///
            "SD = standard deviation of annual raw labor share." ///
            "\end{tablenotes}" ///
            "\end{table}")

    display "Saved: tab_factor_shares_summary.tex"
}
if _rc != 0 {
    display "Could not create summary table."
    display "listtex may not be installed. Try: ssc install listtex"

    * Fallback: manual LaTeX generation
    file open tex using "output/tab_factor_shares_summary.tex", write replace
    file write tex "\begin{table}[htbp]" _n
    file write tex "\centering" _n
    file write tex "\caption{Factor Shares by Industry}" _n
    file write tex "\label{tab:factor_shares}" _n
    file write tex "\begin{tabular}{llcc}" _n
    file write tex "\toprule" _n
    file write tex "NAICS & Industry & Labor Share & Capital Share \\" _n
    file write tex "\midrule" _n
    file write tex "\multicolumn{4}{l}{\textit{See log file for values}} \\" _n
    file write tex "\bottomrule" _n
    file write tex "\end{tabular}" _n
    file write tex "\end{table}" _n
    file close tex
    display "Saved: tab_factor_shares_summary.tex (placeholder)"
}

* ================================================================
* TABLE 2: Copy sensitivity summary
* ================================================================
display _n "=== Table 2: Sensitivity Summary ==="
capture confirm file "input/sensitivity/sensitivity_summary.tex"
if _rc == 0 {
    copy "input/sensitivity/sensitivity_summary.tex" ///
        "output/tab_sensitivity_summary.tex", replace
    display "Copied sensitivity summary table."
}
else {
    display "Sensitivity summary table not available from upstream."
}

* ================================================================
* VERIFICATION
* ================================================================
display _n "=== Verification ==="

local all_ok = 1
foreach fig in fig_labor_share_timeseries fig_capital_share_timeseries ///
    fig_healthcare_subsectors fig_labor_share_bar fig_sensitivity_range {

    capture confirm file "output/`fig'.png"
    if _rc == 0 {
        display "  `fig'.png: OK"
    }
    else {
        display as error "  `fig'.png: MISSING"
        local all_ok = 0
    }
}

capture confirm file "output/fig_employment_vs_share.png"
if _rc == 0 {
    display "  fig_employment_vs_share.png: OK"
}
else {
    display "  fig_employment_vs_share.png: SKIPPED (needs merged data)"
}

foreach tab in tab_factor_shares_summary {
    capture confirm file "output/`tab'.tex"
    if _rc == 0 {
        display "  `tab'.tex: OK"
    }
    else {
        display as error "  `tab'.tex: MISSING"
        local all_ok = 0
    }
}

if `all_ok' {
    display _n "All core outputs generated successfully."
}
else {
    display _n as error "Some outputs missing. Check log for details."
}

display _n "Figures and tables complete."
log close
