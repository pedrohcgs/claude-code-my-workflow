*import fertilizer questions csv--Vihiga entries manually removed*
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

*I think I added the suffix "__" because I thought I was going to reshape again?*
local bag bag_size*
foreach x of local bag{
	rename `x' =__
	}
	
save "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey-fert_questions1.dta", replace

*Import Input Survey csv--Vihiga data manually removed*
import delimited "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey.csv", clear

*rename parent_key in order to merge datasets*
rename key parent_key

*merge input survey with fertilizer questions*
merge 1:m parent_key using "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\InputSurvey-fert_questions1.dta"

sort id fert_type_id manuf_n

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

drop if current_stock==0

tab fert_type_label
tabstat price_small, by(fert_type_id) s(su)

save "D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\Mystery_Shopping_Table.dta", replace
