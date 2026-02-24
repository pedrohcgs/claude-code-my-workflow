* Fake fertilizer
* Master .do file

* global dir "C:\Users\Emilia\Dropbox\Fake fertilizer\PEDL\data"
cd "$dir"

* log using "$dir/data/expected_nitrogen", replace

use raw_mir_spectra.dta, clear
keep ssn - treatment
merge 1:1 ssn using mir_predicted_tool_total_CN_reported.dta, nogen
* drop a bunch of unnecessary variables
* treatment & name are the same
* plotname & fertilizertype are the same
drop study scientist site region country material id treatment fertilizertype
rename plot_code label_id 
label var label_id "Identifying label for fertilizer sample"
merge 1:1 label_id using MysteryShopping_clean.dta

* correct manufactuer names

clonevar originalvarnameV2 = bag_manuf
recode bag_manuf (4 = 9)

	*changing the ones that say Elgon (4) to Thabiti (9)

encode label_id, gen (label_id_num)

tab label_id_num

gen ferttype_flag = 0
replace ferttype_flag = 1 if label_id_num == 236
replace ferttype_flag = 1 if label_id_num == 237
replace ferttype_flag = 1 if label_id_num == 56

label var ferttype_flag "Wrongly Coded"

	* the lab thought it was wrongly coded

* create expected %N variable 

gen expected_nitrogen = 18 if plotname == "DAP"
replace expected_nitrogen = 46 if plotname == "Urea"
replace expected_nitrogen = 27 if plotname == "CAN"
replace expected_nitrogen = 26 if label_id_num == 5 
replace expected_nitrogen = 26 if label_id_num == 33
replace expected_nitrogen = 26 if label_id_num == 62
replace expected_nitrogen = 26 if label_id_num == 107
replace expected_nitrogen = 26 if label_id_num == 108
replace expected_nitrogen = 26 if label_id_num == 123
replace expected_nitrogen = 26 if label_id_num == 188
replace expected_nitrogen = 26 if label_id_num == 241
replace expected_nitrogen = 26 if label_id_num == 245
replace expected_nitrogen = 26 if label_id_num == 267
replace expected_nitrogen = 26 if label_id_num == 304
replace expected_nitrogen = 26 if label_id_num == 306
	/*CAN Spring (Ruiru) is the only CAN fertilizer that is 26 %, those are the
	observations that are both CAN and Spring (Ruiru). It would not allow me to
	do gen expected_nitrogen = 26 if plotname=="CAN" & bag_manuf=="Spring (Ruiru)"*/

label var expected_nitrogen "Expected Percent of Nitrogen"

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






