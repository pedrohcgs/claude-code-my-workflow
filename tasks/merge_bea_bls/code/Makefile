SHELL=bash

all: ../output/merged_bea_bls_panel.dta ../output/cross_validation_report.txt

include ../../generic.make
include ../../shell_functions.make

../output/merged_bea_bls_panel.dta ../output/cross_validation_report.txt: main.do ../input/nipa_shares/nipa_industry_year_panel.dta ../input/bls_employment/bls_employment_panel.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/nipa_shares/nipa_industry_year_panel.dta: ../../build_nipa_shares/output/nipa_industry_year_panel.dta
../input/bls_employment/bls_employment_panel.dta: ../../build_bls_employment/output/bls_employment_panel.dta
