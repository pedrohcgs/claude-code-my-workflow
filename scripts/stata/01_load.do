version 18.0
capture mkdir "${STATA_OUTPUTS}"
display "Replace this stub with project-specific raw data loading logic."
file open loadnote using "${STATA_OUTPUTS}/01_load_notes.txt", write replace
file write loadnote "Replace this stub with Stata data loading commands." _n
file close loadnote
