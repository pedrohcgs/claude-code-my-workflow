SHELL=bash

all: ../output/qcew_annual_national_raw.dta

include ../../generic.make
include ../../shell_functions.make

../output/qcew_annual_national_raw.dta: main.do download_qcew.sh | $(STATA_OOPR)
	$(STATA) main.do
