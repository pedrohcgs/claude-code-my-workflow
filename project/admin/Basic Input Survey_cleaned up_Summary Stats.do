global dir "C:\Users\Alison Harrell\Documents\PAship"
cd "$dir"
import delimited "$dir\Data files\InputSurvey.csv", rowrange(5:) clear

*rename parent_key in order to merge datasets*
rename key parent_key

**Fix duplicate store id**
replace id=134 if store_name=="Golden  apples hardware"

label define county 3 "Homa Bay" 9 "Migori"
label values county county

label define customer 0 "Small-scale farmers" 1 "Large-scale farmers" 2 "Farmers’ organizations" 3 "Other agro-dealers" 4 "None" 99 "Other, specify"
label values customer_type customer
label values customer_type2 customer

label define months 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"

label variable store_name "Store Name"
label variable formdef_version "Survey Version ID"
label variable id "Store ID"
label variable county "County"

label define owner_relationship 0 "Owner" 1 "Non-relative employee" 2 "Non-relative manager" 3 "Owner spouse" 4 "Owner relative" 5 "None"
label values owner_relationship owner_relationship

label define facility_type 1 "Primarily sells ag inputs" 2 "Primarily sells other goods than agricultural "
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

*change education levels based on enumerator error--all originally listed as MA/MSc are actually BA/BSc except for store owner at KBM in Kendu Bay
replace education=5 if id==11
label define education 0 "Primary" 1 "Secondary" 2 "Certificate/Trade School" 3 "Diploma" 4 "University BA/BSc" 5 "University M.S./M.A."
label values education education

*Fertilizer sale month amendments from Fred--still need amendments for id 10 if available*
replace fertsalesmost="2 3 9" if id==21
replace fertsalesleast="6 7" if id==21
replace fertsalesmost="2 3 8 9" if id==32
replace fertsalesleast="7 12" if id==32
replace fertsalesmost="2 3 7 8" if id==59
replace fertsalesleast="5 6 11 12" if id==59


//label define purchase_unit 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg"
** Need to figure out what the purchase_unit numbers actually mean..., some of the entries have 6 and 7?


order formdef_version, last

**label enumerators**
label define enum 1 "Fred" 2 "Gorrety" 3 "Victor" 4 "Corazon" 5 "Hilda" 6 "Albert" 7 "Jared" 8 "Josephat"
label values enum enum

*destring all appropriate varibles and label*
split fert_type, destring
	forval i =1/`r(nvars)'{
		label variable fert_type`i' "Fert Type #`i'"
		}
	order fert_type1-fert_type6, after(fert_type)
	drop fert_type
label define fert_type 0 "NPK" 1 "DAP" 2 "CAN" 3 "Urea" 4 "Minjingu" 5 "Lime" 6 "TSP" 7 "SSP" 99 "Foliar Feed" //Foliar Feed is for older version of survey
label values fert_type1-fert_type6 fert_type


split fertsalesmonth, destring
	forval i =1/`r(nvars)'{
		label variable fertsalesmonth`i' "Fert Sales Month #`i'"
		}
	order fertsalesmonth1-fertsalesmonth9, after(fertsalesmonth)
	drop fertsalesmonth
	label values fertsalesmonth1-fertsalesmonth9 months

split fertsalesmost, destring
	forval i =1/`r(nvars)'{
		label variable fertsalesmost`i' "Fert Sales Most #`i'"
		}
	order fertsalesmost1-fertsalesmost12, after(fertsalesmost)
	drop fertsalesmost
	label values fertsalesmost1-fertsalesmost12 months	
	
*Not sure what these are--they are all filled with zeroes and don't seem to relate to a survey question*
drop fertsalescheck1-fertsaleschecknote

split fertsalesleast, destring
	forval i =1/`r(nvars)'{
		label variable fertsalesleast`i' "Fert Sales Least #`i'"
		}
	order fertsalesleast1-fertsalesleast10, after(fertsalesleast)
	drop fertsalesleast
	label values fertsalesleast1-fertsalesleast10 months	

**split assets owned and rented next**
split assets_own, destring
	forval i =1/`r(nvars)'{
		label variable assets_own`i' "Assets Owned #`i'"
		}
	order assets_own1-assets_own5, after(assets_own)
	drop assets_own

split assets_rent, destring
	forval i =1/`r(nvars)'{
		label variable assets_rent`i' "Assets Rented #`i'"
		}
	order assets_rent1-assets_rent3, after(assets_rent)
	drop assets_rent


label define assets 0 "Mobile Phone" 1 "Smartphone" 2 "Computer/laptop" 3 "Vehicle" 4 "Pickup truck" 5 "Motorbike" 6 "Bicycle" 7 "None"
label values assets_own1-assets_own5 assets
label values assets_rent1-assets_rent3 assets

split storage, destring
	forval i =1/`r(nvars)'{
		label variable storage`i' "Storage Unit #`i'"
		}
	order storage1-storage3, after(storage)
	drop storage
label define storage 0 "Current retail location/shop" 1 "Personal home" 2 "Another shop" 3 "Personal warehouse" 4 "Rented warehouse" 99 "Other, specify"
label values storage1-storage3 storage
 
split runout_cope, destring
	forval i =1/`r(nvars)'{
		label variable runout_cope`i' "Runout Cope #`i'"
		}
	order runout_cope1-runout_cope3, after(runout_cope)
	drop runout_cope
label define runout 0 "Purchase more from regular supplier" 1 " Top up from local dealer (not regular)" 2 "Direct customers to another agrovet" 3 " Purchase more from nearby town" 4 "Nothing" 5 "Other, specify"
label values runout_cope1-runout_cope3 runout

*need to rename credit_repay and credit_repay2 so I can split and destring*
rename credit_repay credit_repay__
rename credit_repay2 credit_repay2__

split credit_repay__, destring
	forval i =1/`r(nvars)'{
		label variable credit_repay__`i' "Credit Repay #`i'"
		}
	order credit_repay__1-credit_repay__2, after(credit_repay__)
	drop credit_repay__

split credit_repay2__, destring
	forval i =1/`r(nvars)'{
		label variable credit_repay2__`i' "Credit Repay #`i'"
		}
	order credit_repay2__1-credit_repay2__2, after(credit_repay2__)
	drop credit_repay2__
	
label define credit 0 "In cash" 1 "MPESA" 2 " In-kind with harvested grains" 99 "Other, specify"
label values credit_repay__1-credit_repay__2 credit
label values credit_repay2__1-credit_repay2__2 credit

split fert_quality_high, destring
	forval i =1/`r(nvars)'{
		label variable fert_quality_high`i' "Fert Quality High #`i'"
		}
	order fert_quality_high1-fert_quality_high6, after(fert_quality_high)
	drop fert_quality_high

split fert_quality_low, destring
	forval i =1/`r(nvars)'{
		label variable fert_quality_low`i' "Fert Quality Low#`i'"
		}
	order fert_quality_low1-fert_quality_low6, after(fert_quality_low)
	drop fert_quality_low

split owner_relationship_other, destring
	forval i =1/`r(nvars)'{
		label variable owner_relationship_other`i' "Other Survey Respondents#`i'"
		}
	order owner_relationship_other1-owner_relationship_other2, after(owner_relationship_other)
	drop owner_relationship_other
label define others 0 "Owner" 1 "Non-relative employee" 2 "Non-relative manager" 3 "Owner spouse" 4 "Owner relative" 99 "None"
label values owner_relationship_other1-owner_relationship_other2 others
 

	label variable concern_label "How big a concern for the market is…"
	note concern_label: "How big a concern for the market is…"
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

	label variable concern_label2 "How much do you agree with…"
	note concern_label2: "How much do you agree with…"
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

	label variable gpslatitude "Enumerator: Please make sure that you are right outside the agrovet.  Please rem"
	note gpslatitude: "Enumerator: Please make sure that you are right outside the agrovet.  Please remain outside while the device gets a GPS reading. (latitude)"

	label variable gpslongitude "Enumerator: Please make sure that you are right outside the agrovet.  Please rem"
	note gpslongitude: "Enumerator: Please make sure that you are right outside the agrovet.  Please remain outside while the device gets a GPS reading. (longitude)"

	label variable gpsaltitude "Enumerator: Please make sure that you are right outside the agrovet.  Please rem"
	note gpsaltitude: "Enumerator: Please make sure that you are right outside the agrovet.  Please remain outside while the device gets a GPS reading. (altitude)"

	label variable gpsaccuracy "Enumerator: Please make sure that you are right outside the agrovet.  Please rem"
	note gpsaccuracy: "Enumerator: Please make sure that you are right outside the agrovet.  Please remain outside while the device gets a GPS reading. (accuracy)"

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
 
*Generate new variable value for quality questions

gen Xqualityo = strmatch(fert_quality_higho,"I can't*")
replace fert_quality_high1 = 10 if Xqualityo == 1 & fert_quality_high1==99

gen Xqualitylowo = strmatch(fert_quality_lowo,"I can't*")
replace fert_quality_low1 = 10 if Xqualitylowo == 1 & fert_quality_low1==99


label define quality 0 "Bag weight" 1 "Condition of package" 2 "Labeling on package" 3 "Level of trust in SUPPLIER" 4"Level of trust in MANUFACTURER" 5 "Lumpy or cakey" 6 "Color" 7 "Smell" 8 "Moisture content" 9 "Customer feedback" 10 "Can't Tell Quality" 99 "Other, specify"
label values fert_quality_high1-fert_quality_high6 quality
label values fert_quality_low1-fert_quality_low6 quality
replace fert_quality_higho=" " if fert_quality_high1==10
replace fert_quality_lowo=" " if fert_quality_low1==10

*Enumerator Errors*
*fixing label for quality question and removing the "other, specify"
replace fert_quality_high1=9 if id==21
replace fert_quality_higho=" " if fert_quality_high1==9

replace fert_quality_low1=9 if id==21
replace fert_quality_lowo=" " if fert_quality_high1==9

*drop irrelevant entries*
drop submissiondate-comments

*change store ownership to individual for these stores*
replace government=1 if id==100 
replace government=1 if id==52
replace government=1 if id==134
replace government=1 if id==102
replace governmento=" " if id==100
replace governmento=" " if id==52
replace governmento=" " if id==134
replace governmento=" " if id==102


*change runout cope to nothing and remove other, specified for these stores*
replace runout_cope2=4 if id==15
replace runout_cope2=4 if id==64
replace runout_cope2=4 if id==130
replace runout_cope1=4 if id==165

replace runout_copeo=" " if id==15
replace runout_copeo=" " if id==64
replace runout_copeo=" " if id==130
replace runout_copeo=" " if id==165


*generate supplier dummy variable--1 if other stores identified store as supplying fertilizer to them*
gen supplychain = 0
replace supplychain = 1 if id==4 | id==88 | id==29 | id==50 | id==71 | id==67 | id==34 | id==103 | id==120 | id==135 | id==151 | id==133 | id==136


****************************************************************************

sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	cap: gen lat`id' = gpslatitude[`i']
}	


capture drop lon*
sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	gen lon`id' = gpslongitude[`i']
}

*******5 km*********
	gen within_5 = .
sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)189 {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <=5
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' >5
		}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_5 = tempvar-1 if id == `id'
	cap drop dist`id'_* tempvar
	}
	
	
hist within_5, percent scheme(s1mono) xtitle("Percent of stores within 5 km of another store")

*******1 km*********

	gen within_1 = .
sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)189 {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <=1
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' >1
		}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_1 = tempvar-1 if id == `id'
	drop dist`id'_* tempvar
	}
	
hist within_1, discrete percent kdensity scheme(s1mono) xtitle("Percent of stores within 1 km of another store")

hist within_1, percent kdensity scheme(s1mono) xtitle("Percent of stores within 1 km of another store")

*******3 km*********

	gen within_3 = .
sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)189 {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <=3
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' >3
		}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_3 = tempvar-1 if id == `id'
	drop dist`id'_* tempvar
	}
	
hist within_3, discrete percent kdensity scheme(s1mono) xtitle("Percent of stores within 3 km of another store")

hist within_3, percent kdensity scheme(s1mono) xtitle("Percent of stores within 3 km of another store")

*******10 km*********

	gen within_10 = .
sort id
forvalues i = 1(1)189 {
	local id = id[`i']
	cap drop tempvar
	forval j = 1(1)189 {
		local id2 = id[`j']
		cap: geodist lon`id' lat`id' lon`id2' lat`id2', gen(dist`id'_`id2')
		cap: replace dist`id'_`id2' = 1 if dist`id'_`id2' <=10
		cap: replace dist`id'_`id2' = 0 if dist`id'_`id2' >10
		}
	egen tempvar = rowtotal(dist`id'_*)
	cap: replace within_10 = tempvar-1 if id == `id'
	drop dist`id'_* tempvar
	}
	
hist within_10, discrete percent kdensity scheme(s1mono) xtitle("Percent of stores within 10 km of another store")

hist within_10, percent kdensity scheme(s1mono) xtitle("Percent of stores within 10 km of another store")


/*CUSTOMER MAX*/

hist customer_max if customer_max<100, discrete percent scheme(s2mono) xlabel(0(10)100, valuelabel) xscale(range(0 100))xtitle("Maximum Number of Customers") subtitle("Maximum Number of Customers in One Day During Peak Month")

estpost sum customer_max
esttab using Customer_Max.rtf,  replace wide label nogap nonum cells/*
*/("count mean(fmt(2)) sd(fmt(2)) min max") noobs title("Maximum Number of Customers in One Day During Peak Month")

/*CUSTOMER_AVG_PEAK*/

hist customer_avg_peak if customer_avg_peak<100, discrete percent scheme(s2mono) xlabel(0(10)100, valuelabel) xscale(range(0 100))xtitle("Average Number of Customers") subtitle("Average Number of Customers in One Day During Peak Month")

estpost sum customer_avg_peak
esttab using Customer_Avg_Peak.rtf,  replace wide label nogap nonum cells/*
*/("count mean(fmt(2)) sd(fmt(2)) min max") noobs title("Average Number of Customers in One Day During Peak Month")

/*CUSTOMER_MIN*/

hist customer_min if customer_min<20, discrete percent scheme(s2mono) xlabel(0(1)20, valuelabel) xscale(range(0 20))xtitle("Minimum Number of Customers") subtitle("Minimum Number of Customers in One Day During Worst Month")

estpost sum customer_min
esttab using Customer_Min.rtf,  replace wide label nogap nonum cells/*
*/("count mean(fmt(2)) sd(fmt(2)) min max") noobs title("Minimum Number of Customers in One Day During Worst Month")

/*CUSTOMER_AVG_SLOW*/

hist customer_avg_slow if customer_avg_slow<20, discrete percent scheme(s2mono) xlabel(0(1)20, valuelabel) xscale(range(0 20))xtitle("Average Number of Customers") subtitle("Average Number of Customers in One Day During Worst Month")

estpost sum customer_avg_slow
esttab using Customer_Avg_Slow.rtf,  replace wide label nogap nonum cells/*
*/("count mean(fmt(2)) sd(fmt(2)) min max") noobs title("Average Number of Customers in One Day During Worst Month")

/*CUSTOMER TYPE*/

estpost tab customer_type
esttab using Customer_Type.rtf, replace cell((pct(fmt(2)))) collabels(none)/*
*/ unstack nonumber mtitle("Customer Type") noobs

/*CUSTOMER CREDIT*/

estpost tab customer_credit
esttab using Customer_Credit.rtf, replace cell((pct(fmt(2)))) collabels(none)/*
*/ unstack nonumber mtitle("Customer Credit") noobs note(0=No 1=Yes)

/*CREDIT REPAY*/

estpost tab credit_repay__1
esttab using Credit_Repay1.rtf, replace cell((pct(fmt(2)))) collabels(none)/*
*/ unstack nonumber mtitle("Credit_Repay1") noobs

estpost tab credit_repay__2
esttab using Credit_Repay2.rtf, replace cell((pct(fmt(2)))) collabels(none)/*
*/ unstack nonumber mtitle("Credit_Repay2") noobs

