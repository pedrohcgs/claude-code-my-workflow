SHELL=bash

include ../../generic.make
include ../../shell_functions.make

all: ../output/bls_employment_panel.dta

../output/bls_employment_panel.dta: main.do ../input/bls_qcew_raw/qcew_annual_national_raw.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/bls_qcew_raw/qcew_annual_national_raw.dta: ../../download_bls_qcew/output/qcew_annual_national_raw.dta
