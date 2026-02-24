* ============================================================================
* Fertilizer Quality in Kenya --- master pipeline
* ============================================================================
* Run this file to execute the full analysis pipeline.
* Edit the $root path below (and in config.do) to match your machine.

* --- Set root path (EDIT THIS LINE for your machine) ---
global root "C:/git/fake-fertilizer"

* --- Load remaining path configuration ---
do "$root/analysis/config.do"

* --- 0. Check/install required packages ---
do "$code/0_setup.do"

* --- 1. Clean input survey + merge fertilizer data ---
do "$code/1_clean_input_survey.do"

* --- 2. Clean mystery shopping data + merge lab results ---
do "$code/2_clean_mystery_shopping.do"

* --- 3. Generate store proximity variables ---
do "$code/3_store_distance.do"

* --- 4. Summary statistics + histograms ---
do "$code/4_summary_stats.do"
