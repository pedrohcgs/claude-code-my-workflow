version 18.0
capture mkdir "${STATA_OUTPUTS}"
display "Replace this stub with figure export logic."
file open figurenote using "${STATA_OUTPUTS}/05_figures_notes.txt", write replace
file write figurenote "Replace this stub with Stata figure export logic." _n
file close figurenote
