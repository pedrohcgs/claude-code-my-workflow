******************************************
*Hayek, Local Information, and Commanding Heights Decentralizing State-Owned Enterprises in China

*By Zhangkai Huang, Lixing Li, Guangrong Ma, and Lixin Colin Xu

*This file is the program that replicates all tables in the main paper. All variables are labelled in the datasets. Please refer to Table 1 in the article for definition of the variables.

*Note: When estimating the probit model, perfectly predicted observations are automatically dropped (in Stata), and the reported number of observation reflects the default choice of Stata. We report the before-Stata-automatically-dropped number of observations in the tables.
********************************************



clear
set more off
set matsize 3000

cd "Hayek, Local Information, and Commanding Heights Decentralizing State-Owned Enterprises in China"




		
***************************************************************************************
*Table 3 - Panel A. Determination of Decentralization 
***************************************************************************************
****Column 1-4: Probit model
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table 3-Panel A", replace word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I*) ctitle(Probit Whole Sample) addtext(gov¡¯t year & industry  dummy, YES) 
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==10 
outreg2 using "Table 3-Panel A",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I*) ctitle(Probit Central SOE) addtext(gov¡¯t year & industry  dummy, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy) 
outreg2 using "Table 3-Panel A",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I*) ctitle(ProbitProvincal SOE) addtext(gov¡¯t year & industry  dummy, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy) 
outreg2 using "Table 3-Panel A",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I*) ctitle(Probit Municipal SOE) addtext(gov¡¯t year & industry  dummy, YES)

****Column 5: Hazard model
stset year,id(id) failure(fdece) origin(time soe_init_yr-1)
stcox lndis lnasset ROS  importance Dfsoe  prov_gdpper prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,  cl(govdummy) nohr
outreg2 using "Table 3-Panel A",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* o.*) ctitle(Hazard model Whole Sample) addtext(gov¡¯t year & industry  dummy, YES)

****Column 6-7:Multinomial Probit model
use "dece_mlogit",clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
gen     moption=0 if restru!=1&fdece!=1
replace moption=1 if restru!=1&fdece==1
replace moption=2 if restru==1&fdece!=1
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  
margins, dydx(lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) predict(outcome(1))  post
outreg2 using "Table 3-Panel A", word noobs noaster nocons dec(4) drop(_I*) ctitle(Multinomial Probit Whole Sample) addtext(gov¡¯t year & industry  dummy, YES)
mlogit moption lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)  
margins, dydx(lndis lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) predict(outcome(2))  post
outreg2 using "Table 3-Panel A",word noobs noaster nocons dec(4) drop(_I*) ctitle(Multinomial Probit Whole Sample) addtext(gov¡¯t year & industry  dummy, YES)





***************************************************************************************
*Table 3 - Panel B. Determination of Decentralization 
***************************************************************************************
****Column 1-3: add addtional controls 
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_SOE unemployment  prov_revper  prov_gdpper prov_fisauto _Iyear* _Iind2* if govType==10
outreg2 using "Table 3-Panel B",replace  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Central SOE) addtext(Controls, YES, Additional controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_SOE unemployment prov_fisauto  prov_gdpper prov_revper muni_fisauto muni_revper muni_gdpper _Iyear* _Igovdum* _Iind2* if govType==20,cl(govdummy)
outreg2 using "Table 3-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Municipal SOE) addtext(Controls, YES, Additional controls, YES)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_SOE unemployment muni_fisauto muni_revper muni_gdpper county_fisauto county_revper county_gdpper  _Iyear* _Igovdum* _Iind2* if govType==40,cl(govdummy)
outreg2 using "Table 3-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(County SOE) addtext(Controls, YES, Additional controls, YES)

****Column 4-5: Full state ownership vs. Partial state ownership
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if state==1,cl(govdummy) 
outreg2 using "Table 3-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Full state ownership) addtext(Controls, YES, Additional controls, NO)
dprobit fdece  lndis lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iyear* _Igovdum* _Iind2* if state<1,cl(govdummy) 
outreg2 using "Table 3-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) keep(lndis) ctitle(Partial state ownership) addtext(Controls, YES, Additional controls, NO)






***************************************************************************************
*Table 4. Determinants of Decentralization ¨C Placebo Test and Third Front Construction as IV
***************************************************************************************
****Column 1: Placebo test - Whole sample
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 
dprobit fdece lndis_placebo lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2*,cl(govdummy) 
outreg2 using "Table 4",replace word noobs noaster nocons dec(4) keep(lndis_placebo) ctitle(Placebo test, whole Sample) addtext(Controls, YES)

****Column 2: Placebo test - excluding small placebo city
dprobit fdece lndis_placebo lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear* _Igovdum* _Iind2* ///
if exclude!=1,cl(govdummy) 
outreg2 using "Table 4", word noobs noaster nor2 nocons dec(4) keep(lndis_placebo) ctitle(Placebo test, excluding small placebo city) addtext(Controls, YES)

****Column 3: 2SLS - first stage 
reg lndis TFC lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment     _Iyear* ///
_Igovdum* _Iind2* ,cl(govdummy) 
outreg2 using "Table 4", word noobs noaster nor2 bdec(4) nocons  keep(TFC) ctitle(2SLS,1st stage, Distance) addtext(Controls, YES)

****Column 4: 2SLS - second stage
ivreg2 fdece (lndis=TFC) lnasset ROS  importance Dfsoe  prov_gdpper   prov_SOE unemployment  _Iyear*  /// 
_Igovdum* _Iind2*, cl(govdummy) 
outreg2 using "Table 4", word noobs noaster nor2 bdec(4) nocons  keep(lndis) ctitle(2SLS,2nd stage, Decentralized) addtext(Controls, YES) sortvar(lndis_placebo lndis TFC)
*Anderson-Rubin F statistic
weakiv,  arlevel(90) 






***************************************************************************************
*Table 5. Determinants of Decentralization: Testing alternative hypotheses 
***************************************************************************************
use dece,clear
tab govdummy,gen(_Igovdum)
tab year,gen(_Iyear)
tab ind2,gen(_Iind2) 

****Panel A. communication costs or information intensity
gen lndis_road=lndis*road
gen lndis_road98=lndis*road98
gen lndis_ROS_sd=lndis*ROS_sd
gen lndis_tfp_OLS_sd=lndis*tfp_OLS_sd
gen lndis_tfp_OP_sd=lndis*tfp_OP_sd
gen lndis_tfp_IN_sd=lndis*tfp_IN_sd
dprobit fdece lnasset ROS   lndis lndis_road road importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2*  ,cl(govdummy) 
outreg2 using "Table 5-Panel A", replace word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_road98 road98 importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
outreg2 using "Table 5-Panel A", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_ROS_sd ROS_sd importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel A", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_tfp_OLS_sd tfp_OLS_sd importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel A", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_tfp_OP_sd tfp_OP_sd importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel A", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_tfp_IN_sd tfp_IN_sd importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel A", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)

****Panel B.Interactions of distance with Strategic Industries
gen strategic_lndis=strategic*lndis
gen strategic2_lndis=strategic2*lndis
dprobit fdece  lndis  strategic_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment    _Iind2* _Iyear* _Igovdum*   ,cl(govdummy) 
outreg2 using "Table 5-Panel B",replace  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece  lndis  strategic_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iind2*  _Iyear*   if govType==10 
outreg2 using "Table 5-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece  lndis  strategic_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment    _Iind2* _Iyear* _Igovdum*   if govType==20|govType==40,cl(govdummy) 
outreg2 using "Table 5-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece  lndis  strategic2_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment    _Iind2* _Iyear* _Igovdum*   ,cl(govdummy) 
outreg2 using "Table 5-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece  lndis  strategic2_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment   _Iind2*  _Iyear*   if govType==10 
outreg2 using "Table 5-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece  lndis  strategic2_lndis   lnasset ROS   importance Dfsoe prov_gdpper   prov_SOE unemployment    _Iind2* _Iyear* _Igovdum*   if govType==20|govType==40,cl(govdummy) 
outreg2 using "Table 5-Panel B",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)

***Panel C.  corruption and firm rent
gen lndis_etc=lndis*etc
gen lndis_corruption=lndis*corruption
gen lndis_ROS=lndis*ROS
gen lndis_wage=lndis*wage
gen lndis_hhi_sale=lndis*hhi_sale
gen lndisLow_etc=lndisLow*etc
gen lndisLow_corruption=lndisLow*corruption
gen lndisLow_ROS=lndisLow*ROS
gen lndisLow_wage=lndisLow*wage
gen lndisLow_hhi_sale=lndisLow*hhi_sale
dprobit fdece lnasset ROS   lndis lndisLow importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel C", replace word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p))   drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_etc lndisLow lndisLow_etc etc importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel C",  word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p))   drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_corruption lndisLow lndisLow_corruption corruption importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2*,cl(govdummy)
outreg2 using "Table 5-Panel C", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p))   drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_ROS lndisLow lndisLow_ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
outreg2 using "Table 5-Panel C", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p))   drop(_I* lnasset  importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_wage lndisLow lndisLow_wage wage importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2*  ,cl(govdummy)
outreg2 using "Table 5-Panel C", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p))  drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)
dprobit fdece lnasset ROS   lndis lndis_hhi_sale lndisLow lndisLow_hhi_sale hhi_sale importance Dfsoe  prov_gdpper   prov_SOE unemployment    _Iyear* _Igovdum* _Iind2* ,cl(govdummy)
outreg2 using "Table 5-Panel C", word noobs noaster nocons dec(4) addstat(Pseudo R2, e(r2_p)) drop(_I* lnasset ROS importance Dfsoe  prov_gdpper   prov_SOE unemployment) addtext(Controls, YES)














