global dir "D:/Kikis Stuff/University of Wisconsin/Year 2/Project Assistant"
cd "$dir"

use "manufacturer_fertilizer.dta", clear

* gen var that equals 1 for each new store
bysort id: gen store_nr = _n == 1

*Total number of stores*
count if store_nr == 1

* tabulate the number of fertilizer types stores have
tab fert_number_total if number ==1
sum fert_number_total if number ==1
//differentiate by county
tab fert_number_total county if number==1

* tabulate the types of fertilizers that they have
tab fert_type_id if fert_number == 1


* tabulate the number of manufacturers for all fertilizers
tab manuf_number if fert_number == 1

*tabulate manufacturer types for all fertilizer
tab manufacturer if fert_number ==1

*tabulate the stores that sell fertilizer every month
tab fertsales if store_nr==1

*tab number of stores surveyed from each county
tab county if store_nr==1
//fertilizer types by county
tab fert_type_id county if fert_number==1

*tab business type for each store
tab business_type if store_nr==1

*tab facility type for each store
tab facility_type if store_nr==1

*tab store ownership
tab government if store_nr==1

*Supply issues--do stores runout of supply
tab runout if store_nr==1

*tab store concerns
tab concern1 if store_nr==1
tab concern2 if store_nr==1
tab concern3 if store_nr==1
tab concern4 if store_nr==1
tab concern5 if store_nr==1
tab concern6 if store_nr==1
tab concern7 if store_nr==1
tab concern8 if store_nr==1
tab concern9 if store_nr==1
tab concern10 if store_nr==1

*tab fertilizers indicated currently in stock*
tab current_stock if fert_number==1

*graphs*
hist fert_type_id if fert_number==1 & fert_type_id < 7, scheme(s2mono) discrete xla(0/5, valuelabel noticks) barw(0.9) percent

hist manufacturer if fert_number == 1 & manufacturer < 8, discrete scheme(s2mono) discrete xla(1/7, valuelabel noticks angle(45)) barw(0.9) percent

*do more established stores know higher number of stores?
twoway scatter other_stores_nr business_age  || lfit other_stores_nr business_age
