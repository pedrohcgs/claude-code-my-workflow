SHELL=bash

all: ../output/bea_va_panel.dta ../output/nipa_comp.dta ../output/nipa_natl_income.dta ../output/nipa_prop_income.dta ../output/nipa_self_employed.dta ../output/nipa_fte_employees.dta ../output/bea_gross_output.csv ../output/bea_intermediate_inputs.csv ../output/bea_va_go_ratios.csv

include ../../generic.make
include ../../shell_functions.make

# Step 1: Fetch raw BEA API data
../output/bea_va_components.csv ../output/bea_chain_indexes.csv ../output/bea_table_inventory.txt: fetch_bea_api.py | $(OOPR)
	$(PYTHON) fetch_bea_api.py

# Step 2: Preprocess API data into clean panel
../output/bea_va_panel.csv: preprocess_bea_api.py ../output/bea_va_components.csv | $(OOPR)
	$(PYTHON) preprocess_bea_api.py

# Step 3: Download NIPA bulk data files
../output/NipaDataA.txt: | $(OOPR)
	curl -sS -o $@ "https://apps.bea.gov/national/Release/TXT/NipaDataA.txt"

../output/SeriesRegister.txt: | $(OOPR)
	curl -sS -o $@ "https://apps.bea.gov/national/Release/TXT/SeriesRegister.txt"

# Step 4: Extract NIPA tables from bulk files
../output/nipa_comp.csv ../output/nipa_natl_income.csv ../output/nipa_prop_income.csv ../output/nipa_self_employed.csv ../output/nipa_fte_employees.csv: extract_nipa_bulk.py ../output/NipaDataA.txt ../output/SeriesRegister.txt | $(OOPR)
	$(PYTHON) extract_nipa_bulk.py

# Step 5: Fetch gross output data
../output/bea_gross_output.csv ../output/bea_intermediate_inputs.csv ../output/bea_va_go_ratios.csv: fetch_gross_output.py ../output/bea_va_panel.csv | $(OOPR)
	$(PYTHON) fetch_gross_output.py

# Step 6: Import CSVs into Stata .dta format
../output/bea_va_panel.dta ../output/nipa_comp.dta ../output/nipa_natl_income.dta ../output/nipa_prop_income.dta ../output/nipa_self_employed.dta ../output/nipa_fte_employees.dta: main.do ../output/bea_va_panel.csv ../output/nipa_comp.csv ../output/nipa_natl_income.csv ../output/nipa_prop_income.csv ../output/nipa_self_employed.csv ../output/nipa_fte_employees.csv | $(STATA_OOPR)
	$(STATA) main.do
