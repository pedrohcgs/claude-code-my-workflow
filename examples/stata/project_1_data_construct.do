****************************************************
*数据集构造
****************************************************


*RPT识别
//Relation [关联关系] - 上市公司与关联方之间的关联关系01=上市公司的母公司02=上市公司的子公司03=与上市公司受同一母公司控制的其他企业04=对上市公司实施共同控制的投资方05=对上市公司施加重大影响的投资方06=上市公司的合营企业07=上市公司的联营企业08=上市公司的主要投资者个人及与其关系密切的家庭成员09=上市公司或其母公司的关键管理人员及其关系密切的家庭成员10=上市公司主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或者施加重大影响的企业11=上市公司的关联方之间12=其他

//1,4,5,8,9,10

//Repat [关联交易事项分类] - 根据关联交易事项进行的分类索引01=商品交易类02=资产交易类03=提供或接受劳务04=代理，委托05=资金交易06=担保，抵押07=租赁08=托管经营（管理方面）09=赠与10=非货币交易13=股权交易15=债权债务类交易17=合作项目18=许可协议19=研究与开发成果20=关键管理人员报酬 21=其他事项

*************
*关联交易主数据
*************
clear 
set excelxlsxlargefile on
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/关联交易情况/RPT_Operation.xlsx", sheet("sheet1") firstrow
drop if _n == 1 | _n == 2
gen year=substr(Reptdt,1,4)
destring year ,replace
destring Stkcd ,replace
rename Stkcd stkcd
save RPT1.dta, replace

import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/关联交易情况/RPT_Operation1.xlsx", sheet("sheet1") firstrow clear
drop if _n == 1 | _n == 2
gen year=substr(Reptdt,1,4)
destring year ,replace
destring Stkcd ,replace
rename Stkcd stkcd
save RPT2.dta, replace


import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/关联交易情况/RPT_Operation2.xlsx", sheet("sheet1") firstrow clear
drop if _n == 1 | _n == 2
gen year=substr(Reptdt,1,4)
destring year ,replace
destring Stkcd ,replace
rename Stkcd stkcd
save RPT3.dta, replace

**************
*整理数据

use RPT1.dta, clear
append using RPT2.dta
append using RPT3.dta

label variable Repart "关联方名称"
label variable Relation "关联关系编号"
label variable Annodt "公告日期"
label variable Repttype "公告类型"
label variable RalatedPartyID "关联方ID"
label variable Relation1 "报告披露关联关系"
label variable Trasub "交易性质"
label variable Direction "交易方向"
label variable Repat "关联交易事项分类"
label variable Kind "关联交易事项"
label variable Curtype "币种"
label variable Isam "关联交易涉及的金额"
label variable Pannrsm "关联交易涉及的金额占公司同类交易比例"
label variable Content "交易内容"


drop Reptdt  TransactionRank Cptcst Interest Isgplo Price Trddt Tlimit Bank Principl Ifafcprf Influence Notes
destring Relation,replace
destring Isam,replace
destring Repat,replace

drop if Curtype != "CNY"

save RPT.dta, replace


*******************
*为排除内部资本市场，构造内部交易指标，采用商品交易和接受或提供劳务两个指标
use RPT.dta, clear

gen Isam_keep = Isam if inlist(Repat, 1)
bysort stkcd year: egen RPT_product = total(Isam_keep)
drop Isam_keep
label variable RPT_product "商品交易"

gen Isam_keep = Isam if inlist(Repat, 3)
bysort stkcd year: egen RPT_labor = total(Isam_keep)
drop Isam_keep
label variable RPT_labor "接受或提供劳务"

*非大股东关联交易

gen Isam_keep = Isam if inlist(Repat, 2, 5, 13)
bysort stkcd year: egen RPT_b = total(Isam_keep)
drop Isam_keep
label variable RPT_b "分类为2、5、13的非大股东关联交易总金额"

save RPT.dta, replace



*******************
*掏空指标构建
*Relation ∈ {1,4,5,8,9,10}
*Repat ∈ {1,2,3,5,13}

*只留下和大股东相关的关联交易 01=上市公司的母公司04=对上市公司实施共同控制的投资方05=对上市公司施加重大影响的投资方08=上市公司的主要投资者个人及与其关系密切的家庭成员09=上市公司或其母公司的关键管理人员及其关系密切的家庭成员10=上市公司主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或者施加重大影响的企业
use RPT.dta, clear
keep if Relation == 1|Relation == 4|Relation == 5|Relation == 8|Relation == 9|Relation == 10


gen Isam_keep = Isam if inlist(Repat, 1)
bysort stkcd year: egen RPT_product_controlling = total(Isam_keep)
drop Isam_keep
label variable RPT_product_controlling "商品交易"

gen Isam_keep = Isam if inlist(Repat, 3)
bysort stkcd year: egen RPT_labor_controlling = total(Isam_keep)
drop Isam_keep
label variable RPT_labor_controlling "接受或提供劳务"


**定义不同口径的掏空，从小到大
*1. 仅限asset acquisition, asset sales, asset displacement, equity transfer, cash payment 即仅限Repat == 2|Repat == 5|Repat == 13

gen Isam_keep = Isam if inlist(Repat, 2, 5, 13)
bysort stkcd year: egen RPT_a = total(Isam_keep)
drop Isam_keep
label variable RPT_a "分类为2、5、13的关联交易总金额"

*2. 01=商品交易类02=资产交易类03=提供或接受劳务05=资金交易13=股权交易

*识别交易方向 Direction 1=上市公司处于卖方立场，提供交易客体 2=上市公司处于买方立场，接受交易客体
*eg 资产交易 1=出售固定资产、销售汽车、转让生产设备、出售住宅用房和车位、转让车辆 2=购买不动产、购买专利 （1是公司把东西卖给大股东，现金流入 2是公司从大股东手里买东西，现金流出）
*eg 资金交易 1提供资金，现金流出，更接近掏空 2.接受资金，现金流入
*eg 股权交易 1=出售股权、股权转让，现金流入 2=收购股权、受让股权，现金流出

destring Direction,replace
*上市公司作为卖方 Direction == 1
gen Isam_asset1 = Isam if Repat==2 & Direction==1
bysort stkcd year: egen RPT_asset1 = total(Isam_asset1)
label variable RPT_asset1 "卖方资产交易"
drop Isam_asset1

gen Isam_cash1 = Isam if Repat==5 & Direction==1
bysort stkcd year: egen RPT_cash1 = total(Isam_cash1)
label variable RPT_cash1 "卖方资金交易"
drop Isam_cash1

gen Isam_equity1 = Isam if Repat==13 & Direction==1
bysort stkcd year: egen RPT_equity1 = total(Isam_equity1)
label variable RPT_equity1 "卖方股权交易"
drop Isam_equity1


egen RPT_a1 = rowtotal(RPT_asset1 RPT_cash1 RPT_equity1)
label variable RPT_a1 "卖方关联交易（资产、资金、股权加总）"


*上市公司作为买方 Direction == 2
gen Isam_asset2 = Isam if Repat==2 & Direction==2
bysort stkcd year: egen RPT_asset2 = total(Isam_asset2)
label variable RPT_asset2 "买方资产交易"
drop Isam_asset2

gen Isam_cash2 = Isam if Repat==5 & Direction==2
bysort stkcd year: egen RPT_cash2 = total(Isam_cash2)
label variable RPT_cash2 "买方资金交易"
drop Isam_cash2


gen Isam_equity2 = Isam if Repat==13 & Direction==2
bysort stkcd year: egen RPT_equity2 = total(Isam_equity2)
label variable RPT_equity2 "买方股权交易"
drop Isam_equity2

egen RPT_a2 = rowtotal(RPT_asset2 RPT_cash2 RPT_equity2)
label variable RPT_a2 "买方关联交易（资产、资金、股权加总）"

save RPT.dta, replace

**去重

bysort stkcd year: keep if _n == 1
keep stkcd year RPT_a RPT_b RPT_asset1 RPT_cash1 RPT_equity1 RPT_asset2 RPT_cash2 RPT_equity2 RPT_a1 RPT_a2 RPT_product RPT_labor RPT_product_controlling RPT_labor_controlling
save RPT.dta, replace
****************************************************
****************************************************






****************************************************
*对外担保
****************************************************

clear 
set excelxlsxlargefile on
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/对外担保/STK_Guarantee_Main.xlsx", sheet("sheet1") firstrow

ds
local vars `r(varlist)'

foreach v of local vars {
    local lbl = `v'[1]
    label variable `v' "`lbl'"
}

drop if _n == 1 | _n == 2

gen year=substr(DeclareDate,1,4)
destring year ,replace
destring Symbol ,replace
rename Symbol stkcd

save guarantee.dta, replace

*只保留和大股东相关的担保 RelateToGuaranteeID [被担保人与上市公司关系编码] - P7501 前者是后者的母公司 P7504 前者是与第三方对后者共同控制的投资方 P7505 前者对后者实施重大影响 P7508 前者是后者的主要投资者个人及与其关系密切的家庭成员 P7509 前者是后者或后者母公司的关键管理人员及其关系密切的家庭成员 P7510 前者是后者的主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或者施加重大影响的企业 

keep if inlist(RelateToGuaranteeID, "P7501","P7504","P7505","P7508","P7509","P7510")
drop if CurrencyCode != "CNY"

**定义不同口径的掏空
*所有类型的担保
destring ActualGuaranteeAmount, replace
bysort stkcd year: egen guarantee = total(ActualGuaranteeAmount)
label variable guarantee "实际担保额加总"


*只留下有关的变量
keep stkcd guarantee year
bysort stkcd year: keep if _n == 1
save guarantee.dta, replace

****************************************************
****************************************************






****************************************************
*实际控制人
****************************************************
clear
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/上市公司控制人文件/HLD_Contrshr.xlsx", sheet("sheet1") firstrow


ds
local vars `r(varlist)'

foreach v of local vars {
    local lbl = `v'[1]
    label variable `v' "`lbl'"
}

drop if _n == 1 | _n == 2



gen year=substr(Reptdt,1,4)
destring year ,replace
destring Stkcd ,replace
rename Stkcd stkcd
drop S0701a S0703a S0704a S0705a Reptdt
save controller.dta, replace
//开始清洗
drop if missing(S0702b) //剔除没有实控人性质的样本
//去掉重复样本 股票代码 实控人名称 实控人性质 年份 删掉的是有多个直接控制人的样本
bysort stkcd S0701b S0702b year: keep if _n == 1
//现在还有重复数据，因为实际控制人可能不止一个人。需要的是控制人性质，所以性质相同的样本只留下一个 
bysort stkcd S0702b year: keep if _n == 1
//此时发现依然stkcd和year的组合有重复值，证明有的公司有多种性质的控制人,或有的观测值把好几个实控人写在一起
//剔除实控人性质相同但都写在一起的观测，即只保留 S0702b 长度为4的观测
keep if strlen(S0702b) == 4
//剩下重复stkcd year就是有多个不同性质的实控人，把这些统一标注出来
//实控人只有一个or性质相同的为1（多个实控人性质相同只保留一条数据) 多个实控人且性质有不同的为0
gen controltype = 1
label variable controltype "实际控制人性质"
bysort stkcd year: replace controltype = 0 if _N > 1
drop if controltype == 0 //现在有53908条不重复的数据
save controller.dta, replace

****************************************************
****************************************************




****************************************************
*资本支出
****************************************************
clear
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/资本支出/CSR_Finidx.xlsx", sheet("sheet1") firstrow


gen year=substr(Accper,1,4)
drop if _n == 1 | _n == 2

destring year ,replace
destring Stkcd ,replace
rename Stkcd stkcd
label variable Outcap "资本支出"
destring Outcap ,replace

drop Accper
save capex.dta, replace


****************************************************
*IV 通信能力
****************************************************


import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/分省份通信能力/CRE_Tpt10.xlsx", sheet("sheet1") firstrow

ds
local vars `r(varlist)'

foreach v of local vars {
    local lbl = `v'[1]
    label variable `v' "`lbl'"
}

drop if _n == 1 | _n == 2


gen year=substr(Sgnyea,1,4)
destring year ,replace
rename Prvcnm_id PROVINCECODE

destring Tpt1001 ,replace
destring Tpt1002 ,replace
destring Tpt1003 ,replace
destring Tpt1004 ,replace
destring Tpt1005 ,replace
destring Tpt1006 ,replace
destring Tpt1007 ,replace
destring PROVINCECODE ,replace

drop Sgnyea Prvcnm

save commu.dta








****************************************************
*大股东委派
****************************************************
import excel "/Users/lixiaorui/Downloads/Tunneling&political connection/code&data/实际控制人委派董监高/MC_ActualControllerNetwork.xlsx", sheet("sheet1") firstrow clear

ds
local vars `r(varlist)'

foreach v of local vars {
    local lbl = `v'[1]
    label variable `v' "`lbl'"
}

drop if _n == 1 | _n == 2


gen year=substr(enddate,1,4)
destring year ,replace
rename stockcode stkcd

destring stkcd ,replace
destring ownershipproportion ,replace
destring controlproportion ,replace
destring seperation ,replace
destring isappointseexecutive ,replace
destring isappointdirector ,replace
destring isappointsupervisor ,replace

//对于有多个实控人的情况，只要有一个实控人委派了，就认为委派了

bysort stkcd year: egen assign_exe = max(isappointseexecutive)
bysort stkcd year: egen assign_dir = max(isappointdirector)
bysort stkcd year: egen assign_sup = max(isappointsupervisor)

label variable assign_exe "任一实控人委派高管"
label variable assign_dir "任一实控人委派董事"
label variable assign_sup "任一实控人委派监事"

//两权分离率取大
bysort stkcd year: egen seperation1 = max(seperation)
label variable seperation1 "stkcd-year组内最大两权分离度"

//两权分离率取所有权最大的
bysort stkcd year: egen max_controller = max(controlproportion)
gen seperation_tmp = seperation if controlproportion == max_controller
bysort stkcd year: egen seperation2 = max(seperation_tmp)
drop max_controller seperation_tmp
label variable seperation2 "stkcd-year组内控制权最大的实控人的两权分离度"


drop actualcontrollerid actualcontrollername isconcertedaction actualcontrollernatureid ownershipproportion controlproportion seperation isappointseexecutive isappointdirector isappointsupervisor enddate
bysort stkcd year: keep if _n == 1

save assign.dta, replace


