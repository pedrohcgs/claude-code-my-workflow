**************************************
**************************************

//为了文章内变量的可读性，对变量名有更改，文章中的变量名和代码中不一致的部分列举如下：
//RPT_a_REV 变成 RPT_control
//RPT_b_REV 变成 RPT_other
//Gurantee_TA 简写成 Guarantee
//OREC_TA 简写成 OREC






**************************************
*Table 3 描述性统计
**************************************

use main.dta, clear

replace guarantee_TA = guarantee_TA*1000
replace guarantee_REV = guarantee_REV*1000

replace guarantee_TA = 0 if missing(guarantee_TA)
replace guarantee_REV = 0 if missing(guarantee_REV)
replace opreatrange = 1 if missing(opreatrange)

rename RPT_a_REV RPT_control
rename RPT_b_REV RPT_other
rename guarantee_TA Guarantee
rename OREC_TA OREC
rename RPT_product_REV RPT_product
rename RPT_product_controlling_REV RPT_product_controlling

replace Tpt1006 = 0 if missing(Tpt1006)
gen software = ln(Tpt1006+1)


gen Capex = Outcap / total_asset


logout, save(description) word dec(3)  replace:       ///  
            tabstat RPT_control RPT_other RPT_product RPT_product_controlling RPT_a1_REV RPT_a2_REV Guarantee OREC FSSC opreatrange assign_exe software Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize Capex,  ///
            stats(mean sd min p25 p50 p75 max N) c(s) f(%6.2f) 
			
			
****************************************************************************
*Table 4 Main results
****************************************************************************


//主回归 只有卖方是显著的，用资产转移那篇文章对掏空的定义来justify
use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"

rename RPT_a_REV RPT_control
rename RPT_b_REV RPT_other


xtreg RPT_control FSSC $controls, fe vce(cluster industry_code)
	est store m1

xtreg RPT_other FSSC $controls, fe vce(cluster industry_code)
	est store m2	
	
outreg2 [m1 m2] using tab4, word dec(4) replace        ///
              title("Table2 FSSC and tunneling")  ///  
              keep (RPT_control RPT_other FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  

			  
****************************************************************************
*Table 5 Robustness Tests: Alternative Measurements
****************************************************************************
//更换掏空度量方式
//guarantee_TA guarantee_REV OREC_TA OREC_REV
use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"	

replace guarantee_TA = guarantee_TA * 1000
replace guarantee_REV = guarantee_REV * 1000




xtreg guarantee_TA FSSC $controls, fe vce(cluster industry_code)
	est store m1

xtreg OREC_TA FSSC $controls, fe vce(cluster industry_code)
	est store m2
	
	
	
outreg2 [m1 m2] using tab5, word dec(4) replace        ///
              title("Table2 FSSC and tunneling")  ///  
              keep (OREC_REV FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  

	


****************************************************************************
*Table 6 Robustness Tests: Heckman Selection Model
****************************************************************************
//工具变量：光缆线路长度
use main.dta, clear
replace Tpt1006 = 0 if missing(Tpt1006)
gen software = ln(Tpt1006)


global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"
//基准回归
xtset stkcd year
probit FSSC software $controls ,vce(cluster stkcd) nolog
estadd scalar pseudo_r2 = e(r2_p)
	est store stage1
//存储一阶段结果
outreg2 [stage1] using tab6, word dec(4) replace         ///
              title("Heckman")  ///  
              keep (software Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize) ///
			  tstat tdec(2) rdec(3)          ///
			  addstat("Pseudo R2", e(pseudo_r2))                ///  
              nonote     

//计算逆米尔斯
predict y_hat, xb
gen imr = normalden(y_hat)/normal(y_hat) if FSSC !=.
replace imr = -normalden(y_hat)/normal(-y_hat) if FSSC ==0
//二阶段
xtreg RPT_a_REV FSSC imr $controls, fe vce(cluster industry_code)
	est store stage2
	
//存储二阶段结果
outreg2 [stage2] using tab6, word dec(4)         ///
              title("Heckman")  ///  
              keep (FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize imr) ///
			  tstat tdec(2) rdec(3)   adjr2         ///
              nonote 

	
	
****************************************************************************
*Table 7 Robustness Tests: Matching
****************************************************************************
**#检查数据
//bysort stkcd: egen fssc_sd = sd(FSSC)
//tab fssc_sd
//bysort stkcd: summarize FSSC

*PSM
use main.dta, clear
xtset stkcd year
set seed 1117
gen ranorder=runiform()
sort ranorder
psmatch2 FSSC Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize, outcome(RPT_a1_REV) logit ate ties common n(1)


pstest Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize,both
logout,save(psm) word replace:pstest Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize,both
***必须汇报1-匹配后样本回归（用哪个选哪个)
xtreg RPT_a_REV FSSC Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize i.year,fe,if _weight!=.,vce(cluster stkcd)
	est store PSM
outreg2 [PSM] using tab7, word dec(4) replace        ///
              title("Robustness")  ///  
              keep (RPT_a_REV FSSC Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  			  
			  

*eb
use main.dta, clear
xtset stkcd year
global controls "Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize State i.year i.industry_code"
xtreg RPT_a_REV FSSC $controls, fe vce(cluster industry_code) //基准回归

ebalance FSSC $controls, targets(3) keep(baltable) replace 
//参考Chahine et al.(2020,RAS)和Francoeur et al.(2022,RAS)，将基准回归中所有协变量作为匹配变量，线性地加入到熵平衡过程中。Francoeur et al.(2022,RAS)还将行业固定效应和年份固定效应加进去。刘长庚等(2022,上海财经大学学报)还加入了二次项、交互项等，协变量个数达到115个。
//targets(3)：对协变量的一阶、二阶和三阶矩均进行平衡
//keep(baltable)：将结果保存到baltable.dta，其中mean_Tr为处理组的均值，mean_Co_Pre为控制组匹配前的均值，mean_Co_Pre为控制组匹配后的均值。

//reg re78 treat age-u75 [pweight=_webal]  //参考Chahine et al.(2020,RAS)和Francoeur et al.(2022,RAS),仍然加入所有控制变量
//reg RPT_a_REV FSSC $controls [pweight=_webal]
//xtreg RPT_a_REV FSSC $controls [pweight=_webal], fe vce(cluster industry_code)
reghdfe RPT_a_REV FSSC $controls [pweight=_webal], ///
    absorb(stkcd year) ///
    vce(cluster industry_code)

	est store EB
outreg2 [EB] using tab7, word dec(4)         ///
              title("Robustness")  ///  
              keep (RPT_a1_REV FSSC Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  			  
			  




****************************************************************************
*Figure 1 Placobo
****************************************************************************

use main.dta, clear
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"
//reghdfe RPT_a1_REV FSSC $controls
xtreg RPT_a_REV FSSC $controls, fe vce(cluster industry_code)

//安慰剂检验   表示出真实值：xline(0.0288, lp(dash))  括号内数字替换主回归真实系数
//为了能显示真实系数把横坐标范围放大 画出真实值：xlabel(-0.16(0.02)0.04) 
cap erase "simulation.dta"
permute FSSC beta =_b[FSSC] se=_se[FSSC] df=e(df_r),reps(500) rseed(123) saving("simulation.dta"):xtreg RPT_a_REV FSSC $controls, fe vce(cluster industry_code)

//permute FSSC beta =_b[FSSC] se=_se[FSSC] df=e(df_r),reps(500) rseed(123) saving("simulation.dta"):reghdfe RPT_a1_REV FSSC $controls

use "simulation.dta",clear
gen t_value = beta / se
gen p_value = 2*ttail(df,abs(beta/se))
//画图：系数
dpplot beta,xline(0.0180, lp(dash)) xlabel(-0.02(0.01)0.02)  xtitle("coefficient of Pseudo_FSSC") ytitle("Density") scheme(tufte)
//画图：T值
dpplot t_value,xtitle("t-value of Pseudo_FSSC") ytitle("Density") scheme(tufte)



****************************************************************************
*Table 8 Moderation: Firm Complexity
****************************************************************************
//上市公司经营范围，跨多少个行业
//结果非常好，opreatrange本身系数为负，表明信息环境复杂，内部信息不对称高，减少掏空
use main.dta, clear
xtset stkcd year
replace opreatrange =1 if missing(opreatrange)
gen FSSC_opreatrange = FSSC * opreatrange
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"


xtreg RPT_a_REV FSSC opreatrange FSSC_opreatrange $controls, fe vce(cluster industry_code)
	est store m1

xtreg RPT_b_REV FSSC opreatrange FSSC_opreatrange $controls, fe vce(cluster industry_code)
	est store m3

	

outreg2 [m1 m3] using tab8, word dec(4) replace        ///
              title("pyramid")  ///  
              keep (FSSC opreatrange FSSC_opreatrange Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  

			  
	
****************************************************************************
*Table 9 Moderation: Controllers appoint TMT
****************************************************************************	
//assign_exe assign_dir assign_sup 1是委派了 0是没有委派 分别是高管、董事、监事
use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"

tab S0702b, gen(d_S0702b_)

gen FSSC_exe = FSSC * assign_exe


//委派管理层
xtreg RPT_a_REV FSSC assign_exe FSSC_exe $controls, fe vce(cluster industry_code)
	est store m1
xtreg RPT_a_REV FSSC assign_exe FSSC_exe $controls if d_S0702b_2 == 1, fe vce(cluster industry_code)
	est store m3
xtreg RPT_a_REV FSSC assign_exe FSSC_exe $controls if d_S0702b_3 == 1, fe vce(cluster industry_code)
	est store m4

	
outreg2 [m1 m3 m4] using tab9, word dec(4) replace        ///
              title("assign")  ///  
              keep (FSSC assign_exe FSSC_exe Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  

	
****************************************************************************
*Table 10 Additional Analysis: Product Transaction
****************************************************************************

use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"


//产品劳务交易
xtreg RPT_product_REV FSSC $controls, fe vce(cluster industry_code)
	est store m3
xtreg RPT_product_controlling_REV FSSC $controls, fe vce(cluster industry_code)
	est store m5


	
outreg2 [m3 m5] using tab10, word dec(4) replace        ///
              title("Table2 FSSC and tunneling")  ///  
              keep (FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  


****************************************************************************
*Table 11 Additional Analysis: Transaction Direction
****************************************************************************

use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"



xtreg RPT_a1_REV FSSC $controls, fe vce(cluster industry_code)
	est store m1
xtreg RPT_a2_REV FSSC $controls, fe vce(cluster industry_code)
	est store m2	
	
outreg2 [m1 m2] using tab11, word dec(4) replace        ///
              title("Table2 FSSC and tunneling")  ///  
              keep (RPT_a1_REV RPT_a2_REV FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  




****************************************************************************
*Table 12 Economic Consequences
****************************************************************************
			  
use main.dta, clear
xtset stkcd year

global controls "Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize State i.year"

// RDSpendSumRatio 研发投入占营业收入比例

//资本支出 Outcap 购建固定资产、无形资产和其它长期资产所支付的现金
gen Capex = Outcap / total_asset

//托宾Q值B-市值A/（资产总计—无形资产净额—商誉净额） F100902A 

//FI_T5F053202B 投资收益率 本期投资收益/（长期股权投资本期期末值+持有至到期投资本期期末值+交易性金融资产本期期末值+可供出售金融资产本期期末值+衍生金融资产本期期末值）。注：当分母未公布或为零或小于零时，以NULL表示
//非效率投资 InefficInvestDegree InefficInvestSign


//用FSSC与RPT变动值的交互项

gen delta_RPT = RPT_a_REV - L.RPT_a_REV

gen FSSC_RPT = FSSC * delta_RPT


xtreg FF.ROA FSSC_RPT  $controls i.year, fe vce(cluster industry_code)
	est store m1
//托宾q
xtreg FF.F100902A FSSC_RPT  $controls i.year, fe vce(cluster industry_code)
	est store m2	

xtreg FF.Capex FSSC_RPT  $controls i.year, fe vce(cluster industry_code)
	est store m3


outreg2 [m1 m2 m3] using tab12, word dec(4) replace        ///
              title("Economic Consequences")  ///  
              keep (FSSC_RPT Size LEV BM ln_firmage Big4 Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  			  

	
	  
****************************************************************************
*table 13 实控人身份的cross-sectional
****************************************************************************
	
//
tab S0702b if FSSC == 1 

//S0702b [实际控制人性质] - 详细分类见说明书附录二的"企业关系人性质分类标准"：1000企业经营单位1100国有企业1200民营企业1210集体所有制企业1220港澳台资企业1230外国企业2000行政机关、事业单位2100中央机构2120地方机构2500社会团体3000自然人3110国内自然人3120港澳台自然人3200国外自然人9999其他


//不包括没有企业建设FSSC的分类d_S0702b_5 d_S0702b_11 d_S0702b_15		
//不包括不明确的分类 d_S0702b_1 企业经营单位 d_S0702b_4 集体所有制 d_S0702b_10社会团体
			  

use main.dta, clear
xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"

tab S0702b, gen(d_S0702b_)			  

//私人
xtreg RPT_a_REV FSSC $controls if d_S0702b_12 == 1, fe vce(cluster industry_code) 
	est store Person
//私企
xtreg RPT_a_REV FSSC $controls if d_S0702b_3 == 1, fe vce(cluster industry_code) 
	est store POE
//国企
xtreg RPT_a_REV FSSC $controls if d_S0702b_2 == 1 , fe vce(cluster industry_code) 
	est store SOE
//事业单位
xtreg RPT_a_REV FSSC $controls if d_S0702b_7 == 1 , fe vce(cluster industry_code) 
	est store Admin
//政府机构
xtreg RPT_a_REV FSSC $controls if d_S0702b_8 == 1 | d_S0702b_9 == 1, fe vce(cluster industry_code) 
	est store Gov
//外国
xtreg RPT_a_REV FSSC $controls if d_S0702b_6 == 1 | d_S0702b_13 == 1 | d_S0702b_14 == 1, fe vce(cluster industry_code) 
	est store Foreign

outreg2 [Person POE SOE Admin Gov Foreign] using tab13B, word dec(4) replace        ///
              title("property right")  ///  
              keep (FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  
	
	  
			  
**************************************
use main.dta, clear
xtset stkcd year	
tab S0702b, gen(d_S0702b_)

global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"


//私人
xtreg OREC_TA FSSC $controls if d_S0702b_12 == 1, fe vce(cluster industry_code) 
	est store Person
//私企
xtreg OREC_TA FSSC $controls if d_S0702b_3 == 1, fe vce(cluster industry_code) 
	est store POE
//国企
xtreg OREC_TA FSSC $controls if d_S0702b_2 == 1 , fe vce(cluster industry_code) 
	est store SOE
//事业单位
xtreg OREC_TA FSSC $controls if d_S0702b_7 == 1 , fe vce(cluster industry_code) 
	est store Admin	
//政府机构
xtreg OREC_TA FSSC $controls if d_S0702b_8 == 1 | d_S0702b_9 == 1, fe vce(cluster industry_code) 
	est store Gov
//外国
xtreg OREC_TA FSSC $controls if d_S0702b_6 == 1 | d_S0702b_13 == 1 | d_S0702b_14 == 1, fe vce(cluster industry_code) 
	est store Foreign

outreg2 [Person POE SOE Admin Gov Foreign] using tab13C, word dec(4) replace        ///
              title("property right")  ///  
              keep (FSSC Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  
	


	
****************************************************************************
*Table 14 Budget deficit and tunneling
****************************************************************************
//看国企掏空和地方财政
clear
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/地方财政收支/CRE_Gfct.xlsx", sheet("sheet1") firstrow

ds
local vars `r(varlist)'

foreach v of local vars {
    local lbl = `v'[1]
    label variable `v' "`lbl'"
}

drop if _n == 1 | _n == 2

gen year=substr(Sgnyea,1,4)
destring year ,replace
destring Egfct01 ,replace
destring Egfct03 ,replace

gen deficit = Egfct03 - Egfct01
label variable deficit "赤字（支出-收入）"
drop Ctnm Sgnyea Egfct03 Egfct01
rename Ctnm_id CITYCODE 
destring CITYCODE ,replace

save deficit.dta, replace


use main.dta, clear
merge m:1 CITYCODE year using deficit.dta
drop if _merge ==2
drop _merge	

xtset stkcd year
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State i.year"		

tab S0702b, gen(d_S0702b_)	

replace deficit = deficit / 1000000

gen FSSC_deficit = FSSC * L.deficit


//地方政府	
xtreg RPT_a_REV FSSC L.deficit FSSC_deficit $controls if d_S0702b_9 == 1 , fe vce(cluster industry_code) 
	est store m2

//行政机构
xtreg RPT_a_REV FSSC L.deficit FSSC_deficit $controls if d_S0702b_7 == 1 , fe vce(cluster industry_code) 
	est store m3
//国企
xtreg RPT_a_REV FSSC L.deficit FSSC_deficit $controls if d_S0702b_2 == 1 , fe vce(cluster industry_code) 
	est store m4

outreg2 [m2 m3 m4] using tab14, word dec(4) replace        ///
              title("property right")  ///  
              keep (FSSC L.deficit FSSC_deficit Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  
	
		

****************************************************************************
*调节：腐败
****************************************************************************
//各地区腐败案件数
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/各地区受贿罪数据（2000-2024年）.xlsx", sheet("Sheet1") firstrow
drop 省份 所属地域 年末常住人口万人 H I
rename 年份 year
rename 省份代码 PROVINCECODE
rename 受贿罪刑事一审判决数件 Corrupt
rename 人均判决数件万人 Corrupt_average
drop if missing(Corrupt)
save corrupt.dta, replace


use main.dta, replace
merge m:1 year PROVINCECODE using corrupt.dta
drop if _merge ==2
drop _merge

replace Corrupt = 0 if missing(Corrupt)
replace Corrupt_average = 0 if missing(Corrupt_average)

gen FSSC_Corrupt = FSSC * Corrupt_average
global controls "Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize i.year"


xtreg RPT_a_REV FSSC Corrupt_average FSSC_Corrupt $controls, fe vce(cluster industry_code)
	est store m1

xtreg RPT_b_REV FSSC Corrupt_average FSSC_Corrupt $controls, fe vce(cluster industry_code)
	est store m3

	

outreg2 [m1 m3] using tab15, word dec(4) replace        ///
              title("corrupt")  ///  
              keep (FSSC Corrupt_average FSSC_Corrupt Size ROA LEV BM ln_firmage Big4 TobinQ Inddir Duality ln_boardsize State) ///
			  tstat tdec(2) rdec(3)  adjr2                  ///  
              nonote                                      ///  

			  
	




	

