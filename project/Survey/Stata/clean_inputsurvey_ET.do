**Use data imported from SurveyCTO Stata do file**

* global dir "C:\Users\Emilia\Dropbox\Red tape\Madison\apps\Kohl\PEDL\Survey"
* cd "$dir"

use "D:/Kikis Stuff/University of Wisconsin/Year 2/Project Assistant/data/Stata/InputSurvey.dta", clear



**drop Vihiga samples and that version of survey**
drop if today__1=="2017-06-15"
drop biz_nr-other_store_subcounty__2


	
**reshape data long on supplier**
reshape long fertilizer_type__ supplier__ supplier_nr__ supplier_type__ suppler_typeo__ supplier_share__ supply_month__ supplier_loc__ supplier_phone__ supplier_credit__ repayment_term__ repayment_term_unit__ repayment_interest__, i(id) j(supplier)

**drop missing suppliers**
drop if missing(supplier_nr__)

**Rename Credit Pay and Facility Characteristic Variables in order to Split**
local cred credit_repay credit_repayo credit_repay2 credit_repayo2 facility_characteristic__* fert_type storage
foreach x of local cred{
	rename `x' =__
	}
	
**generate a copy of column fertilizer_type--that way I can split one and use the other for a reference**
gen fertilizer_nr__=fertilizer_type__
**Split and Destring Multiple Entries and Drop Original Variable*
local vars fertilizer_nr__ fertsalesmonth fertsalesmost fertsalesleast assets_own assets_rent storage__ runout_cope credit_repay__ credit_repay2__ fert_quality_high fert_quality_low owner_relationship_other supply_month__ facility_characteristic__1__ facility_characteristic__2__ facility_characteristic__3__ //update number of facilities (can't figure out how to automate)

foreach x of local vars{
	split `x', destring
		forval i =1/`r(nvars)'{
		label variable `x'`i' "`x' #`i'"
		}
	drop `x'
	}
	
	

*reshape data so fertilizer is nested within supply**
reshape long fertilizer_nr__ fert_position__ fert_type_id__ fert_type_label__ current_stock__ today__ time_since__ time_to__ today_never__ total_sales__ sales_unit__ book_consult__ estimate__ manuf_number__ manufacturer__ manuf_name1__ manufacturero__ manufacturer2__ manuf_name2__ manufacturero2__ manufacturer3__ manuf_name3__ manufacturero3__ purchase_unit_large__ purchase_unit_large2__ purchase_unit_large3__ price__ price2__ price3__ cost__ cost2__ cost3__ price_small__ price_small2__ price_small3__ purchase_unit__ purchase_unit2__ purchase_unit3__ bag_size__ stocked_when__ instock_when__, i(id supplier) j(fertilizer) 

**PROBLEM IS THAT FERTILIZERS ARE FILLING IN ON POSITION RATHER THAN FERTILIZER ID**
//drop if missing(fertilizer_type__) WHEN I DROP THESE, RELEVANT DATA GOES MISSING IF THERE WAS A MISMATCH BETWEEN FERTILIZER POSITION AND ID NUMBER.


**split bag size**
split bag_size__, destring
	forval i =1/`r(nvars)'{
		label variable bag_size__`i' "Bag Size #`i'"
		}
	drop bag_size__



	
**remove empty variables that are giving me a headache**
drop subscriberid-devicephonenum
drop deviceid-username
drop caseid-comments
drop fertsalescheck1-fertsalescheck12 //can't figure out what these were supposed to be; they're all filled with '0'
drop concern_label
drop concern_label2

**reorder variables to align better with survey order**
 order fert_type__*, before(foliar)
 order fertilizer_nr, before(duration)
 order fertsalesmonth*, after(fertsales)
 order fertsalesmost*, before(customer_max)
 order fertsalesleast*, after(customer_avg_peak)
 order assets_own*, after(governmento)
 order assets_rent*, before(storage_nr)
 order storage_nr_calc__1-storage_unit__2, after(fert_unit)
 order supplier_nr__-supplier__, after(supplier_number)
 order fertilizer_type__, after(supplier__)
 order supplier_type__-repayment_interest__, after(fertilizer_type__)
 order supply_month__*, after(supplier_phone__)
 order fert_position__-estimate__, after(repayment_interest)
 order bag_size__*, after(today_never__)
 order manuf_number__-purchase_unit3__, after(estimate__)
 order customer_type-credit_repayo2__, after(purchase_unit3__)
 order fert_quality_high*, after(credit_repayo2__)
 order fert_quality_low*, before(concern1)
 order stocked_when__-instock_when__, after(current_stock__)
 order storage__*, after(fert_unit)
 order storageo, before(storage_nr_calc__1)
 order facility_characteristic__1__*, after(storage_unit__1)
 order facility_characteristic__2__*, after(storage_unit__2)
 order runout_cope*, after(runout)
 order credit_repay__*, after(customer_credit)
 order credit_repay2__*, after(customer_credit2)
 order biz_nr__1-other_business_phone__3, last //moved other business stuff to end because only a few stores had other businesses
 order other_store_*, after(other_stores_nr)
 
save "D:/Kikis Stuff/University of Wisconsin/Year 2/Project Assistant/data/InputSurvey_long_supply.dta", replace

//NEED TO DETERMINE WHICH VARIABLES GO WITH FERTILIZER--THAT WAY I CAN MAKE SURE THOSE ARE NESTED APPROPRIATELY (price, last in stock, bag size?)

