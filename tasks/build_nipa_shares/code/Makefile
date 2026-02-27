SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/nipa_industry_year_panel.dta ../output/naics_concordance.dta

../output/nipa_industry_year_panel.dta ../output/naics_concordance.dta: main.do ../input/bea_gdp_industry/bea_va_panel.dta ../input/bea_nipa_supplements/nipa_supplement_tables.txt | $(STATA_OOPR)
	$(STATA) main.do

../input/bea_gdp_industry/bea_va_panel.dta: ../../download_bea_gdp_industry/output/bea_va_panel.dta
../input/bea_nipa_supplements/nipa_supplement_tables.txt: ../../download_bea_nipa_supplements/output/nipa_supplement_tables.txt
