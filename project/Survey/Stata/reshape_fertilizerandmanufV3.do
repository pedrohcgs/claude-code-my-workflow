 global dir "C:\Users\Emilia\Dropbox\Red tape\Madison\apps\Kohl\PEDL\Survey"
 cd "$dir"

* global dir "D:/Kikis Stuff/University of Wisconsin/Year 2/Project Assistant/data/Stata"
* cd "$dir"

*import fertilizer questions csv--excludes Vihiga data*
import delimited "$dir\Stata\InputSurvey-fert_questions.csv", rowrange(13:) clear

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

save "$dir\Stata\InputSurvey-fert_questions1.dta", replace

*Import Input Survey csv--excludes Vihiga data*
import delimited "$dir\Stata\InputSurvey.csv", rowrange(5:) clear

*rename parent_key in order to merge datasets*
rename key parent_key

*merge input survey with fertilizer questions*
merge 1:m parent_key using "$dir\Stata\InputSurvey-fert_questions1.dta"
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

label define yesno 0 "No" 1 "Yes"
label values current_stock yesno

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
gen Xruiru = strmatch(manufacturero,"*Ruiru*")
replace manufacturer = 7 if Xspring == 1 & manufacturer == 99
replace manufacturer = 7 if Xruiru == 1 & manufacturer == 99

gen Xthabiti = strmatch(manufacturero,"*Thabiti*")
replace manufacturer = 9 if Xthabiti == 1 & manufacturer == 99

gen Xmavuno = strmatch(manufacturero,"*Mavuno*")
replace manufacturer = 10 if Xmavuno == 1 & manufacturer == 99

//label define purchase_unit 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg"
** Need to figure out what the purchase_unit numbers actually mean..., some of the entries have 6 and 7?

*Dropping fertilizers not currently in stock* 
drop if current_stock==0

*drop stores that don't plan to stock again*
drop if id==25 //was wondering why ID 25 had blanks for fertilizer and manufacturers--they don't plan to stock again

*drop string variables*
drop fert_type_label manuf_name

order formdef_version, last


***
bysort id: gen number = _n
tab manuf_number if number == 1
sum manuf_number if number == 1

label variable number "Number of fertilizers by manufacturer within a store"

* gen var that equals 1 for each new fertilizer type
bysort id fert_type_id: gen fert_number = _n == 1
* make another variable with the running sum (within store ID)
bysort id: gen fert_number_total = sum(fert_number)
* replace this with the highest number (i.e. the number of fertilizers that the store currently carries)
bysort id: replace fert_number_total = fert_number_total[_N] 

label variable fert_number "Indicates '1' for each new fertilizer type"
label variable fert_number_total "Number of fertilizers the store current carries"

* tabulate the number of fertilizer types stores have
tab fert_number_total if number ==1
sum fert_number_total if number ==1

* tabulate the types of fertilizers that they have
tab fert_type_id if fert_number == 1

* tabulate the number of manufacturers for all fertilizers
tab manuf_number if fert_number == 1
sum manuf_number if fert_number == 1

* make a variable indicating if the store sells the various bag sizes
gen bagsizeany = (bag_size1==4) + (bag_size2==4) + (bag_size3==4) + (bag_size4==4) + (bag_size5==4)
gen bagsize2 = (bag_size1==3) + (bag_size2==3) + (bag_size3==3) + (bag_size4==3) + (bag_size5==3)
gen bagsize10 = (bag_size1==2) + (bag_size2==2) + (bag_size3==2) + (bag_size4==2) + (bag_size5==2)
gen bagsize25 = (bag_size1==1) + (bag_size2==1) + (bag_size3==1) + (bag_size4==1) + (bag_size5==1)

label variable bagsizeany "Indicates if store sells any bag size of the fertilizer type"
label variable bagsize2 "Indicates if store sells 2 kg bags of fertilizer type"
label variable bagsize10 "Indicates if store sells 10 kg bags of fertilizer type"
label variable bagsize25 "Indicates if store sells 25 kg bags of fertilizer type"

* tabulate the different fertilizers and whether they are sold in "anysize" bags
tab fert_type_id if fert_number ==1, sum(bagsizeany)

* generate vars for whether or not the store sells a certain fertilizer type:
gen dap = 1 if fert_type_id == 1
bysort id: egen Xdap = total(dap)
replace dap = 1 if Xdap > 0
replace dap = 0 if Xdap == 0
* count if they do not sell this fertilizer (and number ==1 to avoid doublecounting)
count if dap == 0 & number ==1

label variable dap "Indicates if store sells DAP fertilizer"
label variable Xdap "Sums total number of DAP manufacturers sold within store"

gen can = 1 if fert_type_id == 2
bysort id: egen Xcan = total(can)
replace can = 1 if Xcan > 0
replace can = 0 if Xcan == 0
* count if they do not sell this fertilizer (and number ==1 to avoid doublecounting)
count if can == 0 & number ==1

label variable can "Indicates of store sells CAN fertilizer"
label variable Xcan "Sums total number of CAN manufacturers sold within store"

gen urea = 1 if fert_type_id == 3
bysort id: egen Xurea = total(urea)
replace urea = 1 if Xurea > 0
replace urea = 0 if Xurea == 0
* count if they do not sell this fertilizer (and number ==1 to avoid doublecounting)
count if urea == 0 & number ==1

label variable urea "Indicates if store sells Urea fertilizer"
label variable Xurea "Sums total number of Urea manufacturers sold within store"

save "Mystery_Shopping_Table.dta", replace
