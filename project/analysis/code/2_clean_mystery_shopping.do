* ============================================================================
* 2_clean_mystery_shopping.do --- import + clean mystery shopping, merge labs
* ============================================================================
* Source: project/data/build/code/archive/mysteryshopping_import_clean.do
* Project: Fertilizer Quality in Kenya
*
* Does:
*   - imports mystery shopping data (rounds 1 and 2)
*   - reshapes to long format
*   - merges lab results (MIR + pXRF)
*   - labels variables and values
*   - corrects enumerator errors
*
* Assumes: config.do has been run (sets $input, $output, $temp globals)

cap: log close
log using "$output/mysteryshopping_import_clean", replace

* ============================================================================
* Import mystery shopping data
* ============================================================================
import delimited "$input/MysteryShoppingr2.csv", clear

* Sort and reshape long
sort id
gen double datetime = clock(subinstr(submissiondate, ",", "", .), "MDYhms")
gen round = 1 if datetime < tc(12mar2018 13:13:03)
replace round = 2 if datetime >= tc(12mar2018 13:13:03)

sort id

rename sealed_bag_type bag4_type
rename sealed_bag_size bag4_size
rename sealed_bag_manuf bag4_manuf
rename sealed_bag_price bag4_price
rename sealed_bag_sizeo bag4_sizeo
rename sealed_bag_manufo bag4_manufo
rename sealed_bag_type_label bag4_type_label

preserve
keep if round == 1
reshape long bag@_size bag@_sizeo bag@_type bag@_size_char bag@_manuf bag@_price bag@_negotiate bag@_size_charo bag@_manufo bag@_type_label bag@_manuf_label bag@_agitate bag@_issues bag@_issueso, i(id) j(bag_no)
drop if missing(bag_type)
* Prepare for merge with label ids
gen num = _n
save "$temp/MysteryShopping_r1.dta", replace
restore

keep if round == 2
drop if id == 190 & bag1_agitate == 0
reshape long bag@_size bag@_sizeo bag@_type bag@_size_char bag@_manuf bag@_price bag@_negotiate bag@_size_charo bag@_manufo bag@_type_label bag@_manuf_label bag@_agitate bag@_issues bag@_issueso, i(id) j(bag_no)
drop if missing(bag_type)
* Prepare for merge with label ids
bysort id: gen bag_number = _n
bysort id bag_type: gen num = _n
save "$temp/MysteryShopping_r2.dta", replace

* ============================================================================
* Import label ids for the mystery shopped bags from round 1
* ============================================================================
import delimited "$input/label_ids.csv", clear
gen round = 1
merge 1:1 num round using "$temp/MysteryShopping_r1.dta"
drop _merge
* Some enumerators entered the sealed bag information twice ---
* they counted it as a sealed bag and as a sample (as bag 1 and bag 4).
* This will remove one of the duplicates
drop if label_id == "9_CAN_4" & bag_no == 4
drop if label_id == "98_Urea_4" & bag_no == 4
drop if label_id == "95_CAN_4" & bag_no == 4
drop if label_id == "92_CAN_4" & bag_no == 4
drop if label_id == "76_CAN_4" & bag_no == 4
drop if label_id == "66_CAN_4" & bag_no == 4
drop if label_id == "55_Urea_4" & bag_no == 4
drop if label_id == "51_DAP_4" & bag_no == 4
drop if label_id == "49_CAN_4" & bag_no == 4
drop if label_id == "46_CAN_4" & bag_no == 4
drop if label_id == "38_DAP_4" & bag_no == 4
drop if label_id == "30_DAP_4" & bag_no == 4
drop if label_id == "29_DAP_4" & bag_no == 4
drop if label_id == "140_CAN_4" & bag_no == 4
drop if label_id == "139_Urea_4" & bag_no == 4
drop if label_id == "165_CAN_4" & bag_no == 4

duplicates tag label_id duration randnum1 randnum2, gen(dup)
bysort label_id: gen Xnum = _n
drop if dup > 0 & Xnum > 1
save "$temp/MysteryShopping_r1V2.dta", replace

* ============================================================================
* Add in test results (round 1 --- MIR)
* ============================================================================
use "$input/raw_mir_spectra.dta", clear
keep ssn - treatment

merge 1:1 ssn using "$input/mir_predicted_tool_total_CN_reported.dta", nogen
* Everything merges
rename plot_code label_id
drop study scientist site region country material id treatment

merge 1:1 label_id using "$temp/MysteryShopping_r1V2.dta"
save "$temp/MysteryShopping_r1V3.dta", replace

* ============================================================================
* Import label ids for the mystery shopped bags from round 2
* ============================================================================
import delimited "$input/label_idsr2.csv", clear
merge 1:1 id bag_no round using "$temp/MysteryShopping_r2.dta"
drop _merge
drop num
save "$temp/MysteryShopping_r2V2.dta", replace

* ============================================================================
* Add in test results (round 2 --- pXRF)
* ============================================================================
import delimited "$input/Migori fertilizer cn_pxrf data.csv", clear
rename ssn label_id
destring total_nitrogen, replace
merge 1:1 label_id using "$temp/MysteryShopping_r2V2.dta"
save "$temp/MysteryShopping_r2V3.dta", replace

append using "$temp/MysteryShopping_r1V3.dta"
drop _merge

* ============================================================================
* Label data
* ============================================================================
label define yesno 0 "No" 1 "Yes"
label values sealed_bag yesno
label values select_bag_negotiate yesno
label values bag_negotiate yesno

label define yesnoidk 0 "No" 1 "Yes" 31 "Don't know"
label values bag_agitate yesnoidk

label define fert 1 "DAP" 2 "CAN" 3 "Urea"
label values bag_type fert

label define size 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg" 99 "Other, specify"
label values bag_size size

label define bag 0 "Sealed manufacturer bag" 1 "Scooped from an OPEN sealed bag" 2 "Repackaged by the seller" 99 "Other, specify"
label values bag_size_char bag

label define manuf 0 "None" 1 "NCPB/Mkulima Bora" 2 "Mea Ltd." 3 "Athi river mining company" 4 "Elgon" 5 "Falcon" 6 "Yara (Chapa Meli)" 7 "Spring (Ruiru)" 9 "Thabiti" 10 "Mavuno" 99 "Other, specify"
label values bag_manuf manuf



* Split and destring fertilizer characteristics
split bag_issues, destring
	forval i = 1/`r(nvars)' {
		label variable bag_issues`i' "Fertilizer Issues #`i'"
	}
	drop bag_issues
label define issues 0 "None" 1 "Clumps or caking" 2 "Unusually dark" 3 "Oily film on fertilizer or bag" 4 "Foreign materials in sample" 5 "Powdered" 6 "Too wet" 7 "Too dry"
label values bag1_issues_0-bag3_issues_7 issues

* Gen var that equals 1 for each new store
bysort id round: gen store_nr = _n == 1

* Total number of stores
count if store_nr == 1

* Sealed Bag Info
* sealed_bag is variable for whether or not a sealed bag was obtained
* after the app requested a sealed bag
tab sealed_bag if store_nr == 1
lab var sealed_bag "App requested sealed bag, 1 indicates obtained"
* Generate variable sealed to indicate sealed bag status regardless of
* whether or not sealed bag was requested
gen sealed = bag_size < 3
lab var sealed "Sealed bag obtained, regardless of app request"
label values sealed yesno

* ============================================================================
* Enumerator errors
* ============================================================================
* Change incorrect fertilizers and manufacturers --- errors caught through
* looking at pictures of sealed bag samples
replace bag_manuf = 5 if label_id == "30_DAP_1"
replace bag_type = 1 if label_id == "40_DAP_1"
replace bag_type = 1 if label_id == "101_DAP_3"

* Missing Information --- this adds information about the sealed bags if they
* were the '4th sample'. The survey only allowed characteristics to be
* recorded for first three, so this manually adds the information.

replace bag_size_char = 0 if id == 144 & bag_no == 4
replace bag_negotiate = 0 if id == 144 & bag_no == 4
replace bag_manuf_label = "Other, specify" if id == 144 & bag_no == 4

replace bag_size_char = 0 if id == 59 & bag_no == 4
replace bag_negotiate = 0 if id == 59 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 59 & bag_no == 4

replace store_name_label = "Shiv Shankar Hardware" if id == 77
replace bag_size_char = 0 if id == 77 & bag_no == 4
replace bag_negotiate = 0 if id == 77 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 77 & bag_no == 4

replace store_name_label = "Rangwe farmers stores" if id == 199
replace bag_size_char = 0 if id == 199 & bag_no == 4
replace bag_negotiate = 0 if id == 199 & bag_no == 4
replace bag_manuf_label = "Spring (Ruiru)" if id == 199 & bag_no == 4
replace bag_issues1 = 0 if id == 199 & bag_no == 4
replace bag_issueso = "DAP fertilizer" if id == 199 & bag_no == 2

replace bag_size_char = 0 if id == 183 & bag_no == 4
replace bag_negotiate = 0 if id == 183 & bag_no == 4
replace bag_manuf_label = "Spring (Ruiru)" if id == 183 & bag_no == 4
replace bag_issues1 = 0 if id == 183 & bag_no == 4
replace bag_issueso = "poor packaging" if id == 183 & bag_no == 4

replace bag_size_char = 0 if id == 148 & bag_no == 4
replace bag_negotiate = 0 if id == 148 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 148 & bag_no == 4
replace bag_issues1 = 5 if id == 148 & bag_no == 4

replace store_name_label = "God mony Hardware" if id == 187

replace bag_size_char = 0 if id == 135 & bag_no == 4
replace bag_negotiate = 0 if id == 135 & bag_no == 4
replace bag_manuf_label = "Yara (Chapa Meli)" if id == 135 & bag_no == 4
replace bag_issues1 = 0 if id == 135 & bag_no == 4

replace store_name_label = "Imbo Agrovet" if id == 189

replace store_name_label = "Wakulima Stores" if id == 188

replace bag_size_char = 0 if id == 141 & bag_no == 4
replace bag_negotiate = 0 if id == 141 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 141 & bag_no == 4
replace bag_issues1 = 5 if id == 141 & bag_no == 4

replace bag_issueso = "Not properly sealed" if id == 136 & bag_no == 1

replace bag_size_char = 0 if id == 1 & bag_no == 4
replace bag_size_char = 0 if id == 2 & bag_no == 4
replace bag_size_char = 0 if id == 4 & bag_no == 4
replace bag_size_char = 0 if id == 10 & bag_no == 4
replace bag_size_char = 0 if id == 15 & bag_no == 4
replace bag_size_char = 0 if id == 19 & bag_no == 4
replace bag_size_char = 0 if id == 26 & bag_no == 4
replace bag_size_char = 0 if id == 31 & bag_no == 4
replace bag_size_char = 0 if id == 32 & bag_no == 4
replace bag_size_char = 0 if id == 34 & bag_no == 4
replace bag_size_char = 0 if id == 44 & bag_no == 4
replace bag_size_char = 0 if id == 47 & bag_no == 4
replace bag_size_char = 0 if id == 74 & bag_no == 4
replace bag_size_char = 0 if id == 88 & bag_no == 4
replace bag_size_char = 0 if id == 100 & bag_no == 4
replace bag_size_char = 0 if id == 101 & bag_no == 4
replace bag_size_char = 0 if id == 108 & bag_no == 4
replace bag_size_char = 0 if id == 120 & bag_no == 4
replace bag_size_char = 0 if id == 147 & bag_no == 4

replace bag_negotiate = 0 if id == 1 & bag_no == 4
replace bag_negotiate = 0 if id == 2 & bag_no == 4
replace bag_negotiate = 0 if id == 4 & bag_no == 4
replace bag_negotiate = 0 if id == 10 & bag_no == 4
replace bag_negotiate = 0 if id == 15 & bag_no == 4
replace bag_negotiate = 0 if id == 19 & bag_no == 4
replace bag_negotiate = 0 if id == 26 & bag_no == 4
replace bag_negotiate = 0 if id == 31 & bag_no == 4
replace bag_negotiate = 0 if id == 32 & bag_no == 4
replace bag_negotiate = 0 if id == 34 & bag_no == 4
replace bag_negotiate = 0 if id == 44 & bag_no == 4
replace bag_negotiate = 0 if id == 47 & bag_no == 4
replace bag_negotiate = 0 if id == 74 & bag_no == 4
replace bag_negotiate = 0 if id == 88 & bag_no == 4
replace bag_negotiate = 0 if id == 100 & bag_no == 4
replace bag_negotiate = 0 if id == 101 & bag_no == 4
replace bag_negotiate = 0 if id == 108 & bag_no == 4
replace bag_negotiate = 0 if id == 120 & bag_no == 4
replace bag_negotiate = 0 if id == 147 & bag_no == 4

replace bag_manuf_label = "Falcon" if id == 1 & bag_no == 4
replace bag_manuf_label = "Yara (Chapa Meli)" if id == 2 & bag_no == 4
replace bag_manuf_label = "Yara (Chapa Meli)" if id == 4 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 10 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 15 & bag_no == 4
replace bag_manuf_label = "Yara (Chapa Meli)" if id == 19 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 26 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 31 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 32 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 34 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 44 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 47 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 74 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 88 & bag_no == 4
replace bag_manuf_label = "Thabiti" if id == 100 & bag_no == 4
replace bag_manuf_label = "Spring (Ruiru)" if id == 101 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 108 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 120 & bag_no == 4
replace bag_manuf_label = "Falcon" if id == 147 & bag_no == 4

* These bag issues are recorded by PA from photos of samples
replace bag_issues1 = 1 if id == 1 & bag_no == 4 & round == 1
replace bag_issues2 = 5 if id == 1 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 2 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 4 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 10 & bag_no == 4 & round == 1
replace bag_issues2 = 5 if id == 10 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 15 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 19 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 26 & bag_no == 4 & round == 1
replace bag_issues2 = 5 if id == 26 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 31 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 32 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 34 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 44 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 47 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 59 & bag_no == 4 & round == 1
replace bag_issues2 = 5 if id == 59 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 74 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 77 & bag_no == 4 & round == 1
replace bag_issues2 = 5 if id == 77 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 88 & bag_no == 4 & round == 1
replace bag_issues1 = 1 if id == 100 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 101 & bag_no == 4 & round == 1
replace bag_issues1 = 4 if id == 108 & bag_no == 4 & round == 1
replace bag_issueso = "Stones" if id == 108 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 120 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 135 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 141 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 144 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 147 & bag_no == 4 & round == 1
replace bag_issues1 = 0 if id == 148 & bag_no == 4 & round == 1



* Create a variable for how much N should be in the bag
recode bag_manuf (4 = 9)
	* Changing the ones that say Elgon (4) to Thabiti (9) as they are the same

* Create expected %N variable
gen expected_nitrogen = .
replace expected_nitrogen = 27 if bag_type == 2
* Spring (Ruiru) lists 26%N
replace expected_nitrogen = 26 if bag_type == 2 & bag_manuf == 7
replace expected_nitrogen = 46 if bag_type == 3
replace expected_nitrogen = 18 if bag_type == 1
label var expected_nitrogen "Expected Percent of Nitrogen"

* Some basic summary stats
gen diff = total_nitrogen - expected_nitrogen
gen percent = (diff / expected_nitrogen) * 100
	lab var percent "Deviation from expected nitrogen (%)"
gen flag = !mi(comment)
lab var flag "Lab thought it might be mis-labeled"

drop X*

save "$output/MysteryShopping_all.dta", replace

log close
