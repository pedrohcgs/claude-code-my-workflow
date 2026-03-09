use 财务共享中心与DA初步合并数据-新.dta, clear
drop DA ODA DDA lnDA lnODA lnDDA da oda dda da_sen da_intangible da_int1 da_int2
drop _merge

**************************************
**合并掏空
**************************************
merge 1:1 stkcd year using RPT.dta
drop if _merge == 2
drop if _merge == 1
drop _merge

xtset stkcd year

gen RPT_a_REV = RPT_a /FS_CominsB001101000
label variable RPT_a_REV "关联交易小口径/营收"
gen RPT_a_TA = RPT_a /FS_CombasA001000000
label variable RPT_a_TA "关联交易小口径/总资产"

gen RPT_a1_REV = RPT_a1 /FS_CominsB001101000
label variable RPT_a1_REV "关联交易卖方小口径/营收"
gen RPT_a1_TA = RPT_a1 /FS_CombasA001000000
label variable RPT_a1_TA "关联交易卖方小口径/总资产"

gen RPT_a2_REV = RPT_a2 /FS_CominsB001101000
label variable RPT_a2_REV "关联交易买方小口径/营收"
gen RPT_a2_TA = RPT_a2 /FS_CombasA001000000
label variable RPT_a2_TA "关联交易买方小口径/总资产"


gen RPT_b_REV = RPT_b /FS_CominsB001101000
label variable RPT_b_REV "关联交易非大股东/营收"
gen RPT_b_TA = RPT_b /FS_CombasA001000000
label variable RPT_b_TA "关联交易非大股东/营收"



gen RPT_product_controlling_REV = RPT_product_controlling /FS_CominsB001101000
label variable RPT_product_controlling_REV "商品/营收"

gen RPT_labor_controlling_REV = RPT_labor_controlling /FS_CominsB001101000
label variable RPT_labor_controlling_REV "劳务/营收"

gen RPT_product_REV = RPT_product /FS_CominsB001101000
label variable RPT_product_REV "商品/营收"

gen RPT_labor_REV = RPT_labor /FS_CominsB001101000
label variable RPT_labor_REV "劳务/营收"




drop RPT_product RPT_labor RPT_product_controlling RPT_labor_controlling RPT_a RPT_b RPT_asset1 RPT_cash1 RPT_equity1 RPT_a1 RPT_asset2 RPT_cash2 RPT_equity2 RPT_a2

save raw.dta, replace




**************************************
*合并实际控制人文件
**************************************
use raw.dta, clear
merge 1:1 stkcd year using controller.dta
drop if _merge ==2
drop if _merge ==1
drop _merge 
save raw.dta, replace

*S0702b1000企业经营单位1100国有企业1200民营企业1210集体所有制企业1220港澳台资企业1230外国企业2000行政机关、事业单位2100中央机构2120地方机构2500社会团体3000自然人3110国内自然人3120港澳台自然人3200国外自然人9999其他





**************************************
*其他掏空衡量方式
*************************************

*对外担保
use raw.dta, clear
merge 1:1 stkcd year using guarantee.dta
drop if _merge ==2
drop _merge 

xtset stkcd year

gen guarantee_TA = guarantee /FS_CombasA001000000
label variable guarantee_TA "担保/总资产"
gen guarantee_REV = guarantee /FS_CominsB001101000
label variable guarantee_REV "担保/营收"


*其他应收款
gen OREC_TA = FS_CombasA001121000 /FS_CombasA001000000
label variable OREC_TA "其他应收/总资产"
gen OREC_REV = FS_CombasA001121000 /FS_CominsB001101000
label variable OREC_REV "其他应收/营收"

save raw.dta, replace

**# 掏空衡量有三种方式构造：关联交易为主、担保、其他应收款为辅
//具体变量为 RPT_a_REV RPT_a_TA RPT_b_REV RPT_b_TA RPT_a1_REV RPT_a1_TA RPT_a2_REV RPT_a2_TA guarantee_TA guarantee_REV OREC_TA OREC_REV



**************************************
*合并资本支出、委派、通信能力
*************************************

use raw.dta, clear
merge 1:1 stkcd year using capex.dta
drop if _merge == 2
drop _merge
save raw.dta, replace

use raw.dta, clear
merge 1:1 stkcd year using assign.dta
drop if _merge == 2
drop _merge
save raw.dta, replace


use raw.dta, clear
merge m:1 PROVINCECODE year using commu.dta
drop if _merge == 2
drop _merge
save raw.dta, replace

**************************************
**#数据清洗 从raw到main，剔除观测值后为main
**************************************

**股票的识别
**A股市场主要板块目前A股市场有三个交易所：分别是上海交易所、深圳交易所、北京交易所。
*根据定位不同，分为主板（上海主板、深圳主板）、科创板、创业板、北交所四大板块。下面介绍各个板块的定位和特点。
**沪市主板：股票代码以600、601或603开头。
**深市主板：股票代码以000、001、002、003开头。
**创业板：股票代码以300开头，属于深证市场。
**科创板：股票代码以688开头，属于上证市场。
**新三板：股票代码通常以400、430、830开头。
**北交所：股票代码以8开头，其中82开头的股票表示优先股，83和87开头的股票表示普通股票，88开头的股票表示公开发行的股票

use raw.dta, clear
order stkcd year  Stknmec

*保留A股的上市公司
tostring stkcd, gen(stkcd_str) format(%06.0f)
* 标记（默认 0）
gen remainA = 0
* 沪市主板
replace remainA = 1 if regexm(stkcd_str, "^(600|601|603)")
* 深市主板
replace remainA = 1 if regexm(stkcd_str, "^(000|001|002|003)")
* 创业板
replace remainA = 1 if regexm(stkcd_str, "^300")
* 科创板
replace remainA = 1 if regexm(stkcd_str, "^688")
* 北交所（按照你提供的细分保留）
replace remain = 1 if regexm(stkcd_str, "^82")         // 北交所-优先股
replace remain = 1 if regexm(stkcd_str, "^(83|87)")    // 北交所-普通股
replace remain = 1 if regexm(stkcd_str, "^88")         // 北交所-公开发行
* 最后：只保留 remainA==1 的观测（如果需要）
keep if remainA==1


**剔除部分数据
*1.金融行业数据
* 假设行业变量名为 industry
drop if regexm(csmar_listedcoinfoNnindcd, "^J")    //
* 剔除公司简称中含有 "ST" 的观测

drop if strpos(公司简称, "ST") > 0   //
drop if strmatch(公司简称,"*PT*")    //
**剔除数据所有者权益、资产总计、营业收入负数的企业
drop if FS_CombasA003000000<0      //
drop if FS_CombasA001000000<0
drop if FS_CominsB001101000<0      //

*控制变量
rename FS_CombasA001000000 total_asset
rename F100901A TobinQ
rename F101001A BM
rename FI_T1F011201A LEV
rename FI_T5F050201B ROA
rename IndDirectorRatio Inddir
rename IsDuality Duality
rename state State
drop industry_code
encode industry, gen(industry_code)

gen ln_boardsize = ln(Boardsize)
gen Size = ln(total_asset)
gen ln_firmage = ln(firmage)
replace FSSC = 0 if missing(FSSC)
gen Big4_num = .
replace Big4_num = 1 if Big4 == "Y"
replace Big4_num = 0 if Big4 == "N"
drop Big4
rename Big4_num Big4

*删除存在缺失值的观测值
drop if missing(Size)
drop if missing(ROA)
drop if missing(LEV)
drop if missing(BM)
drop if missing(ln_firmage)
drop if missing(State)
drop if missing(Big4)
drop if missing(TobinQ)
drop if missing(Inddir)
drop if missing(Duality)
drop if missing(ln_boardsize)

replace OREC_TA = 0 if missing(OREC_TA)
replace OREC_REV = 0 if missing(OREC_REV)


*重新构建FSSC

drop FSSC
gen Treat=0 if setyear==.
replace Treat=1 if Treat==.
gen Post=1 if year>=setyear
replace Post=0 if setyear==.
replace Post=0 if Post==.
gen FSSC=Treat*Post
drop Treat Post

*缩尾处理
winsor2 RPT_a_REV RPT_a_TA RPT_b_REV RPT_b_TA RPT_a1_REV RPT_a1_TA RPT_a2_REV RPT_a2_TA RPT_product_controlling_REV RPT_labor_controlling_REV RPT_product_REV RPT_labor_REV guarantee_TA guarantee_REV OREC_TA OREC_REV, cuts(1 99) replace

winsor2 Size ROA LEV BM ln_firmage  Big4 TobinQ State Inddir Duality ln_boardsize Outcap, cuts(1 99) replace
save main.dta, replace

