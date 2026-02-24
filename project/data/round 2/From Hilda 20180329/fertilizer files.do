clear all

global dir "D:\HSK\UMATI\Fertilizer_work\March_2018"
cd "$dir"

*import fertilizer questions csv--excludes Vihiga data*
insheet using "$dir\MysteryShopping_second.csv",clear

label variable id "shop id"
label variable store_name_label "name of store"

label variable enum "name of enumerator" 
label define enum 1"Fredrick"6"Albert"7"Jared"8"Josephat"
label values enum enum

label variable sealed_bag "was enumerator able to buy sealed bag"
replace sealed_bag=31 if sealed_bag==.
label define sealed_bag 0"No"1"Yes"31"Not required"
label values sealed_bag sealed_bag

label variable sealed_bag_type "type of fertilizer for sealed bag"
label define sealed_bag_type 1"DAP"2"CAN"3"Urea"
label values sealed_bag_type sealed_bag_type

label variable sealed_bag_size "size for sealed bag" 
label define sealed_bag_size 1"50kg"2"25kg"3"10kg"4"5kg"5"2kg"6"1kg"99"Other (specify)"
label values sealed_bag_size sealed_bag_size

label variable sealed_bag_manuf "manufacturer for sealed bag" 
label define sealed_bag_manuf 0"None"1"NCPB/Mkulima Bora"2"Mea Ltd"3"Athi river mining company"4"Elgon"5"Falcon"6"Yara (Chapa Meli)"7"Spring"8"Thabiti"9"Mavuno"99"Other (specify)"
label values sealed_bag_manuf sealed_bag_manuf

label variable sealed_bag_price "price of sealed bag" 
label variable select_bag_negotiate "was price of sealed bag negotiable"
label define select_bag_negotiate 0"No"1"Yes"
label values select_bag_negotiate select_bag_negotiate
 
label variable sealed_bag_sizeo "other size for sealed bag" 
label variable sealed_bag_manufo "other manufacturer for sealed bag" 
label variable sealed_bag_type_label "sealed bag label"

*sample 1
label variable sample_number "how many samples shopper obtained" 
label variable bag1_type "type of fertilizer for sample1"
label define bag1_type 1"DAP"2"CAN"3"Urea"
label values bag1_type bag1_type

label variable bag1_size "size of sample1"
label define bag1_size 1"50kg"2"25kg"3"10kg"4"5kg"5"2kg"6"1kg"99"Other (specify)"
label values bag1_size bag1_size
 
label variable bag1_size_char "type of packaging for sample1"
label define bag1_size_char 1"Sealed manufacturer bag"2"Scooped from an open sealed bag"3"repackaged by the seller"99"Other (specify)"
label values bag1_size_char bag1_size_char
 
label variable bag1_manuf "which manufacturer for sample1"
label define bag1_manuf 0"None"1"NCPB/Mkulima Bora"2"Mea Ltd"3"Athi river mining company"4"Elgon"5"Falcon"6"Yara (Chapa Meli)"7"Spring"8"Thabiti"9"Mavuno"99"Other (specify)"
label values bag1_manuf bag1_manuf
 
label variable bag1_price "price of sample1"
 
label variable bag1_negotiate "was price of sample1 negotiable"
label define bag1_negotiate 0"No"1"Yes"
label values bag1_negotiate bag1_negotiate

label variable bag1_size_charo "other type of packaging for sample1" 
label variable bag1_manufo "other manufacturer for sample1" 
label variable bag1_agitate "seller agitated bag before scooping sample1" 
label define bag1_agitate 0"No"1"Yes"31"Don't know"
label values bag1_agitate bag1_agitate

label variable bag1_type_label "sample1 label" 
label variable bag1_manuf_label "sample1 manufacturer label"

label variable bag1_issues "observations made for sample1"
label variable bag1_issues_0 "no issues for sample1"
label variable bag1_issues_1 "clumps or caking - sample1" 
label variable bag1_issues_2 "unusually dark - sample1" 
label variable bag1_issues_3 "oily film on fertilizer or bag for sample1" 
label variable bag1_issues_4 "foreign materials in sample1"
label variable bag1_issues_5 "powdered - sample1"  
label variable bag1_issues_6 "too wet - sample1" 
label variable bag1_issues_7 "too dry - sample1" 
label variable bag1_issueso "other specific issues - sample1"

foreach x of varlist bag1_issues_0-bag1_issues_7{
   
   label define `x' 1"Yes"0"No"
   label values `x' `x'
}
	

*sample 2
label variable bag2_type "type of fertilizer for sample2" 
label define bag2_type 1"DAP"2"CAN"3"Urea"
label values bag2_type bag2_type

label variable bag2_size "size of sample2" 
label define bag2_size 1"50kg"2"25kg"3"10kg"4"5kg"5"2kg"6"1kg"99"Other (specify)"
label values bag2_size bag2_size

label variable bag2_size_char "type of packaging for sample2" 
label define bag2_size_char 1"Sealed manufacturer bag"2"Scooped from an open sealed bag"3"repackaged by the seller"99"Other (specify)"
label values bag2_size_char bag2_size_char

label variable bag2_manuf "which manufacturer for sample2" 
label define bag2_manuf 0"None"1"NCPB/Mkulima Bora"2"Mea Ltd"3"Athi river mining company"4"Elgon"5"Falcon"6"Yara (Chapa Meli)"7"Spring"8"Thabiti"9"Mavuno"99"Other (specify)"
label values bag2_manuf bag2_manuf

label variable bag2_price "price of sample2" 
label variable bag2_negotiate "was price of sample2 negotiable" 
label define bag2_negotiate 0"No"1"Yes"
label values bag2_negotiate bag2_negotiate

label variable bag2_size_charo "other type of packaging for sample2" 
label variable bag2_manufo "other manufacturer for sample2" 
label variable bag2_agitate "seller agitated bag before scooping sample2"
label define bag2_agitate 0"No"1"Yes"31"Don't know"
label values bag2_agitate bag2_agitate
 
label variable bag2_type_label "sample2 label" 
label variable bag2_manuf_label "sample2 manufacturer label"

label variable bag2_issues "observations made for sample2"
label variable bag2_issues_0 "no issues for sample2"
label variable bag2_issues_1 "clumps or caking - sample2" 
label variable bag2_issues_2 "unusually dark - sample2" 
label variable bag2_issues_3 "oily film on fertilizer or bag for sample2" 
label variable bag2_issues_4 "foreign materials in sample2"
label variable bag2_issues_5 "powdered - sample2"  
label variable bag2_issues_6 "too wet - sample2" 
label variable bag2_issues_7 "too dry - sample2" 
label variable bag2_issueso "other specific issues - sample2"

foreach x of varlist bag2_issues_0-bag2_issues_7{
   
   label define `x' 1"Yes"0"No"
   label values `x' `x'
}



*sample 3
label variable bag3_type "type of fertilizer for sample3"
label define bag3_type 1"DAP"2"CAN"3"Urea"
label values bag3_type bag3_type
 
label variable bag3_size "size of sample3"
label define bag3_size 1"50kg"2"25kg"3"10kg"4"5kg"5"2kg"6"1kg"99"Other (specify)"
label values bag3_size bag3_size
 
label variable bag3_size_char "type of packaging for sample3"
label define bag3_size_char 1"Sealed manufacturer bag"2"Scooped from an open sealed bag"3"repackaged by the seller"99"Other (specify)"
label values bag3_size_char bag3_size_char
 
label variable bag3_manuf "which manufacturer for sample3"
label define bag3_manuf 0"None"1"NCPB/Mkulima Bora"2"Mea Ltd"3"Athi river mining company"4"Elgon"5"Falcon"6"Yara (Chapa Meli)"7"Spring"8"Thabiti"9"Mavuno"99"Other (specify)"
label values bag3_manuf bag3_manuf
 
label variable bag3_price "price of sample3" 
label variable bag3_negotiate "was price of sample3 negotiable"
label define bag3_negotiate 0"No"1"Yes"
label values bag3_negotiate bag3_negotiate
 
label variable bag3_size_charo "other type of packaging for sample3" 
label variable bag3_manufo "other manufacturer for sample3" 
label variable bag3_agitate "seller agitated bag before scooping sample3"
label define bag3_agitate 0"No"1"Yes"31"Don't know"
label values bag3_agitate bag3_agitate
 
label variable bag3_type_label "sample3 label" 
label variable bag3_manuf_label "sample3 manufacturer label"

label variable bag3_issues "observations made for sample3"
label variable bag3_issues_0 "no issues for sample3"
label variable bag3_issues_1 "clumps or caking - sample3" 
label variable bag3_issues_2 "unusually dark - sample3" 
label variable bag3_issues_3 "oily film on fertilizer or bag for sample3" 
label variable bag3_issues_4 "foreign materials in sample3"
label variable bag3_issues_5 "powdered - sample3"  
label variable bag3_issues_6 "too wet - sample3" 
label variable bag3_issues_7 "too dry - sample3" 
label variable bag3_issueso "other specific issues - sample3"

foreach x of varlist bag3_issues_0-bag3_issues_7{
   
   label define `x' 1"Yes"0"No"
   label values `x' `x'
}
	
*calculate number of samples obtained:
sum sample_number
display r(sum)
count if sealed_bag==1

list id store_name_label sealed_bag_type_label sealed_bag_size sealed_bag_manuf if sealed_bag==1&sealed_bag_type_label!=""

stop
**Reshaping file

*create generic ID for reshaping*
gen case_id = _n
order case_id, first

*renaming variables for the reshape*

rename bag1_type bag_type1
rename bag1_size bag_size1
rename bag1_size_char bag_size_char1
rename bag1_manuf bag_manuf1
rename bag1_price bag_price1
rename bag1_negotiate bag_negotiate1
rename bag1_size_charo bag_size_charo1
rename bag1_manufo bag_manufo1 
rename bag1_agitate bag_agitate1
rename bag1_type_label bag_type_label1
rename bag1_manuf_label bag_manuf_label1
rename bag1_issues bag_issues_1
rename bag1_issues_0 bag_issues0_1
rename bag1_issues_1 bag_issues1_1
rename bag1_issues_2 bag_issues2_1
rename bag1_issues_3 bag_issues3_1
rename bag1_issues_4 bag_issues4_1
rename bag1_issues_5 bag_issues5_1
rename bag1_issues_6 bag_issues6_1
rename bag1_issues_7 bag_issues7_1
rename bag1_issueso bag_issues_oth_1

rename bag2_type bag_type2
rename bag2_size bag_size2
rename bag2_size_char bag_size_char2
rename bag2_manuf bag_manuf2
rename bag2_price bag_price2
rename bag2_negotiate bag_negotiate2
rename bag2_size_charo bag_size_charo2
rename bag2_manufo bag_manufo2 
rename bag2_agitate bag_agitate2
rename bag2_type_label bag_type_label2
rename bag2_manuf_label bag_manuf_label2
rename bag2_issues bag_issues_2
rename bag2_issues_0 bag_issues0_2
rename bag2_issues_1 bag_issues1_2
rename bag2_issues_2 bag_issues2_2
rename bag2_issues_3 bag_issues3_2
rename bag2_issues_4 bag_issues4_2
rename bag2_issues_5 bag_issues5_2
rename bag2_issues_6 bag_issues6_2
rename bag2_issues_7 bag_issues7_2
rename bag2_issueso bag_issues_oth_2

rename bag3_type bag_type3
rename bag3_size bag_size3
rename bag3_size_char bag_size_char3
rename bag3_manuf bag_manuf3
rename bag3_price bag_price3
rename bag3_negotiate bag_negotiate3
rename bag3_size_charo bag_size_charo3
rename bag3_manufo bag_manufo3 
rename bag3_agitate bag_agitate3
rename bag3_type_label bag_type_label3
rename bag3_manuf_label bag_manuf_label3
rename bag3_issues bag_issues_3
rename bag3_issues_0 bag_issues0_3
rename bag3_issues_1 bag_issues1_3
rename bag3_issues_2 bag_issues2_3
rename bag3_issues_3 bag_issues3_3
rename bag3_issues_4 bag_issues4_3
rename bag3_issues_5 bag_issues5_3
rename bag3_issues_6 bag_issues6_3
rename bag3_issues_7 bag_issues7_3
rename bag3_issueso bag_issues_oth_3

*reshape data into long format*
reshape long bag_type bag_size bag_size_char bag_manuf bag_price bag_negotiate bag_size_charo bag_manufo bag_agitate bag_type_label bag_manuf_label bag_issues bag_issues0 bag_issues1 bag_issues2 bag_issues3 bag_issues4 bag_issues5 bag_issues6 bag_issues7 bag_issueso, i(case_id id enum store_name_label) j(jrow)

*dropping observations without fertilizer data
drop if missing(bag_type)&sample_number==1
drop if missing(bag_type)&sample_number==2

list id store_name_label bag_type bag_size bag_manuf
stop


*split and destring bag size variables*
split bag_size, destring
	forval i =1/`r(nvars)'{
		label variable bag_size`i' "Bag Size #`i'"
		}
	drop bag_size

ssave "MysteryShopping_second.dta", replace

*Import Input Survey csv--excludes Vihiga data*
import delimited "$dir\data\InputSurvey.csv", rowrange(5:) clear

*rename parent_key in order to merge datasets*
rename key parent_key

*merge input survey with fertilizer questions*
merge 1:m parent_key using "InputSurvey-fert_questions1.dta"
//D:\Kikis Stuff\University of Wisconsin\Year 2\Project Assistant\data\
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
keep id county store_name enum formdef_version fert_type_id fert_type_label current_stock manuf_n manuf_number manufacturer manufacturero manuf_name price purchase_unit_large price_small purchase_unit bag_size* gpslatitude gpslongitude

*add new value for manufacturer Spring
gen Xspring = strmatch(manufacturero,"Spring*")
replace manufacturer = 7 if Xspring == 1 & manufacturer == 99

gen Xthabiti = strmatch(manufacturero,"*Thabiti*")
replace manufacturer = 9 if Xthabiti == 1 & manufacturer == 99

gen Xmavuno = strmatch(manufacturero,"*Mavuno*")
replace manufacturer = 10 if Xmavuno == 1 & manufacturer == 99

gen Xruiru = strmatch(manufacturero,"*Ruiru*")
replace manufacturer = 11 if Xruiru == 1 & manufacturer == 99

//label define purchase_unit 0 "50 kg" 1 "25 kg" 2 "10 kg" 3 "5 kg" 4 "2 kg" 5 "1 kg"
** Need to figure out what the purchase_unit numbers actually mean..., some of the entries have 6 and 7?

*Dropping fertilizers not currently in stock* 
//drop if current_stock==0

*drop stores that don't plan to stock again*
drop if id==25 //was wondering why ID 25 had blanks for fertilizer and manufacturers--they don't plan to stock again

*drop string variables*
drop fert_type_label manuf_name

order formdef_version, last

**label enumerators**
label define enum 1 "Fred" 2 "Gorrety" 3 "Victor" 4 "Corazon" 5 "Hilda" 6 "Albert" 7 "Jared" 8 "Josephat"
label values enum enum

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
