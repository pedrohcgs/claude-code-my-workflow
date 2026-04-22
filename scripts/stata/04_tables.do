version 18.0
capture mkdir "${STATA_OUTPUTS}"
display "Replace this stub with table export logic."
file open tablenote using "${STATA_OUTPUTS}/04_tables_notes.txt", write replace
file write tablenote "Replace this stub with Stata table export logic." _n
file close tablenote
