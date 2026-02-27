##This file defines shell functions that
# 1. Improve Makefiles' readability by compartmentalizing all the "if" statements around SLURM vs local executables.
# 2. Cause Stata to report an error to Make when the Stata log file ends with an error.

stata_with_flag() {
	stata_pc_and_slurm $@;
	LOGFILE_NAME=$(basename ${1%.*}.log);
	if grep -q '^r([0-9]*);$' ${LOGFILE_NAME}; then
		echo "STATA ERROR: There are errors in the running of ${1} file";
		echo "Exiting Status: $(grep '^r([0-9]*);$' ${LOGFILE_NAME} | head -1)";
		exit 1;
	fi
} ;

stata_pc_and_slurm() {
	if command -v sbatch >/dev/null ; then
		command1="module load stata/18";
		command2="stata-se -e $@";
		jobname1=$(echo "${1%.*}_" | sed 's/\.\.\/input\///');
		jobname2=$(echo ${@:2} | sed -E 's/\.\.\/(temp|input|code|output).//g' | sed -E 's/( |\/)/\_/g' | cut -c '1-200');
		full_jobname=$(echo "$jobname1$jobname2" | sed -E 's/\_{2,}/\_/g' | sed -E 's/\_$//g');
		print_info Stata $@;
		sbatch -W --export=command1="$command1",command2="$command2" --job-name="$full_jobname" run.sbatch;
	else
		if command -v stata-mp >/dev/null ; then
			print_info Stata $@;
			stata-mp -e $@;
		elif command -v stata-se >/dev/null ; then
			print_info Stata $@;
			stata-se -e $@;
		else
			echo "Stata/MP and Stata/SE not installed on this machine, or not found in PATH. Please fix to continue.";
			exit 1;
		fi;
	fi
} ;

python_run() {
	print_info Python $@;
	python3 $@;
} ;

R_pc_and_slurm() {
	if command -v sbatch >/dev/null ; then
		command1="echo R is not a module on Columbia HPC";
		command2="Rscript $@";
		jobname1=$(echo "${1%.*}_" | sed 's/\.\.\/input\///');
		jobname2=$(echo ${@:2} | sed -E 's/\.\.\/(temp|input|code|output).//g' | sed -E 's/( |\/)/\_/g' | cut -c '1-200');
		full_jobname=$(echo "$jobname1$jobname2" | sed -E 's/\_{2,}/\_/g' | sed -E 's/\_$//g');
		print_info R $@;
		sbatch -W --export=command1="$command1",command2="$command2" --job-name="$full_jobname" run.sbatch;
	else
		print_info R $@;
		Rscript $@;
	fi
} ;

print_info() {
	software=$1;
	shift;
	if [ $# == 1 ]; then
		echo "Running ${1} via ${software}, waiting...";
	else
		echo "Running ${1} via ${software} with args = ${@:2}, waiting...";
	fi
}
