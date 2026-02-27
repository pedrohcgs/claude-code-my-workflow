SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/qcew_annual_national_raw.dta

../output/qcew_annual_national_raw.dta: main.do download_qcew.sh | $(STATA_OOPR)
	$(STATA) main.do
