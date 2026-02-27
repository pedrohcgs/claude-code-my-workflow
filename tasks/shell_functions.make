# Source shell functions at runtime so bash (not Make) handles $@, $1, etc.
STATA = @. ../../shell_functions.sh; stata_with_flag
PYTHON = @. ../../shell_functions.sh; python_run
R = @. ../../shell_functions.sh; R_pc_and_slurm

#If 'make -n' option is invoked
ifneq (,$(findstring n,$(MAKEFLAGS)))
STATA := STATA
PYTHON := PYTHON
R := R
endif
