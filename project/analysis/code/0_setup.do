* ============================================================================
* 0_setup.do --- check and install required Stata packages
* ============================================================================
* Packages used by the analysis pipeline:
*   geodist      (3_store_distance.do)
*   estout       (4_summary_stats.do --- provides eststo, esttab, estpost)
*   blindschemes (1_clean_input_survey.do, 4_summary_stats.do --- plotplain)

local packages geodist estout blindschemes

foreach pkg of local packages {
	capture which `pkg'
	if _rc {
		di as txt "Installing `pkg' from SSC..."
		ssc install `pkg', replace
	}
	else {
		di as txt "`pkg' already installed."
	}
}

set scheme plotplain
