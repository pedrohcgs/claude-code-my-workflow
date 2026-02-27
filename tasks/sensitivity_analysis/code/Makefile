SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/sensitivity_results.dta ../output/sensitivity_summary.csv ../output/sensitivity_summary.tex

../output/sensitivity_results.dta ../output/sensitivity_summary.csv ../output/sensitivity_summary.tex: main.do ../input/factor_shares/factor_shares_adjusted.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/factor_shares/factor_shares_adjusted.dta: ../../compute_factor_shares/output/factor_shares_adjusted.dta
