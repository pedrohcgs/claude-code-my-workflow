version 18.0
capture mkdir "${STATA_OUTPUTS}"
display "Replace this stub with estimation and inference."
file open analyzenote using "${STATA_OUTPUTS}/03_analyze_notes.txt", write replace
file write analyzenote "Replace this stub with Stata estimation logic." _n
file close analyzenote
