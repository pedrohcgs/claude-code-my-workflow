********************************************************************************
* [Paper Title] - Main Regression Results
* Author: [Your Name]
* Date: [YYYY-MM-DD]
*
* This file runs all main regressions and exports to Word/LaTeX tables.
* Data: [Data source description]
* Output: [Table files created]
********************************************************************************

version 18.0
clear all
set more off

* Set working directory
cd "[project_directory]"

* Use main dataset
use "Data/clean/main.dta", clear

********************************************************************************
* SETUP
********************************************************************************

* Set panel structure
xtset stkcd year

* Define control variables
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize"
global controls_fe "$controls i.year"
global controls_fe2 "$controls i.year i.industry_code"

********************************************************************************
* Table X: [Title]
********************************************************************************

* Column (1): Baseline
xtreg dep_var indep_var $controls_fe, fe vce(cluster industry_code)
    est store col1

* Column (2): With additional controls
xtreg dep_var indep_var var3 var4 $controls_fe, fe vce(cluster industry_code)
    est store col2

* Column (3): Subsample
xtreg dep_var indep_var $controls_fe if sample_condition == 1, fe vce(cluster industry_code)
    est store col3

* Export to Word
outreg2 [col1 col2 col3] using "Tables/tableX.doc", replace word dec(4) ///
    title("Table X: [Title]") ///
    keep(indep_var var3 var4 Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize) ///
    addstat("Observations", e(N), "Adj R2", e(r2_a), "Number of Firms", e(N_g)) ///
    addtext("Year FE", "YES", "Clustered SE", "Industry")


********************************************************************************
* Table Y: [Title] - Robustness
********************************************************************************

* Robustness 1: Alternative dependent variable
xtreg dep_var_alt indep_var $controls_fe, fe vce(cluster industry_code)
    est store rob1

* Robustness 2: Alternative SE
xtreg dep_var indep_var $controls_fe, fe vce(cluster stkcd)
    est store rob2

* Robustness 3: Winsorized sample
xtreg dep_var indep_var $controls_fe, fe vce(cluster industry_code)
    est store rob3

outreg2 [rob1 rob2 rob3] using "Tables/tableY.doc", replace word dec(4) ///
    title("Table Y: [Title] - Robustness") ///
    keep(indep_var dep_var_alt) ///
    addstat("Observations", e(N)) ///
    addtext("Year FE", "YES")


********************************************************************************
* Table Z: [Title] - Heterogeneity
********************************************************************************

* Heterogeneity by group
xtreg dep_var indep_var $controls_fe if group == 1, fe vce(cluster industry_code)
    est store het1

xtreg dep_var indep_var $controls_fe if group == 0, fe vce(cluster industry_code)
    est store het2

* Interaction effect
gen indep_varXgroup = indep_var * group
xtreg dep_var indep_var group indep_varXgroup $controls_fe, fe vce(cluster industry_code)
    est store het3

outreg2 [het1 het2 het3] using "Tables/tableZ.doc", replace word dec(4) ///
    title("Table Z: [Title] - Heterogeneity") ///
    keep(indep_var group indep_varXgroup) ///
    addtext("Year FE", "YES")


********************************************************************************
* END
********************************************************************************

di "All tables exported successfully"
