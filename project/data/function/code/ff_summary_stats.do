* Project: Fake fertilizer
* When: Aug 2018
* Stata v.15.1

* ********** general setup
* global dir "C:\Users\Emilia\Dropbox\Fake fertilizer\PEDL\data"
cd "$dir"
* **********

* assumes
	* geodist
	
log using "$dir/build/output/ff_summary_stats", replace

use "$dir/build/output/mystery_addvars.dta", clear


* generate variable for successful purchase
gen purchase_success = (!mi(total_nitrogen))
	lab var purchase_success "Completed purchase in at least one round"
bysort id: egen purchases = total(purchase_success)
	lab var purchases "Number of samples purchased from store"
	
bysort id: gen number = _n
bysort id round: gen numberround = _n

tab education, gen(e)
rename e1 primary
	lab var primary "Education: primary"
rename e2 secondary 
	lab var secondary "Education: secondary"
rename e3 trade
	lab var trade "Education: trade"
rename e4 diploma
	lab var diploma "Education: diploma"
rename e5 university
	lab var university "Education: university"

lab var customer_max "Max. customers in a day"
lab var customer_min "Min. customers in a day"
lab var customer_avg_peak "Average customers, peak season"
lab var customer_avg_slow "Average customers, slow season"
lab var business_age "Business years in operation"
lab var gender "Female"
lab var age "Respondent age"
lab var facility_type "Ag inputs is main activity"
lab var bus_typeD "Permanent store (not seasonal)"
lab var chain "Owner owns multiple agrovets"


tab county, gen(c)
rename c1 homabay
	lab var homabay "Homa Bay"
rename c2 migori
	lab var migori "Migori"

* bysort id round: egen purchases_round = total(purchase_success)

* histogram of number of purchases from each store
hist purchases if number == 1, freq xtitle("Number of samples obtained from agrodealers") scheme(plotplain)
graph export "$dir/function/output/purchases.png", replace


global balvar1 migori homabay facility_type bus_typeD chain gender age primary secondary trade diploma university cellphone smartphone computer vehicle truck motorbike business_age no_months_sale customer_max customer_min customer_avg_peak customer_avg_slow fert_store_kg 

eststo clear 
estpost summarize $balvar1 if number == 1
esttab using "$dir/function/output/summary_stats.tex", cells("count(fmt(a2)) mean(fmt(a2)) sd(fmt(a2)) min(fmt(a2)) max(fmt(a2))") noobs replace nonumber starlevels(* .1 ** .05 *** .01)  label title("Summary statistics")

copy "$dir/function/output/summary_stats.tex" "C:\Users\Emilia\Dropbox\Apps\Overleaf/Fake fertilizer/Tables/summary_stats.tex", replace

hist percent if numberround==1 & round==1, by(bag_type) scheme(plotplain) freq 
hist percent if bag_type==1 & flag==0, by(round, note("") title("Fertilizer quality by round")) scheme(plotplain) freq xtitle("Percent of expected Nitrogen, DAP") 
graph export "$dir/function/output/hist_dap.png", replace
hist percent if bag_type==2 & flag==0, by(round, note("") title("Fertilizer quality by round")) scheme(plotplain) freq xtitle("Percent of expected Nitrogen, CAN") 
graph export "$dir/function/output/hist_can.png", replace
hist percent if bag_type==3 & flag==0, by(round, note("") title("Fertilizer quality by round")) scheme(plotplain) freq xtitle("Percent of expected Nitrogen, Urea")
graph export "$dir/function/output/hist_urea.png", replace

hist percent if bag_type == 2, by(bag_manuf, note("") title("Fertilizer quality by manufacturer")) scheme(plotplain) xline(0) freq xtitle("Percent of expected Nitrogen, CAN")
graph export "$dir/function/output/hist_can_manuf.png", replace

gen clumps = .
gen dark = .
gen oily = .
gen foreign = .
gen powdered = .
gen wet = .
gen dry = .

lab var clumps "Clumps/caking"
lab var dark "Unusually dark"
lab var oily "Oily film"
lab var foreign "Foreign materials"
lab var powdered "Powdered"
lab var wet "Too wet"
lab var dry "Too dry"
	
forval i = 1/3 {
	replace clumps = 1 if bag_issues`i' == 1
	replace dark = 1 if bag_issues`i' == 2
	replace oily = 1 if bag_issues`i' == 3
	replace foreign = 1 if bag_issues`i' == 4
	replace powdered = 1 if bag_issues`i' == 5
	replace wet = 1 if bag_issues`i' == 6
	replace dry = 1 if bag_issues`i' == 7
	}
replace clumps = 0 if mi(clumps)
replace dark = 0 if mi(dark)
replace oily = 0 if mi(oily)
replace foreign = 0 if mi(foreign)
replace powdered = 0 if mi(powdered)
replace wet = 0 if mi(wet)
replace dry = 0 if mi(dry)



















