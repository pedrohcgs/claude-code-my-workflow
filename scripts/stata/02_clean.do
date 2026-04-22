version 18.0
capture mkdir "${STATA_OUTPUTS}"
display "Replace this stub with cleaning, merges, and feature creation."
file open cleannote using "${STATA_OUTPUTS}/02_clean_notes.txt", write replace
file write cleannote "Replace this stub with Stata cleaning logic." _n
file close cleannote
