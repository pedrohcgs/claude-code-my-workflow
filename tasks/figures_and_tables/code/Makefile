SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/fig_sensitivity_range.png ../output/fig_labor_share_bar.png ../output/fig_healthcare_subsectors.png ../output/fig_labor_share_time_series.png ../output/fig_capital_share_bar.png ../output/fig_factor_shares_over_time.png ../output/tab_factor_shares_summary.tex ../output/tab_gollin_adjustments.tex

../output/fig_sensitivity_range.png ../output/fig_labor_share_bar.png ../output/fig_healthcare_subsectors.png ../output/fig_labor_share_time_series.png ../output/fig_capital_share_bar.png ../output/fig_factor_shares_over_time.png ../output/tab_factor_shares_summary.tex ../output/tab_gollin_adjustments.tex: main.do ../input/bea_bls_merged/merged_bea_bls_panel.dta ../input/factor_shares/factor_shares_adjusted.dta ../input/sensitivity/sensitivity_results.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/bea_bls_merged/merged_bea_bls_panel.dta: ../../merge_bea_bls/output/merged_bea_bls_panel.dta
../input/factor_shares/factor_shares_adjusted.dta: ../../compute_factor_shares/output/factor_shares_adjusted.dta
../input/sensitivity/sensitivity_results.dta: ../../sensitivity_analysis/output/sensitivity_results.dta
