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







