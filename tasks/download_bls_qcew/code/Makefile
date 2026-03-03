SHELL=bash

all: ../output/qcew_annual_national_raw.dta

include ../../generic.make
include ../../shell_functions.make

# Step 1: Download raw QCEW CSVs from BLS
../output/data_vintage.txt: download_qcew.sh | $(OOPR)
	bash download_qcew.sh

# Step 2: Import, filter to national level, and save .dta
../output/qcew_annual_national_raw.dta: main.do ../output/data_vintage.txt | $(STATA_OOPR)
	$(STATA) main.do
