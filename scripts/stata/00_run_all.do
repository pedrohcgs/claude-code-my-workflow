version 18.0
clear all
set more off
set seed 20260422

local repo_root : pwd
global REPO_ROOT "`repo_root'"
global STATA_OUTPUTS "${REPO_ROOT}/scripts/stata/_outputs"

capture mkdir "${STATA_OUTPUTS}"
log using "${STATA_OUTPUTS}/run_all.log", replace text

display "Running Stata pipeline from ${REPO_ROOT}"
do "${REPO_ROOT}/scripts/stata/01_load.do"
do "${REPO_ROOT}/scripts/stata/02_clean.do"
do "${REPO_ROOT}/scripts/stata/03_analyze.do"
do "${REPO_ROOT}/scripts/stata/04_tables.do"
do "${REPO_ROOT}/scripts/stata/05_figures.do"

display "Finished Stata pipeline"
log close
