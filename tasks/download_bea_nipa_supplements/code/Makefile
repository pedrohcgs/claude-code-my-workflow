SHELL=bash

all: ../output/proprietors_income_by_industry_raw.dta ../output/cfc_by_industry_raw.dta

include ../../generic.make
include ../../shell_functions.make

# Step 1: Fetch NIPA supplement CSVs via API
../output/nipa_proprietors_income.csv ../output/nipa_cfc.csv: fetch_nipa_supplements.py | $(OOPR)
	$(PYTHON) fetch_nipa_supplements.py

# Step 2: Import CSVs into Stata .dta format
../output/proprietors_income_by_industry_raw.dta ../output/cfc_by_industry_raw.dta: main.do ../output/nipa_proprietors_income.csv ../output/nipa_cfc.csv | $(STATA_OOPR)
	$(STATA) main.do
