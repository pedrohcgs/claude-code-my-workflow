*import fertilizer questions csv--Vihiga entries manually removed*
//import delimited csvfile, rowrange(5:)
import delimited "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey-fert_questions.csv", clear

*create generic ID for reshaping*
gen case_id = _n
order case_id, first

*add suffix "1" to variables for the reshape*
local manuf manufacturer manufacturero purchase_unit_large price cost price_small purchase_unit

foreach x of local manuf{
	rename `x' `x'1
	}
	
*reshape data into long format*
reshape long manufacturer manufacturero manuf_name purchase_unit_large price cost price_small purchase_unit, i(case_id fert_position fert_type_id fert_type_label) j(manuf_n)

drop if missing(manufacturer)

*split and destring bag size variables*
split bag_size, destring
	forval i =1/`r(nvars)'{
		label variable bag_size`i' "Bag Size #`i'"
		}
	drop bag_size

save "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey-fert_questions1.dta", replace

*Import Input Survey csv--Vihiga data manually removed*
import delimited "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey.csv", clear

*rename parent_key in order to merge datasets*
rename key parent_key

*merge input survey with fertilizer questions*
merge 1:m parent_key using "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey-fert_questions1.dta"

sort id fert_type_id manuf_n

*Add labels to variables and values*
label define manufacturer 0 "None" 1 "NCPB/Mkulima Bora" 2 "Mea Ltd." 3 "Athi river mining company" 4 "Elgon" 5 "Falcon" 6 "Yara (Chapa Meli)" 7 "Spring" 99 "Other, specify"
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

label define current_stock 0 "No" 1 "Yes"
label values current_stock current_stock

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
label variable manuf_n "Manufacturer ID (within fertilizer type)" //does this label even make sense?!
label variable manuf_name "Manufacturer Name"
label variable county "County"

*Needed to rename the Manufacturers because of the prior survey that autopopulated the third manufacturer with the second manufacturer name*
replace manuf_name="None" if manufacturer==0
replace manuf_name="NCPB/Mkulima Bora" if manufacturer==1
replace manuf_name="Mea Ltd." if manufacturer==2
replace manuf_name="Athi river mining company" if manufacturer==3
replace manuf_name="Elgon" if manufacturer==4
replace manuf_name="Falcon" if manufacturer==5
replace manuf_name="Yara (Chapa Meli)" if manufacturer==6
replace manuf_name="Other, Specify" if manufacturer==99

*Dropping everything not relevant to mystery shopping table*
keep id county store_name formdef_version fert_type_id fert_type_label current_stock manuf_n manuf_number manufacturer manufacturero manuf_name price purchase_unit_large price_small purchase_unit bag_size*

*add new value for manufacturer Spring
gen Xspring = strmatch(manufacturero,"Spring*")
replace manufacturer = 7 if Xspring == 1 & manufacturer == 99



//label define purchase_unit 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg"
** Need to figure out what the purchase_unit numbers actually mean..., some of the entries have 6 and 7?

*Dropping fertilizers not currently in stock* 
drop if current_stock==0

*drop stores that don't plan to stock again*
drop if id==25 //was wondering why ID 25 had blanks for fertilizer and manufacturers--they don't plan to stock again


tab fert_type_label
tabstat price_small, by(fert_type_id) s(su)

save "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\Mystery_Shopping_Table.dta", replace
