FUNCTIONS = $(shell cat ../../shell_functions.sh)
STATA = @$(FUNCTIONS); stata_with_flag
PYTHON = @$(FUNCTIONS); python_run
R = @$(FUNCTIONS); R_pc_and_slurm

#If 'make -n' option is invoked
ifneq (,$(findstring n,$(MAKEFLAGS)))
STATA := STATA
PYTHON := PYTHON
R := R
endif
