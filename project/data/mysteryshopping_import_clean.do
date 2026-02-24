global dir "D:/Kikis Stuff/University of Wisconsin/Year 2/Project Assistant"
cd "$dir"

*Import Mystery Shopping Data*
import delimited "$dir\data\MysteryShopping.csv", clear

*sort and reshape long*
sort id

rename sealed_bag_type bag4_type
rename sealed_bag_size bag4_size
rename sealed_bag_manuf bag4_manuf
rename sealed_bag_price bag4_price
rename sealed_bag_sizeo bag4_sizeo
rename sealed_bag_manufo bag4_manufo
rename sealed_bag_type_label bag4_type_label


	
reshape long bag@_size  bag@_sizeo bag@_type bag@_size_char bag@_manuf bag@_price bag@_negotiate bag@_size_charo bag@_manufo bag@_type_label bag@_manuf_label bag@_agitate bag@_issues bag@_issueso, i(id) j(bag_no)

drop if missing(bag_type)

*prepare for merge with label ids*
gen num=_n

save "MysteryShopping.dta", replace

*Import Label Ids*
import delimited "$dir\data\label_ids.csv", clear

merge 1:1 num using "MysteryShopping.dta", nogen
drop num

*Clean and Label Data*
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

label define manuf 0 "None" 1 "NCPB/Mkulima Bora" 2 "Mea Ltd." 3 "Athi river mining company" 4 "Elgon" 5 "Falcon" 6 "Yara (Chapa Meli)" 7 "Spring (Ruiru)" 9 "Thabiti" 99 "Other, specify"
label values bag_manuf manuf
 
label define enum 1 "Fred" 2 "Gorrety" 3 "Victor" 4 "Corazon" 5 "Hilda" 6 "Albert" 7 "Jared" 8 "Josephat"
label values enum enum

**Need to address duplicates--some ennumerators entered the sealed bag information twice
//--they counted it as a sealed bag and as a sample (as bag 1 and bag 4). This will remove one of the duplicates*
drop if label_id=="9_CAN_4" & bag_no==4
drop if label_id=="98_Urea_4" & bag_no==4
drop if label_id=="95_CAN_4" & bag_no==4
drop if label_id=="92_CAN_4" & bag_no==4
drop if label_id=="76_CAN_4" & bag_no==4
drop if label_id=="66_CAN_4" & bag_no==4
drop if label_id=="55_Urea_4" & bag_no==4
drop if label_id=="51_DAP_4" & bag_no==4
drop if label_id=="49_CAN_4" & bag_no==4
drop if label_id=="46_CAN_4" & bag_no==4
drop if label_id=="38_DAP_4" & bag_no==4
drop if label_id=="30_DAP_4" & bag_no==4
drop if label_id=="29_DAP_4" & bag_no==4
drop if label_id=="140_CAN_4" & bag_no==4
drop if label_id=="139_Urea_4" & bag_no==4
drop if label_id=="165_CAN_4" & bag_no==4

*Split and Destring Fertilize Characteristics*
split bag_issues, destring
	forval i =1/`r(nvars)'{
		label variable bag_issues`i' "Fertilizer Issues #`i'"
		}
	order bag_issues1-bag_issues3, after(bag_issues)
	drop bag_issues
label define issues 0 "None" 1 "Clumps or caking" 2 "Unusually dark" 3 "Oily film on fertilizer or bag" 4 "Foreign materials in sample" 5 "Powdered" 6 "Too wet" 7 "Too dry" 
label values bag_issues1-bag_issues3 issues


* gen var that equals 1 for each new store
bysort id: gen store_nr = _n == 1

*Total number of stores*
count if store_nr == 1

**Enumerator Errors**
*change incorrect fertilizers and manufacturers--errors caught through looking at pictures of sealed bag samples*

replace bag_manuf=5 if label_id=="30_DAP_1"
replace bag_type=1 if label_id=="40_DAP_1"
replace bag_type=1 if label_id=="101_DAP_3"

**Sealed Bag Info**
*sealed_bag is variable for whether or not a sealed bag was obtained after the app requested a sealed bag*

tab sealed_bag if store_nr==1 //indicates 53 sealed bags were requested (out of 102 stores visited)

*generate variable sealed to indicate sealed bag status regardless of whether or not sealed bag was requested*
gen sealed = bag_size < 3
label values sealed yesno

*summary stats*
tab sealed
tab bag_type
tab bag_manuf

sum bag_price if bag_size==0
sum bag_price if bag_size==1
sum bag_price if bag_size==2
sum bag_price if bag_size==3
sum bag_price if bag_size==4
sum bag_price if bag_size==5

//double check some of the bag sizes--prices don't make sense on a few

*graphs*
hist bag_type, scheme(s2mono) discrete xla(1/3, valuelabel noticks) barw(0.9) frequency

hist bag_manuf if bag_manuf< 8, discrete scheme(s2mono) xla(1/7, valuelabel noticks angle(45)) barw(0.9) frequency


*Missing Information* //this adds information about the sealed bags if they were the '4th sample'--the survey only allowed characterstics to be recorded
//for first three, so this manually adds the information. 

replace bag_size_char=0 if id==144 & bag_no==4
replace bag_negotiate=0 if id==144 & bag_no==4
replace bag_manuf_label="Other, specify" if id==144 & bag_no==4
//no bag issues recorded--check pictures to fill this in

replace bag_size_char=0 if id==59 & bag_no==4
replace bag_negotiate=0 if id==59 & bag_no==4
replace bag_manuf_label="Falcon" if id==59 & bag_no==4
//no bag issues recorded--check pictures to fill this in


replace store_name_label="Shiv Shankar Hardware" if id==77 //fixing store name to match sample
replace bag_size_char=0 if id==77 & bag_no==4
replace bag_negotiate=0 if id==77 & bag_no==4
replace bag_manuf_label="Falcon" if id==77 & bag_no==4
//no bag issues recorded--check pictures to fill this in

replace store_name_label="Rangwe farmers stores" if id==199
replace bag_size_char=0 if id==199 & bag_no==4
replace bag_negotiate=0 if id==199 & bag_no==4
replace bag_manuf_label="Spring (Ruiru)" if id==199 & bag_no==4
replace bag_issues1=0 if id==199 & bag_no==4
replace bag_issueso="DAP fertilizer" if id==199 & bag_no==2

replace bag_size_char=0 if id==183 & bag_no==4
replace bag_negotiate=0 if id==183 & bag_no==4
replace bag_manuf_label="Spring (Ruiru)" if id==183 & bag_no==4
replace bag_issues1=0 if id==183 & bag_no==4
replace bag_issueso="poor packaging" if id==183 & bag_no==4

replace bag_size_char=0 if id==148 & bag_no==4
replace bag_negotiate=0 if id==148 & bag_no==4
replace bag_manuf_label="Falcon" if id==148 & bag_no==4
replace bag_issues1=5 if id==148 & bag_no==4

replace store_name_label="God mony Hardware" if id==187

replace bag_size_char=0 if id==135 & bag_no==4
replace bag_negotiate=0 if id==135 & bag_no==4
replace bag_manuf_label="Yara (Chapa Meli)" if id==135 & bag_no==4
replace bag_issues1=0 if id==135 & bag_no==4

replace store_name_label="Imbo Agrovet" if id==189

replace store_name_label="Wakulima Stores" if id==188

replace bag_size_char=0 if id==141 & bag_no==4
replace bag_negotiate=0 if id==141 & bag_no==4
replace bag_manuf_label="Falcon" if id==141 & bag_no==4
replace bag_issues1=5 if id==141 & bag_no==4

replace bag_issueso="Not properly sealed" if id==136 & bag_no==1

replace bag_size_char=0 if id==1 & bag_no==4
replace bag_size_char=0 if id==2 & bag_no==4
replace bag_size_char=0 if id==4 & bag_no==4
replace bag_size_char=0 if id==10 & bag_no==4
replace bag_size_char=0 if id==15 & bag_no==4
replace bag_size_char=0 if id==19 & bag_no==4
replace bag_size_char=0 if id==26 & bag_no==4
replace bag_size_char=0 if id==31 & bag_no==4
replace bag_size_char=0 if id==32 & bag_no==4
replace bag_size_char=0 if id==34 & bag_no==4
replace bag_size_char=0 if id==44 & bag_no==4
replace bag_size_char=0 if id==47 & bag_no==4
replace bag_size_char=0 if id==74 & bag_no==4
replace bag_size_char=0 if id==88 & bag_no==4
replace bag_size_char=0 if id==100 & bag_no==4
replace bag_size_char=0 if id==101 & bag_no==4
replace bag_size_char=0 if id==108 & bag_no==4
replace bag_size_char=0 if id==120 & bag_no==4
replace bag_size_char=0 if id==147 & bag_no==4

replace bag_negotiate=0 if id==1 & bag_no==4
replace bag_negotiate=0 if id==2 & bag_no==4
replace bag_negotiate=0 if id==4 & bag_no==4
replace bag_negotiate=0 if id==10 & bag_no==4
replace bag_negotiate=0 if id==15 & bag_no==4
replace bag_negotiate=0 if id==19 & bag_no==4
replace bag_negotiate=0 if id==26 & bag_no==4
replace bag_negotiate=0 if id==31 & bag_no==4
replace bag_negotiate=0 if id==32 & bag_no==4
replace bag_negotiate=0 if id==34 & bag_no==4
replace bag_negotiate=0 if id==44 & bag_no==4
replace bag_negotiate=0 if id==47 & bag_no==4
replace bag_negotiate=0 if id==74 & bag_no==4
replace bag_negotiate=0 if id==88 & bag_no==4
replace bag_negotiate=0 if id==100 & bag_no==4
replace bag_negotiate=0 if id==101 & bag_no==4
replace bag_negotiate=0 if id==108 & bag_no==4
replace bag_negotiate=0 if id==120 & bag_no==4
replace bag_negotiate=0 if id==147 & bag_no==4

replace bag_manuf_label="Falcon" if id==1 & bag_no==4
replace bag_manuf_label="Yara (Chapa Meli)"  if id==2 & bag_no==4
replace bag_manuf_label="Yara (Chapa Meli)"  if id==4 & bag_no==4
replace bag_manuf_label="Falcon" if id==10 & bag_no==4
replace bag_manuf_label="Falcon"  if id==15 & bag_no==4
replace bag_manuf_label="Yara (Chapa Meli)"  if id==19 & bag_no==4
replace bag_manuf_label="Falcon"  if id==26 & bag_no==4
replace bag_manuf_label="Falcon"  if id==31 & bag_no==4
replace bag_manuf_label="Falcon"  if id==32 & bag_no==4
replace bag_manuf_label="Falcon"  if id==34 & bag_no==4
replace bag_manuf_label="Falcon"  if id==44 & bag_no==4
replace bag_manuf_label="Falcon" if id==47 & bag_no==4
replace bag_manuf_label="Falcon"  if id==74 & bag_no==4
replace bag_manuf_label="Falcon"  if id==88 & bag_no==4
replace bag_manuf_label="Thabiti"  if id==100 & bag_no==4
replace bag_manuf_label="Spring (Ruiru)" if id==101 & bag_no==4
replace bag_manuf_label="Falcon"  if id==108 & bag_no==4
replace bag_manuf_label="Falcon"  if id==120 & bag_no==4
replace bag_manuf_label="Falcon"  if id==147 & bag_no==4

**these bag issues are recorded by PA from photos of samples**
replace bag_issues1=1 if id==1 & bag_no==4
replace bag_issues2=5 if id==1 & bag_no==4

replace bag_issues1=0 if id==2 & bag_no==4

replace bag_issues1=0 if id==4 & bag_no==4

replace bag_issues1=1 if id==10 & bag_no==4
replace bag_issues2=5 if id==10 & bag_no==4

replace bag_issues1=1 if id==15 & bag_no==4

replace bag_issues1=0 if id==19 & bag_no==4

replace bag_issues1=1 if id==26 & bag_no==4
replace bag_issues2=5 if id==26 & bag_no==4

replace bag_issues1=0 if id==31 & bag_no==4
replace bag_issues1=0 if id==32 & bag_no==4

replace bag_issues1=1 if id==34 & bag_no==4

replace bag_issues1=0 if id==44 & bag_no==4

replace bag_issues1=1 if id==47 & bag_no==4

replace bag_issues1=1 if id==59 & bag_no==4
replace bag_issues2=5 if id==59 & bag_no==4

replace bag_issues1=1 if id==74 & bag_no==4

replace bag_issues1=1 if id==77 & bag_no==4
replace bag_issues2=5 if id==77 & bag_no==4

replace bag_issues1=1 if id==88 & bag_no==4

replace bag_issues1=1 if id==100 & bag_no==4

replace bag_issues1=0 if id==101 & bag_no==4

replace bag_issues1=4 if id==108 & bag_no==4
replace bag_issueso="Stones" if id==108 & bag_no==4

replace bag_issues1=0 if id==120 & bag_no==4

replace bag_issues1=0 if id==135 & bag_no==4

replace bag_issues1=0 if id==141 & bag_no==4

replace bag_issues1=0 if id==144 & bag_no==4

replace bag_issues1=0 if id==147 & bag_no==4  //hard time telling if it's too dark because of lighting

replace bag_issues1=0 if id==148 & bag_no==4


save "MysteryShopping_clean.dta", replace




