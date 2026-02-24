* ============================================================================
* 3_store_distance.do --- generate within-X-km store proximity variables
* ============================================================================
* Source: project/data/function/code/ff_stores_distance.do
* Project: Fertilizer Quality in Kenya
*
* Does:
*   - computes pairwise geodesic distances between agrodealers
*   - generates within_1, within_3, within_5, within_10 (store counts)
*   - creates derived variables (assets, quality indicators, etc.)
*   - merges with mystery shopping data
*
* Assumes:
*   - config.do has been run (sets $input, $output, $temp globals)
*   - geodist package installed (see 0_setup.do)
*   - 1_clean_input_survey.do has produced agrovet_survey_cleanish.dta
*   - 2_clean_mystery_shopping.do has produced MysteryShopping_all.dta

cap: log close
log using "$output/ff_stores_distance", replace

use "$output/agrovet_survey_cleanish.dta", clear

* Generate variables of the number of stores within a certain distance

sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap: gen lon`id' = gpslongitude[`i']
}

sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap: gen lat`id' = gpslatitude[`i']
}

******* 1 km *********

gen within_1 = .
sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)`N' {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <= 1
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' > 1
	}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_1 = tempvar - 1 if id == `id'
	drop dist`id'_* tempvar
}


******* 3 km *********
gen within_3 = .
sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)`N' {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <= 3
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' > 3
	}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_3 = tempvar - 1 if id == `id'
	drop dist`id'_* tempvar
}


******* 5 km *********
gen within_5 = .
sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)`N' {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <= 5
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' > 5
	}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_5 = tempvar - 1 if id == `id'
	drop dist`id'_* tempvar
}


******* 10 km *********

gen within_10 = .
sort id
local N = _N
forvalues i = 1(1)`N' {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)`N' {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <= 10
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' > 10
	}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_10 = tempvar - 1 if id == `id'
	drop dist`id'_* tempvar
}


tab facility_type if number == 1

tab business_type if number == 1
gen bus_typeD = (business_type == 0)
label define bus_typeD 0 "Non-permanent" 1 "Permanent"
lab val bus_typeD bus_typeD
lab var bus_typeD "Dummy: Permanent store (aot seasonal)"

clonevar chain = other_business
	lab var chain "Dummy: Owner owns other agrovets"

* Number of months they sell in
gen no_months_sale = (!mi(fertsalesmonth1)) + (!mi(fertsalesmonth2)) + (!mi(fertsalesmonth3)) + (!mi(fertsalesmonth4)) + (!mi(fertsalesmonth5)) + (!mi(fertsalesmonth6)) + (!mi(fertsalesmonth7)) + (!mi(fertsalesmonth8)) + (!mi(fertsalesmonth9))

replace no_months_sale = 12 if fertsales == 1
	lab var no_months_sale "Number of months during which store sells fertilizer"

gen cellphone = .
gen smartphone = .
gen computer = .
gen vehicle = .
gen truck = .
gen motorbike = .

lab var cellphone "Business owns cellphone"
lab var smartphone "Business owns smartphone"
lab var computer "Business owns computer"
lab var vehicle "Business owns vehicle"
lab var truck "Business owns truck"
lab var motorbike "Business owns motorbike"

forval i = 1/5 {
	replace cellphone = 1 if assets_own`i' == 0
	replace cellphone = 1 if assets_own`i' == 0
	replace smartphone = 1 if assets_own`i' == 1
	replace computer = 1 if assets_own`i' == 2
	replace vehicle = 1 if assets_own`i' == 3
	replace truck = 1 if assets_own`i' == 4
	replace motorbike = 1 if assets_own`i' == 5
}
replace cellphone = 0 if mi(cellphone)
replace smartphone = 0 if mi(smartphone)
replace computer = 0 if mi(computer)
replace vehicle = 0 if mi(vehicle)
replace truck = 0 if mi(truck)
replace motorbike = 0 if mi(motorbike)


gen cellphone_rent = .
gen smartphone_rent = .
gen computer_rent = .
gen vehicle_rent = .
gen truck_rent = .
gen motorbike_rent = .

lab var cellphone_rent "Business rents cellphone"
lab var smartphone_rent "Business rents smartphone"
lab var computer_rent "Business rents computer"
lab var vehicle_rent "Business rents vehicle"
lab var truck_rent "Business rents truck"
lab var motorbike_rent "Business rents motorbike"

forval i = 1/3 {
	replace cellphone_rent = 1 if assets_rent`i' == 0
	replace smartphone_rent = 1 if assets_rent`i' == 1
	replace computer_rent = 1 if assets_rent`i' == 2
	replace vehicle_rent = 1 if assets_rent`i' == 3
	replace truck_rent = 1 if assets_rent`i' == 4
	replace motorbike_rent = 1 if assets_rent`i' == 5
}
replace cellphone_rent = 0 if mi(cellphone_rent)
replace smartphone_rent = 0 if mi(smartphone_rent)
replace computer_rent = 0 if mi(computer_rent)
replace vehicle_rent = 0 if mi(vehicle_rent)
replace truck_rent = 0 if mi(truck_rent)
replace motorbike_rent = 0 if mi(motorbike_rent)

gen fert_store_kg = fert_amount_stored if fert_unit == 1
replace fert_store_kg = fert_amount_stored * 1000 if fert_unit == 0
	lab var fert_store_kg "Amount currently stored (kg)"

	lab var runout "Do you ever run out of fertilizer or have difficulty obtaining during peak demand months?"



gen bag_weight_good = .
gen bag_weight_bad = .
gen package_condition_good = .
gen package_condition_bad = .
gen package_labeling_good = .
gen package_labeling_bad = .
gen supplier_trust_good = .
gen supplier_trust_bad = .
gen manufacturer_trust_good = .
gen manufacturer_trust_bad = .
gen lumpy_cakey_good = .
gen lumpy_cakey_bad = .
gen color_good = .
gen color_bad = .
gen smell_good = .
gen smell_bad = .
gen moisture_good = .
gen moisture_bad = .
gen cust_feedback_good = .
gen cust_feedback_bad = .

lab var bag_weight_good "Good quality: bag weight"
lab var package_condition_good "Good quality: package condition"
lab var package_labeling_good "Good quality: labeling"
lab var supplier_trust_good "Good quality: supplier trust"
lab var manufacturer_trust_good "Good quality: manufacturer trust"
lab var lumpy_cakey_good "Good quality: lumpy or cakey"
lab var color_good "Good quality: color"
lab var smell_good "Good quality: smell"
lab var moisture_good "Good quality: moisture content"
lab var cust_feedback_good "Good quality: customer feedback"

lab var bag_weight_bad "Bad quality: bag weight"
lab var package_condition_bad "Bad quality: package condition"
lab var package_labeling_bad "Bad quality: labeling"
lab var supplier_trust_bad "Bad quality: supplier trust"
lab var manufacturer_trust_bad "Bad quality: manufacturer trust"
lab var lumpy_cakey_bad "Bad quality: kumpy or cakey"
lab var color_bad "Bad quality: color"
lab var smell_bad "Bad quality: smell"
lab var moisture_bad "Bad quality: moisture content"
lab var cust_feedback_bad "Bad quality: customer feedback"

forval i = 1/3 {
	replace bag_weight_good = 1 if fert_quality_high`i' == 0
	replace bag_weight_bad = 1 if fert_quality_low`i' == 0
	replace package_condition_good = 1 if fert_quality_high`i' == 1
	replace package_condition_bad = 1 if fert_quality_low`i' == 1
	replace package_labeling_good = 1 if fert_quality_high`i' == 2
	replace package_labeling_bad = 1 if fert_quality_low`i' == 2
	replace supplier_trust_good = 1 if fert_quality_high`i' == 3
	replace supplier_trust_bad = 1 if fert_quality_low`i' == 3
	replace manufacturer_trust_good = 1 if fert_quality_high`i' == 4
	replace manufacturer_trust_bad = 1 if fert_quality_low`i' == 4
	replace lumpy_cakey_good = 1 if fert_quality_high`i' == 5
	replace lumpy_cakey_bad = 1 if fert_quality_low`i' == 5
	replace color_good = 1 if fert_quality_high`i' == 6
	replace color_bad = 1 if fert_quality_low`i' == 6
	replace smell_good = 1 if fert_quality_high`i' == 7
	replace smell_bad = 1 if fert_quality_low`i' == 7
	replace moisture_good = 1 if fert_quality_high`i' == 8
	replace moisture_bad = 1 if fert_quality_low`i' == 8
	replace cust_feedback_good = 1 if fert_quality_high`i' == 9
	replace cust_feedback_bad = 1 if fert_quality_low`i' == 9
}
replace bag_weight_good = 0 if mi(bag_weight_good)
replace bag_weight_bad = 0 if mi(bag_weight_bad)
replace package_condition_good = 0 if mi(package_condition_good)
replace package_condition_bad = 0 if mi(package_condition_bad)
replace package_labeling_good = 0 if mi(package_labeling_good)
replace package_labeling_bad = 0 if mi(package_labeling_bad)
replace supplier_trust_good = 0 if mi(supplier_trust_good)
replace supplier_trust_bad = 0 if mi(supplier_trust_bad)
replace manufacturer_trust_good = 0 if mi(manufacturer_trust_good)
replace manufacturer_trust_bad = 0 if mi(manufacturer_trust_bad)
replace lumpy_cakey_good = 0 if mi(lumpy_cakey_good)
replace lumpy_cakey_bad = 0 if mi(lumpy_cakey_bad)
replace color_good = 0 if mi(color_good)
replace color_bad = 0 if mi(color_bad)
replace smell_good = 0 if mi(smell_good)
replace smell_bad = 0 if mi(smell_bad)
replace moisture_good = 0 if mi(moisture_good)
replace moisture_bad = 0 if mi(moisture_bad)
replace cust_feedback_good = 0 if mi(cust_feedback_good)
replace cust_feedback_bad = 0 if mi(cust_feedback_bad)



keep if number == 1

keep id county facility_type business_age bus_typeD chain gender age education fertsales no_months_sale customer_max customer_min customer_avg_peak customer_avg_slow cellphone* smartphone* computer* vehicle* truck* motorbike* storage_nr fert_store_kg runout runout_cope1-runout_cope3 customer_type customer_credit bag_weight_good-cust_feedback_bad concern1-concern5 concern6-concern10 characteristics_inventory characteristics_roof characteristics_inventory characteristics_inventory2 characteristics_inventory3 characteristics_openbag characteristics_cert characteristics_sign characteristics_system characteristics_employee characteristics_customer trust manuf_number gpslatitude gpslongitude bus_typeD-cust_feedback_bad within*

save "$temp/addvars.dta", replace
merge 1:m id using "$output/MysteryShopping_all.dta"

save "$output/mystery_addvars.dta", replace

log close
