SHELL=bash

all: ../output/bls_employment_panel.dta

include ../../generic.make
include ../../shell_functions.make

../output/bls_employment_panel.dta: main.do ../input/bls_qcew_raw/qcew_annual_national_raw.dta | $(STATA_OOPR)
	$(STATA) main.do

../input/bls_qcew_raw/qcew_annual_national_raw.dta: ../../download_bls_qcew/output/qcew_annual_national_raw.dta
