/*
04_clean_county.do
清洗 PKU-DFIIC 县级数据（2014-2023）

运行方式（从项目根目录）：
    do codes/04_clean_county.do

输入：  data_temp/county_raw.dta
输出：  PKU_DFIIC_county.dta（根目录）
Log：   data_logs/04_clean_county.log

说明：
    县级数据时间跨度为 2014-2023（省级和市级为 2011-2023）。
    行政区划代码统一以 2014 年底标准为准。
    面板为非平衡面板（部分县域有缺失年份），属正常情况。
    含省级、市级、县级三层代码，可直接与上层数据合并。
*/

clear all
set more off

* ── 路径设置 ─────────────────────────────────────────────────────────────────
local input   "data_temp/county_raw.dta"
local output  "PKU_DFIIC_county.dta"
local logfile "data_logs/04_clean_county.log"

log using "`logfile'", replace text

di "============================================================"
di "  PKU-DFIIC 县级数据清洗"
di "  `c(current_date)' `c(current_time)'"
di "============================================================"

* ── 1. 读入数据 ──────────────────────────────────────────────────────────────
use "`input'", clear
di "读入数据：`=_N' 行 × `=c(k)' 列"

* ── 2. 核验观测数 ────────────────────────────────────────────────────────────
di _newline "=== 核验观测数 ==="
* ~2800 县 × 10 年 = ~28000，实际 26090（部分县域缺失年份正常）
di "实际观测数：`=_N'"
di "实际观测数：`=_N'（预期范围 [25000, 29000]）"
assert _N >= 25000 & _N <= 29000
di "PASS: 观测数在预期范围内"

* ── 3. 核验年份范围 ──────────────────────────────────────────────────────────
di _newline "=== 年份分布 ==="
assert year >= 2014 & year <= 2023
tab year

* ── 4. 核验县域数量 ──────────────────────────────────────────────────────────
di _newline "=== 县域数量核查 ==="
qui levelsof county_code_year14, local(counties)
di "唯一县域数（2014年代码）：`: word count `counties''"

* ── 5. 检查重复 ──────────────────────────────────────────────────────────────
di _newline "=== 重复行检查（year × county_code_year14）==="
duplicates report year county_code_year14
local n_unique = r(unique_value)
duplicates list year county_code_year14
di "唯一组合数：`n_unique'，总行数：`=_N'"
assert `n_unique' == _N
di "PASS: 无重复（year × county_code_year14）"

* ── 6. 核验层级代码一致性 ────────────────────────────────────────────────────
di _newline "=== 层级代码检查 ==="
* 省级代码应在 [11, 91]
assert prov_code >= 11 & prov_code <= 91
di "PASS: prov_code 范围正常"
* 市级代码：通常4位，新疆生产建设兵团等可能为6位，用宽松范围
assert pref_code >= 1000 & pref_code <= 999999
di "PASS: pref_code 范围正常（含特殊地区代码）"
* 县级代码应为 6 位
assert county_code_year14 >= 100000 & county_code_year14 <= 999999
di "PASS: county_code_year14 范围正常"

* ── 7. 指数值域描述（指数值不限于0-100，随数字金融发展逐年增长）──────────
di _newline "=== 指数值域描述 ==="
foreach var of varlist index_aggregate coverage_breadth usage_depth ///
    payment insurance investment credit digitization_level ///
    monetary_fund credit_investigation {
    qui summarize `var'
    di "`var': min=`r(min)', max=`r(max)', N非缺失=`r(N)'"
}
* 检查明显异常值（< -500 或 > 5000 视为数据错误）
foreach var of varlist index_aggregate coverage_breadth usage_depth ///
    payment insurance investment credit digitization_level {
    qui count if !missing(`var') & (`var' < -500 | `var' > 5000)
    if r(N) > 0 {
        di "WARNING: `var' 有 `=r(N)' 个值超出合理范围 [-500, 5000]，请核查"
    }
}

* ── 8. 记录缺失模式 ──────────────────────────────────────────────────────────
di _newline "=== 缺失值统计 ==="
foreach var of varlist monetary_fund credit_investigation investment {
    di "`var' 各年缺失情况："
    tab year if missing(`var')
}
* 统计各年出现的县域数（了解面板结构）
di _newline "各年县域覆盖数："
bysort year: gen _n_yr = _N
tab year if _n == 1
drop _n_yr

* ── 9. 变量标签 ──────────────────────────────────────────────────────────────
label variable year                 "年份 / Year"
label variable county_name_year14   "县域名称（2014年底标准）/ County name, 2014 standard"
label variable county_code_year14   "县域行政区划代码（2014年底标准）/ County code, 2014 standard"
label variable prov_code            "省级行政区划代码 / Province code"
label variable prov_name            "省份名称（中文）/ Province name (Chinese)"
label variable pref_code            "市级行政区划代码（2014年标准）/ Prefecture code, 2014 standard"
label variable pref_name            "城市名称（中文）/ City name (Chinese)"
label variable index_aggregate      "数字普惠金融总指数 / DFI aggregate index"
label variable coverage_breadth     "覆盖广度 / Coverage breadth"
label variable usage_depth          "使用深度 / Usage depth"
label variable payment              "支付业务指数 / Payment sub-index"
label variable insurance            "保险业务指数 / Insurance sub-index"
label variable monetary_fund        "货币基金指数（2019+未公布）/ Monetary fund sub-index (not published 2019+)"
label variable investment           "投资业务指数 / Investment sub-index"
label variable credit               "信贷业务指数 / Credit sub-index"
label variable credit_investigation "信用业务指数（2019+未公布）/ Credit investigation sub-index (not published 2019+)"
label variable digitization_level   "数字化程度 / Digitization level"

* 数据集注释
notes _dta: "PKU数字普惠金融指数 县级数据 2014-2023"
notes _dta: "来源：北京大学数字金融研究中心 & 蚂蚁科技集团研究院"
notes _dta: "引用：郭峰等，《经济学季刊》2020年第19卷第4期"
notes _dta: "面板类型：非平衡面板（部分县域有缺失年份，属正常情况）"
notes _dta: "面板ID：county_code_year14（2014年底行政区划代码标准）"
notes _dta: "含prov_code/pref_code可直接与省级/市级数据合并"
notes _dta: "缺失说明：monetary_fund和credit_investigation因监管原因2019-2023未公布"
notes _dta: "清洗脚本：codes/04_clean_county.do"

* ── 10. 设置面板结构 + 排序 ──────────────────────────────────────────────────
di _newline "=== 面板结构 ==="
xtset county_code_year14 year
sort county_code_year14 year

* ── 11. 描述统计 ─────────────────────────────────────────────────────────────
di _newline "=== 最终描述统计 ==="
summarize

* ── 12. 保存 ─────────────────────────────────────────────────────────────────
save "`output'", replace
di _newline "=== 保存完成 ==="
di "输出：`output'"
di "观测数：`=_N'，变量数：`=c(k)'"

log close
di "Log 已保存：`logfile'"
