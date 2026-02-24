* Fake fertilizer
* Master .do file

global dir "C:\Users\Emilia\Dropbox\Fake fertilizer\PEDL\"
cd "$dir"

* log using "$dir/data/ff_master", replace

* run cleaning code
run Alison\reshape_inputsurvey_fertilizer.do
* takes $dir\data\InputSurvey-fert_questions.csv, applies labels and some other cleaning
*  saves $dir/data/manufacturer_fertilizer

* run cleaning code
run Alison\mysteryshopping_import_clean.do
* takes "$dir\data\MysteryShopping.csv", applies labels and some other cleaning
* merges on "$dir\data\label_ids.csv"
* the above merge command adds on label_id
* label_id is the correct id to merge with ICRAF lab data
* saves "$dir\data\MysteryShopping_clean.dta"

use "$dir/Alison/raw_mir_spectra.dta", clear
keep ssn - treatment
merge 1:1 ssn using "$dir/Alison/mir_predicted_tool_total_CN_reported.dta", nogen
* drop a bunch of unnecessary variables
* treatment & name are the same
* plotname & fertilizertype are the same
drop study scientist site region country material id treatment fertilizertype
rename plot_code label_id 
label var label_id "Identifying label for fertilizer sample"
merge 1:1 label_id using "$dir\data\MysteryShopping_clean.dta"


* Some basic summary stats based on guesstimates of N
* Will update once Alison generates a better "expected" variable
gen diff = total_nitrogen-expected
gen percent = diff/expected

clonevar expected2 = expected
replace expected2 = 27 if fert == 2
gen diff2 = total_nitrogen-expected2
gen percent2 = diff2/expected2

hist percent, scheme(plottig) freq
hist percent, scheme(plottig) freq by(fert)
hist percent2 if mi(comment) & percent2<.35, scheme(plottig) freq by(bag_issues1, note("")) xtitle("Nitrogen, percentage of expected")






