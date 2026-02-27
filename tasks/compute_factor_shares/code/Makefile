SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/factor_shares_raw.dta ../output/factor_shares_adjusted.dta ../output/factor_shares_summary.dta

../output/factor_shares_raw.dta ../output/factor_shares_adjusted.dta ../output/factor_shares_summary.dta: main.do ../input/nipa_shares/nipa_industry_year_panel.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/nipa_shares/nipa_industry_year_panel.dta: ../../build_nipa_shares/output/nipa_industry_year_panel.dta
