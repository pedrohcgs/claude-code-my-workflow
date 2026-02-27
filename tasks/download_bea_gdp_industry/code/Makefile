SHELL=bash

all: ../output/bea_va_panel.dta ../output/bea_va_components.csv ../output/bea_chain_indexes.csv ../output/bea_table_inventory.txt ../output/bea_gross_output.csv ../output/bea_intermediate_inputs.csv ../output/bea_va_go_ratios.csv

include ../../generic.make
include ../../shell_functions.make

../output/bea_va_panel.dta ../output/bea_va_components.csv ../output/bea_chain_indexes.csv ../output/bea_table_inventory.txt ../output/bea_gross_output.csv ../output/bea_intermediate_inputs.csv ../output/bea_va_go_ratios.csv: main.do fetch_bea_api.py preprocess_bea_api.py fetch_gross_output.py | $(STATA_OOPR)
	$(STATA) main.do
