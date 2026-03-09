******************************************
*Hayek, Local Information, and Commanding Heights Decentralizing State-Owned Enterprises in China

*By Zhangkai Huang, Lixing Li, Guangrong Ma, and Lixin Colin Xu

*This file is the program that replicates all tables in the online Appendix. All variables are labelled in the datasets. Please refer to Table 1 in the article for definition of the variables.

*Note: When estimating the probit model, perfectly predicted observations are automatically dropped (in Stata), and the reported number of observation reflects the default choice of Stata. We report the before-Stata-automatically-dropped number of observations in the tables.
********************************************




clear
set more off
set matsize 3000

cd "Hayek, Local Information, and Commanding Heights Decentralizing State-Owned Enterprises in China"
		


***************************************************************************************
*Table B-2 Summary statistics of key variables
***************************************************************************************
use dece,clear
global x   lndis diff_city lnasset ROS tfp_OLS tfp_OP tfp_IN  importance Dfsoe wage TFC ///
prov_gdpper prov_SOE unemployment road    etc  corruption ROS_sd  tfp_OLS_sd tfp_OP_sd tfp_IN_sd hhi_sale

tabstat fdece $x, stats(n mean sd min max) col(stats)



***************************************************************************************
*Table B-3 Comparison of basic characteristics for decentralized and non-decentralized SOEs 
***************************************************************************************
use dece,clear
global x   lndis  lnasset ROS tfp_OLS tfp_OP tfp_IN  importance Dfsoe wage TFC ///
prov_gdpper prov_SOE unemployment road    etc  corruption  ROS_sd  tfp_OLS_sd tfp_OP_sd tfp_IN_sd hhi_sale

bysort id:egen fdece_ever=max(fdece)
eststo clear
foreach var of varlist $x  {
eststo:reg  `var' fdece_ever 
}
esttab using "Table B-3.csv", label r2 b(3) p(3) nostar  nogap replace 			
			



***************************************************************************************
*Table B-4: Number of firms that were decentralized in different years
***************************************************************************************
use dece,clear
tab year if year==fdece_year



***************************************************************************************
*Table B-5: Ratio of Decentralization in different provinces
***************************************************************************************
use dece,clear
bysort id:egen fdece_ever=max(fdece)
tabstat fdece_ever if year==soe_init_yr,by(provcode) 




***************************************************************************************
**Table D-1. The determinants of decentralization: Cox proportional hazard regression 
***************************************************************************************
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2* if govType==10 ,nohr
outreg2 using "Table D-1", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Central SOE) addtext(Controls, YES)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2* if govType==20 ,nohr cl(govdummy) 
outreg2 using "Table D-1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Provincal SOE) addtext(Controls, YES)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2* if govType==40 ,nohr cl(govdummy) 
outreg2 using "Table D-1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Municipal SOE) addtext(Controls, YES)





***************************************************************************************
*Table E-1. Determinants of decentralization, explicit privatization and exit
***************************************************************************************
use dece_mlogit,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption2=0 if restru!=1&fdece!=1
replace moption2=1 if restru!=1&fdece==1
replace moption2=2 if exit==1&fdece!=1
replace moption2=3 if expriv==1&fdece!=1
mlogit moption2 lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) iter(100)
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table E-1", word noaster noobs nocons dec(4) drop(_I*) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption2 lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  iter(100)
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table E-1",word noaster noobs nocons dec(4) drop(_I*) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption2 lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  iter(100)
margins, dydx(lndis) predict(outcome(3))  post
outreg2 using "Table E-1",word noaster noobs nocons dec(4) drop(_I*) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)




***************************************************************************************
*Table E-2. Determinants of decentralization: dropping SOEs that are eventually restructured
***************************************************************************************
use dece,clear
drop if  soe_last_yr!=2007
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table E-2", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Iind2* if govType==10 
outreg2 using "Table E-2",  word noaster noobs nocons dec(4)  keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table E-2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Provincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table E-2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table E-2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)





***************************************************************************************
*Table F-1: Determinants of decentralization: using alternative definitions of SOEs
***************************************************************************************
****Panel A. Using 50% state ownership share as the cutoff for defining SOEs
*Column 1-4: Probit model
use dece_SOE50p,clear
*drop obs after decetralizaiton 
keep if year<=fdece_year
drop if year==soe_last_yr
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table F- Panel 1", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table F- Panel 1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table F- Panel 1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table F- Panel 1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table F- Panel 1",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7: Multinomial Probit model
use dece_SOE50p,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(1))   post
outreg2 using "Table F- Panel 1",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(2))   post
outreg2 using "Table F- Panel 1",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)



****Panel B. Using the Brandt et al. (2012) definition of SOEs
*Column 1-3: Probit model
use dece_SOEregis,clear
*drop obs after decetralizaiton 
keep if year<=fdece_year
drop if year==soe_last_yr
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
set more off
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table F- Panel 2", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table F- Panel 2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table F- Panel 2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table F- Panel 2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table F- Panel 2",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7:Multinomial Probit model
use dece_SOEregis,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table F- Panel 2", word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table F- Panel 2",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)




****Panel C. Using the Hsieh and Song (2015) definition of SOEs
*Column 1-3: Probit model
use dece_SOEcontrol,clear
*drop obs after decetralizaiton 
keep if year<=fdece_year
drop if year==soe_last_yr
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
set more off
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table F- Panel 3", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table F- Panel 3",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table F- Panel 3",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table F- Panel 3",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table F- Panel 3",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7: Multinomial Probit model
use dece_SOEcontrol,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table F- Panel 3", word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table F- Panel 3",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)







***************************************************************************************
*Table G-1 Determinants of decentralization: Different sample compositions
***************************************************************************************
*Panel A: Keep firms with abnormal decentralization
*Column 1-4: Probit model
use dece_withabnormal,clear
drop if year==soe_last_yr
keep if year<=fdece_year
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
set more off
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table G-1 Panel A", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table G-1 Panel A",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table G-1 Panel A",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table G-1 Panel A",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table G-1 Panel A",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7:Multinomial Probit model
use dece_withabnormal,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table G-1 Panel A",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table G-1 Panel A",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)




****Panel B: Allow for multiple episodes of decentralization
*Column 1-4: Probit model
use dece_mlogit,clear
drop if year==soe_last_yr
drop if govType==50
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table G-1 Panel B", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table G-1 Panel B",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table G-1 Panel B",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table G-1 Panel B",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
replace id=id*100000 if year>fdece_year
drop soe_init_yr
bysort id:egen soe_init_yr=min(year)
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table G-1 Panel B",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7:Multinomial Probit 
use dece_mlogit,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table G-1 Panel B",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table G-1 Panel B",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)




****Panel C: Allow for two consecutive period
*Column 1-4: Probit model
use dece_SOE2consec,clear
keep if year<=fdece_year
drop if year==soe_last_yr
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table G-1 Panel C", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Whole Sample) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table G-1 Panel C",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Central SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table G-1 Panel C",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(ProbitProvincal SOE) addtext(Controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table G-1 Panel C",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Probit Municipal SOE) addtext(Controls, YES)
*Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table G-1 Panel C",  word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Hazard model Whole Sample) addtext(Controls, YES)
*Column 6-7:Multinomial Probit 
use dece_SOE2consec,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2)
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1 
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
margins, dydx(lndis) predict(outcome(1))  post
outreg2 using "Table G-1 Panel C",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
margins, dydx(lndis) predict(outcome(2))  post
outreg2 using "Table G-1 Panel C",word noaster noobs nocons dec(4) keep(lndis) ctitle(Multinomial Probit Whole Sample) addtext(Controls, YES)





***************************************************************************************
*Table H-1. Regression results on the determinants of centralization
***************************************************************************************
use dece_add_countySOEs,clear
tab govup,gen(_Igovup)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fup  lndis lndisUp lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovup* ///
_Iind2* if govType!=10,cl(govup) 
outreg2 using "Table H-1", replace word noaster noobs nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I*) ctitle(Province & Municipal SOE) addtext(Controls, YES)





***************************************************************************************
*Table J-1. Determinants of TFC
***************************************************************************************
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit  TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment     _Iyear* ///
_Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table J-1",replace word noaster noobs bdec(4) nocons  drop(_I*)  addstat(Pseudo R2, e(r2_p)) ctitle(Depedent variable: TFC) addtext(gov¡¯t, year & industry dummy, YES)




***************************************************************************************
*Table J-2. Characterizing distributions of the compliers sample
***************************************************************************************
use dece,clear
drop if ROS==.
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
egen lnasset_m=median(lnasset)
egen ROS_m=median(ROS)
egen importance_m=median(importance)
egen Dfsoe_m=median(Dfsoe)
egen prov_gdpper_m=median(prov_gdpper)
egen prov_SOE_m=median(prov_SOE)
egen unemployment_m=median(unemployment)

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper  prov_SOE unemployment  _Iyear*  ///
_Igovdum* _Iind2* , cl(govdummy)
outreg2 using "Tabe J-2", replace nocons dec(4) word  noaster  keep(TFC)
mat beta=e(b)
gen b=beta[1,1] 

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if lnasset>lnasset_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster   keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if ROS>ROS_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster   keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if importance>importance_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word  noaster  keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if Dfsoe==1, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster  keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if prov_gdpper>prov_gdpper_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster   keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if prov_SOE>prov_SOE_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster  keep(TFC)
test TFC=0.0875

reg  diff_city TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2* if unemployment>unemployment_m, cl(govdummy)
outreg2 using "Tabe J-2",  nocons dec(4) word noaster   keep(TFC)
test TFC=0.0875

