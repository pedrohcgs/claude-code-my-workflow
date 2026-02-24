* ============================================================================
* 1_clean_input_survey.do --- import + clean agrodealer survey, merge fert data
* ============================================================================
* Source: project/data/build/code/archive/reshape_inputsurvey_fertilizerV2.do
* Project: Fertilizer Quality in Kenya
*
* Does:
*   - imports fertilizer survey data (Homabay & Migori)
*   - data cleaning + create new variables
*   - merge on fertilizer info
*
* Assumes: config.do has been run (sets $input, $output, $temp globals)

cap: log close
log using "$output/agrovet_survey", replace

* ============================================================================
* Save a basic version of root data
* ============================================================================

* Import Input Survey csv --- excludes Vihiga data
import delimited "$input/InputSurvey.csv", rowrange(5:) clear

* Rename parent_key in order to merge datasets
rename key parent_key

label data "Agrodealer survey \ $S_DATE"
note: InputSurvey.dta \ agrodealer survey w/ basic cleaning \ created using 1_clean_input_survey.do \ $S_DATE
save "$output/InputSurvey.dta", replace

* ============================================================================
* Open fertilizer data & merge
* ============================================================================

* Import fertilizer questions csv --- excludes Vihiga data
import delimited "$input/InputSurvey-fert_questions.csv", rowrange(13:) clear

* Create generic ID for reshaping
gen case_id = _n
order case_id, first

* Add suffix "1" to variables for the reshape
local manuf manufacturer manufacturero purchase_unit_large price cost price_small purchase_unit

foreach x of local manuf {
	rename `x' `x'1
}

* Reshape data into long format
reshape long manufacturer manufacturero manuf_name purchase_unit_large price cost price_small purchase_unit, i(case_id fert_position fert_type_id fert_type_label) j(manuf_n)

drop if missing(manufacturer)

* Split and destring bag size variables
split bag_size, destring
	forval i = 1/`r(nvars)' {
		label variable bag_size`i' "Bag Size #`i'"
	}
	drop bag_size

save "$output/InputSurvey-fert_questions_r1.dta", replace

merge m:1 parent_key using "$output/InputSurvey.dta", nogen
* All but 2 obs merge

sort id fert_type_id manuf_n


* Fix duplicate store id
replace id = 134 if store_name == "Golden  apples hardware"

* Add labels to variables and values
label define manufacturer 0 "None" 1 "NCPB/Mkulima Bora" 2 "Mea Ltd." 3 "Athi river mining company" 4 "Elgon" 5 "Falcon" 6 "Yara (Chapa Meli)" 7 "Spring" 9 "Thabiti" 10 "Mavuno" 11 "Ruiru" 99 "Other, specify"
label values manufacturer manufacturer

label define fert_type_id 0 "NPK" 1 "DAP" 2 "CAN" 3 "Urea" 4 "Minjingu" 5 "Lime" 99 "Foliar Feed"
label values fert_type_id fert_type_id

label define bag_size 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "2 kg" 4 "Smaller bags upon request"
label values bag_size1 bag_size
label values bag_size2 bag_size
label values bag_size3 bag_size
label values bag_size4 bag_size
label values bag_size5 bag_size

label define county 3 "Homa Bay" 9 "Migori"
label values county county

label define yesno 0 "No" 1 "Yes"
label values current_stock yesno
label values foliar yesno
label values fertsales yesno
label values kephis yesno
label values runout yesno
label values customer_credit yesno
label values customer_credit2 yesno

label define customer 0 "Small-scale farmers" 1 "Large-scale farmers" 2 "Farmers' organizations" 3 "Other agro-dealers" 4 "None" 99 "Other, specify"
label values customer_type customer
label values customer_type2 customer

label define months 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"

label variable store_name "Store Name"
label variable fert_type_id "Fertilizer Type"
label variable manuf_number "Total number of manufacturers for fertilizer type"
label variable current_stock "Is this fertilizer currently in stock?"
label variable manufacturer "Name of manufacturer"
label variable manufacturero "Specify if other manufacturer"
label variable purchase_unit_large "Largest unit of fertilizer type available for purchase"
label variable purchase_unit "Smallest unit of fertilizer available for purchase"
label variable price "Selling price of largest unit of fertilizer"
label variable cost "Purchasing price of largest unit of fertilizer"
label variable price_small "Selling price of smallest unit of fertilizer available"
label variable bag_size1 "Largest bag size available for purchase"
label variable bag_size2 "Second bag size available for purchase"
label variable bag_size3 "Third bag size available for purchase"
label variable bag_size4 "Fourth bag size available for purchase"
label variable bag_size5 "Fifth bag size available for purchase"
label variable formdef_version "Survey Version ID"
label variable id "Store ID"
label variable fert_type_label "Fertilizer Type"
label variable manuf_n "Manufacturer ID (within fertilizer type)"
label variable manuf_name "Manufacturer Name"
label variable county "County"

label define owner_relationship 0 "Owner" 1 "Non-relative employee" 2 "Non-relative manager" 3 "Owner spouse" 4 "Owner relative" 5 "None"
label values owner_relationship owner_relationship

recode facility_type (2=0)
lab var facility_type "Dummy for ag inputs as main activity"
label define facility_type 1 "Ag inputs is main activity" 0 "Non-ag goods is main activity"
label values facility_type facility_type

label define business_type 0 "Permanent" 1 "Seasonal" 2 "Mobile" 99 "Other, specify"
label values business_type business_type

label define gender 0 "male" 1 "female"
label values gender gender

label variable government "What type of ownernship does business have?"
label define government 0 "Government" 1 "Individual" 2 "Farmer Group" 99 "Other, Specify"
label values government government

label define units 0 "Metric tons" 1 "Kgs"
label values fert_unit units

* Change education levels based on enumerator error
* All originally listed as MA/MSc are actually BA/BSc except for store owner
* at KBM in Kendu Bay
replace education = 5 if id == 11
label define education 0 "Primary" 1 "Secondary" 2 "Certificate/Trade School" 3 "Diploma" 4 "University BA/BSc" 5 "University M.S./M.A."
label values education education

* Fertilizer sale month amendments from Fred
replace fertsalesmost = "2 3 9" if id == 21
replace fertsalesleast = "6 7" if id == 21
replace fertsalesmost = "2 3 8 9" if id == 32
replace fertsalesleast = "7 12" if id == 32
replace fertsalesmost = "2 3 7 8" if id == 59
replace fertsalesleast = "5 6 11 12" if id == 59

* Rename manufacturers because of the prior survey that autopopulated the
* third manufacturer with the second manufacturer name
replace manuf_name = "None" if manufacturer == 0
replace manuf_name = "NCPB/Mkulima Bora" if manufacturer == 1
replace manuf_name = "Mea Ltd." if manufacturer == 2
replace manuf_name = "Athi river mining company" if manufacturer == 3
replace manuf_name = "Elgon" if manufacturer == 4
replace manuf_name = "Falcon" if manufacturer == 5
replace manuf_name = "Yara (Chapa Meli)" if manufacturer == 6
replace manuf_name = "Other, Specify" if manufacturer == 99

* Add new value for manufacturer Spring
gen Xspring = strmatch(manufacturero, "Spring*")
replace manufacturer = 7 if Xspring == 1 & manufacturer == 99

gen Xthabiti = strmatch(manufacturero, "*Thabiti*")
replace manufacturer = 9 if Xthabiti == 1 & manufacturer == 99

gen Xmavuno = strmatch(manufacturero, "*Mavuno*")
replace manufacturer = 10 if Xmavuno == 1 & manufacturer == 99

gen Xruiru = strmatch(manufacturero, "*Ruiru*")
replace manufacturer = 11 if Xruiru == 1 & manufacturer == 99
drop X*

* Remove manufacturer 7, 9, 10, 11 from manufacturero
replace manufacturero = " " if manufacturer == 7
replace manufacturero = " " if manufacturer == 9
replace manufacturero = " " if manufacturer == 10
replace manufacturero = " " if manufacturer == 11

* A couple of errors in purchase_unit
replace purchase_unit = 2 if purchase_unit == 6 & price_small == 850
replace purchase_unit = 4 if purchase_unit == 6 & price_small == 150
replace purchase_unit = 3 if purchase_unit == 6 & price_small == 250
replace purchase_unit = 3 if purchase_unit == 6 & price_small == 300
replace purchase_unit = 2 if purchase_unit == 7 & price_small == 100
replace purchase_unit_large = 0 if cost == 2350 & purchase_unit_large == 4 & id == 124
replace purchase_unit_large = 0 if price == 3000 & id == 190 & purchase_unit_large == 4
replace purchase_unit_large = 0 if price == 3100 & id == 190 & purchase_unit_large == 2
replace purchase_unit_large = 0 if id == 79 & cost > 2100 & purchase_unit_large == 2
replace purchase_unit_large = 0 if id == 80 & cost == 2500 & purchase_unit_large == 2
replace purchase_unit_large = 0 if id == 113 & cost == 3200 & purchase_unit_large == 1
replace purchase_unit_large = 0 if id == 124 & cost > 2100 & purchase_unit_large == 4
replace purchase_unit_large = 0 if id == 191 & cost > 2100 & purchase_unit_large == 2
replace purchase_unit = 2 if price_small > 600 & purchase_unit == 5 & (fert_type_id == 1 | fert_type_id == 2)
* For some reason some obs are straight up missing purchase_unit_large ---
* easy to infer what size when the prices are really large:
replace purchase_unit_large = 0 if fert_type_id < 4 & price > 2000
replace purchase_unit_large = 0 if fert_type_id < 4 & price >= 1800
replace cost = 2000 if id == 9 & cost == 200

label define purchase_unit 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg"
lab val purchase_unit purchase_unit
lab val purchase_unit_large purchase_unit

* Drop string variables
drop fert_type_label manuf_name
order formdef_version, last

order id

* Label enumerators
label define enum 1 "Fred" 2 "Gorrety" 3 "Victor" 4 "Corazon" 5 "Hilda" 6 "Albert" 7 "Jared" 8 "Josephat"
label values enum enum

***
bysort id: gen number = _n
tab manuf_number if number == 1
sum manuf_number if number == 1

label variable number "Number of fertilizers by manufacturer within a store"

* Gen var that equals 1 for each new fertilizer type
bysort id fert_type_id: gen fert_number = _n == 1
* Make another variable with the running sum (within store ID)
bysort id: gen fert_number_total = sum(fert_number)
* Replace this with the highest number (i.e. the number of fertilizers
* that the store currently carries)
bysort id: replace fert_number_total = fert_number_total[_N]

label variable fert_number "Indicates '1' for each new fertilizer type"
label variable fert_number_total "Number of fertilizer types the store currently carries"

* Tabulate the number of fertilizer types stores have
tab fert_number_total if number == 1
sum fert_number_total if number == 1

* Tabulate the types of fertilizers that they have
tab fert_type_id if fert_number == 1

* Tabulate the number of manufacturers for all fertilizers
tab manuf_number if fert_number == 1
tab manufacturer

* Make a variable indicating if the store sells the various bag sizes
gen bagsizeany = (bag_size1 == 4) + (bag_size2 == 4) + (bag_size3 == 4) + (bag_size4 == 4) + (bag_size5 == 4)
gen bagsize2 = (bag_size1 == 3) + (bag_size2 == 3) + (bag_size3 == 3) + (bag_size4 == 3) + (bag_size5 == 3)
gen bagsize10 = (bag_size1 == 2) + (bag_size2 == 2) + (bag_size3 == 2) + (bag_size4 == 2) + (bag_size5 == 2)
gen bagsize25 = (bag_size1 == 1) + (bag_size2 == 1) + (bag_size3 == 1) + (bag_size4 == 1) + (bag_size5 == 1)

label variable bagsizeany "Indicates if store sells any bag size of the fertilizer type"
label variable bagsize2 "Indicates if store sells 2 kg bags of fertilizer type"
label variable bagsize10 "Indicates if store sells 10 kg bags of fertilizer type"
label variable bagsize25 "Indicates if store sells 25 kg bags of fertilizer type"

* Tabulate the different fertilizers and whether they are sold in "anysize" bags
tab fert_type_id if fert_number == 1, sum(bagsizeany)
tab fert_type_id if fert_number == 1, sum(bagsize2)
tab fert_type_id if fert_number == 1, sum(bagsize10)
tab fert_type_id if fert_number == 1, sum(bagsize25)

* Generate vars for whether or not the store sells a certain fertilizer type
gen Xdap = 1 if fert_type_id == 1
bysort id: egen dap = max(Xdap)
replace dap = 0 if mi(dap) & !mi(fert_type_id)

gen Xcan = (fert_type_id == 2)
bysort id: egen can = max(Xcan)
replace can = 0 if mi(can) & !mi(fert_type_id)

gen Xurea = (fert_type_id == 3)
bysort id: egen urea = max(Xurea)
replace urea = 0 if mi(urea) & !mi(fert_type_id)

drop X*

label variable dap "Indicates if store sells DAP fertilizer"
label variable can "Indicates of store sells CAN fertilizer"
label variable urea "Indicates if store sells Urea fertilizer"

* Destring all appropriate variables and label
split fert_type, destring
	forval i = 1/`r(nvars)' {
		label variable fert_type`i' "Fert Type #`i'"
	}
	order fert_type1-fert_type6, after(fert_type)
	drop fert_type
label define fert_type 0 "NPK" 1 "DAP" 2 "CAN" 3 "Urea" 4 "Minjingu" 5 "Lime" 6 "TSP" 7 "SSP" 99 "Foliar Feed"
label values fert_type1-fert_type6 fert_type


split fertsalesmonth, destring
	forval i = 1/`r(nvars)' {
		label variable fertsalesmonth`i' "During which months does the business sell fertilizer? (#`i')"
	}
	order fertsalesmonth1-fertsalesmonth9, after(fertsalesmonth)
	drop fertsalesmonth
	label values fertsalesmonth1-fertsalesmonth9 months

split fertsalesmost, destring
	forval i = 1/`r(nvars)' {
		label variable fertsalesmost`i' "In what month(s) do you typically sell the most fertilizer? (#`i')"
	}
	order fertsalesmost1-fertsalesmost12, after(fertsalesmost)
	drop fertsalesmost
	label values fertsalesmost1-fertsalesmost12 months

* Drop calculate fields
drop fertsalescheck1-fertsaleschecknote

split fertsalesleast, destring
	forval i = 1/`r(nvars)' {
		label variable fertsalesleast`i' "In what month(s) do you typically sell the least fertilizer? (#`i')"
	}
	order fertsalesleast1-fertsalesleast10, after(fertsalesleast)
	drop fertsalesleast
	label values fertsalesleast1-fertsalesleast10 months

* What assets does the owner own/rent?
split assets_own, destring
	forval i = 1/`r(nvars)' {
		label variable assets_own`i' "Assets owned #`i'"
	}
	order assets_own1-assets_own5, after(assets_own)
	drop assets_own

split assets_rent, destring
	forval i = 1/`r(nvars)' {
		label variable assets_rent`i' "Assets rented #`i'"
	}
	order assets_rent1-assets_rent3, after(assets_rent)
	drop assets_rent

label define assets 0 "Mobile Phone" 1 "Smartphone" 2 "Computer/laptop" 3 "Vehicle" 4 "Pickup truck" 5 "Motorbike" 6 "Bicycle" 7 "None"
label values assets_own1-assets_own5 assets
label values assets_rent1-assets_rent3 assets

split storage, destring
	forval i = 1/`r(nvars)' {
		label variable storage`i' "Storage Unit #`i'"
	}
	order storage1-storage3, after(storage)
	drop storage
label define storage 0 "Current retail location/shop" 1 "Personal home" 2 "Another shop" 3 "Personal warehouse" 4 "Rented warehouse" 99 "Other, specify"
label values storage1-storage3 storage

split runout_cope, destring
	forval i = 1/`r(nvars)' {
		label variable runout_cope`i' "Runout Cope #`i'"
	}
	order runout_cope1-runout_cope3, after(runout_cope)
	drop runout_cope
label define runout 0 "Purchase more from regular supplier" 1 "Top up from local dealer (not regular)" 2 "Direct customers to another agrovet" 3 "Purchase more from nearby town" 4 "Nothing" 5 "Other, specify"
label values runout_cope1-runout_cope3 runout

* Need to rename credit_repay and credit_repay2 so I can split and destring
rename credit_repay credit_repay_cust1
rename credit_repay2 credit_repay_cust2

split credit_repay_cust1, destring gen(credit_repay_cust1_)
	forval i = 1/`r(nvars)' {
		label variable credit_repay_cust1_`i' "How do 1st type of customer repay you? (#`i')"
	}
	drop credit_repay_cust1

split credit_repay_cust2, destring gen(credit_repay_cust2_)
	forval i = 1/`r(nvars)' {
		label variable credit_repay_cust2_`i' "How do 2nd type of customer repay you? (#`i')"
	}
	drop credit_repay_cust2

label define credit 0 "In cash" 1 "MPESA" 2 "In-kind with harvested grains" 99 "Other, specify"
label values credit_repay_cust1* credit
label values credit_repay_cust2* credit

split fert_quality_high, destring
	forval i = 1/`r(nvars)' {
		label variable fert_quality_high`i' "Fert Quality High #`i'"
	}
	order fert_quality_high1-fert_quality_high6, after(fert_quality_high)
	drop fert_quality_high

split fert_quality_low, destring
	forval i = 1/`r(nvars)' {
		label variable fert_quality_low`i' "Fert Quality Low #`i'"
	}
	order fert_quality_low1-fert_quality_low6, after(fert_quality_low)
	drop fert_quality_low

split owner_relationship_other, destring
	forval i = 1/`r(nvars)' {
		label variable owner_relationship_other`i' "Other Survey Respondents #`i'"
	}
	order owner_relationship_other1-owner_relationship_other2, after(owner_relationship_other)
	drop owner_relationship_other
label define others 0 "Owner" 1 "Non-relative employee" 2 "Non-relative manager" 3 "Owner spouse" 4 "Owner relative" 99 "None"
label values owner_relationship_other1-owner_relationship_other2 others


	label variable concern_label "How big a concern for the market is..."
	note concern_label: "How big a concern for the market is..."
	label define concern_label 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern_label concern_label

	label variable concern1 "Fertilizer can be adulterated"
	note concern1: "Fertilizer can be adulterated"
	label define concern1 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern1 concern1

	label variable concern2 "Fertilizer can be caked and clumpy from moisture"
	note concern2: "Fertilizer can be caked and clumpy from moisture"
	label define concern2 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern2 concern2

	label variable concern3 "Fertilizer can be too old"
	note concern3: "Fertilizer can be too old"
	label define concern3 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern3 concern3

	label variable concern4 "Fertilizer can have a nutrient content that is different from what is advertised"
	note concern4: "Fertilizer can have a nutrient content that is different from what is advertised"
	label define concern4 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern4 concern4

	label variable concern5 "Other agrovets sell poor quality fertilizer, which reduces trust in the market"
	note concern5: "Other agrovets sell poor quality fertilizer, which reduces trust in the market"
	label define concern5 0 "No problem" 1 "Affects few stores" 2 "Affects < 50% of market" 3 "Affecting ~50% of market" 4 "Affects majority of fertilizer in the market"
	label values concern5 concern5

	label variable concern_label2 "How much do you agree with..."
	note concern_label2: "How much do you agree with..."
	label define concern_label2 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern_label2 concern_label2

	label variable concern6 "Supply is often limited during months of peak demand"
	note concern6: "Supply is often limited during months of peak demand"
	label define concern6 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern6 concern6

	label variable concern7 "My business often has leftover supply at the end of seson"
	note concern7: "My business often has leftover supply at the end of seson"
	label define concern7 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern7 concern7

	label variable concern8 "It is difficult to predict the amount of sales in a seson"
	note concern8: "It is difficult to predict the amount of sales in a seson"
	label define concern8 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern8 concern8

	label variable concern9 "Consumers do not know how to tell good fertilizer from bad"
	note concern9: "Consumers do not know how to tell good fertilizer from bad"
	label define concern9 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern9 concern9

	label variable concern10 "Customers have a lack of trust in the market"
	note concern10: "Customers have a lack of trust in the market"
	label define concern10 0 "Strongly disagree" 1 "Disagree a little" 2 "Neutral" 3 "Agree a little" 4 "Strongly agree"
	label values concern10 concern10

	label variable other_stores_nr "How many other stores does the respondent know about?"
	note other_stores_nr: "How many other stores does the respondent know about?"

	label variable owner_relationship_other1 "What other people helped answer the survey?"
	note owner_relationship_other1: "What other people helped answer the survey?"

	label variable owner_relationship_other2 "What other people helped answer the survey?"
	note owner_relationship_other2: "What other people helped answer the survey?"

	label variable gpslatitude "GPS latitude (outside agrovet)"
	note gpslatitude: "Enumerator: Please make sure that you are right outside the agrovet. Please remain outside while the device gets a GPS reading. (latitude)"

	label variable gpslongitude "GPS longitude (outside agrovet)"
	note gpslongitude: "Enumerator: Please make sure that you are right outside the agrovet. Please remain outside while the device gets a GPS reading. (longitude)"

	label variable gpsaltitude "GPS altitude (outside agrovet)"
	note gpsaltitude: "Enumerator: Please make sure that you are right outside the agrovet. Please remain outside while the device gets a GPS reading. (altitude)"

	label variable gpsaccuracy "GPS accuracy (outside agrovet)"
	note gpsaccuracy: "Enumerator: Please make sure that you are right outside the agrovet. Please remain outside while the device gets a GPS reading. (accuracy)"

	label variable characteristics_roof "Does the business have a tin roof?"
	note characteristics_roof: "Does the business have a tin roof?"
	label define characteristics_roof 1 "Yes" 0 "No"
	label values characteristics_roof characteristics_roof

	label variable characteristics_inventory "Is inventory visible?"
	note characteristics_inventory: "Is inventory visible?"
	label define characteristics_inventory 0 "No" 1 "Yes" 2 "Some but not all" 3 "No because there is no inventory"
	label values characteristics_inventory characteristics_inventory

	label variable characteristics_inventory2 "Is inventory stored on concrete floor?"
	note characteristics_inventory2: "Is inventory stored on concrete floor?"
	label define characteristics_inventory2 1 "Yes" 0 "No"
	label values characteristics_inventory2 characteristics_inventory2

	label variable characteristics_inventory3 "Is inventory stored on pallets?"
	note characteristics_inventory3: "Is inventory stored on pallets?"
	label define characteristics_inventory3 1 "Yes" 0 "No"
	label values characteristics_inventory3 characteristics_inventory3

	label variable characteristics_openbag "Are there previously opened bags visible?"
	note characteristics_openbag: "Are there previously opened bags visible?"
	label define characteristics_openbag 1 "Yes" 0 "No"
	label values characteristics_openbag characteristics_openbag

	label variable characteristics_cert "Is there certification posted/visible?"
	note characteristics_cert: "Is there certification posted/visible?"
	label define characteristics_cert 1 "Yes" 0 "No"
	label values characteristics_cert characteristics_cert

	label variable characteristics_sign "Is there a sign outside the store for advertizing purposes?"
	note characteristics_sign: "Is there a sign outside the store for advertizing purposes?"
	label define characteristics_sign 1 "Yes" 0 "No"
	label values characteristics_sign characteristics_sign

	label variable characteristics_system "What kind of system does the business use to keep track of sales transactions?"
	note characteristics_system: "What kind of system does the business use to keep track of sales transactions?"
	label define characteristics_system 0 "None" 1 "Manual system (ledger)" 2 "Computer / laptop" 3 "Cell phone"
	label values characteristics_system characteristics_system

	label variable characteristics_employee "How many employees were working (excluding the owner) in the store?"
	note characteristics_employee: "How many employees were working (excluding the owner) in the store?"

	label variable characteristics_customer "How many customers were present during the interview?"
	note characteristics_customer: "How many customers were present during the interview?"

	label variable trust "How good do you think the quality of this respondent's fertilizer is?"
	note trust: "How good do you think the quality of this respondent's fertilizer is?"
	label define trust 0 "I have no idea" 1 "Very low" 2 "Low" 3 "Average" 4 "High" 5 "Very high"
	label values trust trust

* Generate new variable value for quality questions
gen Xqualityo = strmatch(fert_quality_higho, "I can't*")
replace fert_quality_high1 = 10 if Xqualityo == 1 & fert_quality_high1 == 99

gen Xqualitylowo = strmatch(fert_quality_lowo, "I can't*")
replace fert_quality_low1 = 10 if Xqualitylowo == 1 & fert_quality_low1 == 99

label define quality 0 "Bag weight" 1 "Condition of package" 2 "Labeling on package" 3 "Level of trust in SUPPLIER" 4 "Level of trust in MANUFACTURER" 5 "Lumpy or cakey" 6 "Color" 7 "Smell" 8 "Moisture content" 9 "Customer feedback" 10 "Can't Tell Quality" 99 "Other, specify"
label values fert_quality_high1-fert_quality_high6 quality
label values fert_quality_low1-fert_quality_low6 quality
replace fert_quality_higho = " " if fert_quality_high1 == 10
replace fert_quality_lowo = " " if fert_quality_low1 == 10

* Enumerator errors
* Fixing label for quality question and removing the "other, specify"
replace fert_quality_high1 = 9 if id == 21
replace fert_quality_higho = " " if fert_quality_high1 == 9

replace fert_quality_low1 = 9 if id == 21
replace fert_quality_lowo = " " if fert_quality_high1 == 9

* Drop irrelevant entries
drop submissiondate-comments

* Change store ownership to individual for these stores
replace government = 1 if id == 100
replace government = 1 if id == 52
replace government = 1 if id == 134
replace government = 1 if id == 102
replace governmento = " " if id == 100
replace governmento = " " if id == 52
replace governmento = " " if id == 134
replace governmento = " " if id == 102


* Change runout cope to nothing and remove other, specified for these stores
replace runout_cope2 = 4 if id == 15
replace runout_cope2 = 4 if id == 64
replace runout_cope2 = 4 if id == 130
replace runout_cope1 = 4 if id == 165

replace runout_copeo = " " if id == 15
replace runout_copeo = " " if id == 64
replace runout_copeo = " " if id == 130
replace runout_copeo = " " if id == 165


* Incorporating enumerator comments
replace cost = . if cost == 0
replace price = . if price == 0

* Drop ID 11: store just opened, only sold Foliar Feed at time of survey
drop if id == 11

* Generate supplier dummy variable
gen supplier = 0
replace supplier = 1 if id == 4 | id == 88 | id == 29 | id == 50 | id == 71 | id == 67 | id == 34 | id == 103 | id == 120 | id == 135 | id == 151 | id == 133 | id == 136
lab var supplier "Dummy for identified as supplier to other store"



gen kg_largep = 1 if purchase_unit_large == 5
replace kg_largep = 2 if purchase_unit_large == 4
replace kg_largep = 5 if purchase_unit_large == 3
replace kg_largep = 10 if purchase_unit_large == 2
replace kg_largep = 25 if purchase_unit_large == 1
replace kg_largep = 50 if purchase_unit_large == 0
	lab var kg_largep "Unit for large bags sold"

* Some obvious mismatches between sale unit, sale price, and cost
gen kg_largec = kg_largep
	lab var kg_largec "Unit for large bags bought"

replace kg_largep = 10 if id == 79 & kg_largep == 50 & price >= 600 & price < 700
replace kg_largep = 10 if id == 80 & kg_largep == 50 & price >= 600 & price < 700
replace kg_largep = 1 if id == 85 & kg_largep == 50 & price == 150
replace kg_largec = 50 if id == 113 & price == 1300 & cost == 2400
replace kg_largec = 50 if id == 113 & price == 1500 & cost == 3200
replace kg_largep = 25 if id == 113 & price == 1500 & cost == 3200
replace kg_largec = 50 if id == 114 & price == 1400 & cost == 2400
replace kg_largec = 50 if id == 116 & price == 750 & cost == 2750
replace kg_largec = 50 if id == 116 & price == 750 & cost == 2700
replace kg_largec = 50 if id == 116 & price == 650 & cost == 2200
replace kg_largep = 2 if id == 124 & price == 200 & cost == 2600
replace kg_largep = 2 if id == 124 & price == 160 & cost == 2350
replace cost = 2000 if id == 28 & price == 2500 & cost == 200
replace kg_largep = 2 if id == 124 & price == 150 & cost == 2350
replace price = 3000 if id == 150 & price == 300
replace kg_largec = 0 if cost == 3000 & price == 150 & id == 85

gen kg_small = 1 if purchase_unit == 5
replace kg_small = 2 if purchase_unit == 4
replace kg_small = 5 if purchase_unit == 3
replace kg_small = 10 if purchase_unit == 2
replace kg_small = 25 if purchase_unit == 1
replace kg_small = 50 if purchase_unit == 0
	lab var kg_small "Unit for small bags sold"

* Look at price dispersion
gen price_kg_large = price / kg_largep
	lab var price_kg_large "Price/kg for largest unit sold"
gen price_kg_small = price_small / kg_small
	lab var price_kg_small "Price/kg for smallest unit sold"
* What did the agrodealer pay?
gen cost_kg_large = cost / kg_largec
	lab var cost_kg_large "Purchase price/kg for largest unit sold"
gen markup_kg = (price_kg_large - cost_kg_large) / cost_kg_large
	lab var markup_kg "(Price-cost)/cost (per kg)"

* Large prices
bysort id: egen Xnpk_pricel = mean(price_kg_large) if fert_type_id == 0
bysort id: egen npk_pricel = max(Xnpk_pricel)

bysort id: egen Xdap_pricel = mean(price_kg_large) if fert_type_id == 1
bysort id: egen dap_pricel = max(Xdap_pricel)

bysort id: egen Xcan_pricel = mean(price_kg_large) if fert_type_id == 2
bysort id: egen can_pricel = max(Xcan_pricel)

bysort id: egen Xurea_pricel = mean(price_kg_large) if fert_type_id == 3
bysort id: egen urea_pricel = max(Xurea_pricel)
* Small prices
bysort id: egen Xnpk_prices = mean(price_kg_small) if fert_type_id == 0
bysort id: egen npk_prices = max(Xnpk_prices)

bysort id: egen Xdap_prices = mean(price_kg_small) if fert_type_id == 1
bysort id: egen dap_prices = max(Xdap_prices)

bysort id: egen Xcan_prices = mean(price_kg_small) if fert_type_id == 2
bysort id: egen can_prices = max(Xcan_prices)

bysort id: egen Xurea_prices = mean(price_kg_small) if fert_type_id == 3
bysort id: egen urea_prices = max(Xurea_prices)
* Markup
bysort id: egen Xnpk_markup = mean(markup_kg) if fert_type_id == 0
bysort id: egen npk_markup = max(Xnpk_markup)

bysort id: egen Xdap_markup = mean(markup_kg) if fert_type_id == 1
bysort id: egen dap_markup = max(Xdap_markup)

bysort id: egen Xcan_markup = mean(markup_kg) if fert_type_id == 2
bysort id: egen can_markup = max(Xcan_markup)

bysort id: egen Xurea_markup = mean(markup_kg) if fert_type_id == 3
bysort id: egen urea_markup = max(Xurea_markup)
* Cost
bysort id: egen Xnpk_cost = mean(cost_kg_large) if fert_type_id == 0
bysort id: egen npk_cost = max(Xnpk_cost)

bysort id: egen Xdap_cost = mean(cost_kg_large) if fert_type_id == 1
bysort id: egen dap_cost = max(Xdap_cost)

bysort id: egen Xcan_cost = mean(cost_kg_large) if fert_type_id == 2
bysort id: egen can_cost = max(Xcan_cost)

bysort id: egen Xurea_cost = mean(cost_kg_large) if fert_type_id == 3
bysort id: egen urea_cost = max(Xurea_cost)

drop X*
drop intro1 intro2 business_note

bysort id: gen idnumber = _n
save "$output/agrovet_survey_cleanish.dta", replace


* ============================================================================
* Make a data version with just store IDs, lat/long for distance calculations
* Also keep the prices and markup
* ============================================================================
duplicates drop id, force

keep id gpslat gpslong county_id npk_pricel dap_pricel can_pricel urea_pricel npk_prices dap_prices can_prices urea_prices npk_markup dap_markup can_markup urea_markup npk_cost dap_cost can_cost urea_cost

label data "Agrodealer survey lat/long only \ $S_DATE"
note: agrovet_survey_gps.dta \ agrodealer survey w/ basic cleaning \ created using 1_clean_input_survey.do \ $S_DATE
save "$output/agrovet_survey_gps.dta", replace

log close
