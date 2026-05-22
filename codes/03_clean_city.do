/*
03_clean_city.do
清洗 PKU-DFIIC 市级数据（2011-2023）

运行方式（从项目根目录）：
    do codes/03_clean_city.do

输入：  data_temp/city_raw.dta
输出：  PKU_DFIIC_city.dta（根目录）
Log：   data_logs/03_clean_city.log

说明：
    市级数据同时保留 2014 年和 2018 年两套行政区划代码，
    因部分城市在此期间经历"撤地设市"或"县改区"调整。
    合并其他数据时请注意选用与目标数据匹配的代码版本。
*/

clear all
set more off

* ── 路径设置 ─────────────────────────────────────────────────────────────────
local input   "data_temp/city_raw.dta"
local output  "PKU_DFIIC_city.dta"
local logfile "data_logs/03_clean_city.log"

log using "`logfile'", replace text

di "============================================================"
di "  PKU-DFIIC 市级数据清洗"
di "  `c(current_date)' `c(current_time)'"
di "============================================================"

* ── 1. 读入数据 ──────────────────────────────────────────────────────────────
use "`input'", clear
di "读入数据：`=_N' 行 × `=c(k)' 列"

* ── 2. 核验观测数 ────────────────────────────────────────────────────────────
di _newline "=== 核验观测数 ==="
* 337 城市 × 13 年 ≈ 4381，实际约 4369（部分城市有缺失）
di "实际观测数：`=_N'"
di "实际观测数：`=_N'（预期范围 [4300, 4400]）"
assert _N >= 4300 & _N <= 4400
di "PASS: 观测数在预期范围内"

* ── 3. 核验年份范围 ──────────────────────────────────────────────────────────
di _newline "=== 年份分布 ==="
assert year >= 2011 & year <= 2023
tab year

* ── 4. 核验城市数量 ──────────────────────────────────────────────────────────
di _newline "=== 城市数量核查 ==="
qui levelsof pref_code_year14, local(cities14)
di "2014年代码口径唯一城市数：`: word count `cities14''"
qui levelsof pref_code_year18, local(cities18)
di "2018年代码口径唯一城市数：`: word count `cities18''"

* ── 5. 检查重复 ──────────────────────────────────────────────────────────────
di _newline "=== 重复行检查（year × pref_code_year14）==="
duplicates report year pref_code_year14
local n_unique = r(unique_value)
duplicates list year pref_code_year14
di "唯一组合数：`n_unique'，总行数：`=_N'"
assert `n_unique' == _N
di "PASS: 无重复（year × pref_code_year14）"

* ── 6. 指数值域描述（指数值不限于0-100，随数字金融发展逐年增长）──────────
di _newline "=== 指数值域描述 ==="
foreach var of varlist index_aggregate coverage_breadth usage_depth ///
    payment insurance investment credit digitization_level ///
    monetary_fund credit_investigation {
    qui summarize `var'
    di "`var': min=`r(min)', max=`r(max)', N非缺失=`r(N)'"
}
* 检查明显异常值
foreach var of varlist index_aggregate coverage_breadth usage_depth ///
    payment insurance investment credit digitization_level {
    qui count if !missing(`var') & (`var' < -500 | `var' > 5000)
    if r(N) > 0 {
        di "WARNING: `var' 有 `=r(N)' 个值超出合理范围 [-500, 5000]，请核查"
    }
}
foreach var of varlist monetary_fund credit_investigation {
    qui count if !missing(`var') & (`var' < -500 | `var' > 5000)
    if r(N) > 0 {
        di "WARNING: `var' 有 `=r(N)' 个非缺失值超出合理范围"
    }
    else {
        di "PASS: `var' 非缺失值值域正常"
    }
}

* ── 7. 记录缺失模式 ──────────────────────────────────────────────────────────
di _newline "=== 缺失值统计 ==="
foreach var of varlist monetary_fund credit_investigation investment {
    di "`var' 各年缺失情况："
    tab year if missing(`var')
}

* ── 8. 变量标签 ──────────────────────────────────────────────────────────────
label variable year                  "年份 / Year"
label variable pref_name_year18      "城市名称2018年标准（中文）/ City name, 2018 code standard"
label variable pref_name_year18_eng  "城市名称2018年标准（英文）/ City name English, 2018 standard"
label variable pref_code_year18      "城市行政区划代码（2018年标准）/ Prefecture code, 2018 standard"
label variable pref_name_year14      "城市名称2014年标准（中文）/ City name, 2014 code standard"
label variable pref_code_year14      "城市行政区划代码（2014年标准）/ Prefecture code, 2014 standard"
label variable index_aggregate       "数字普惠金融总指数 / DFI aggregate index"
label variable coverage_breadth      "覆盖广度 / Coverage breadth"
label variable usage_depth           "使用深度 / Usage depth"
label variable payment               "支付业务指数 / Payment sub-index"
label variable insurance             "保险业务指数 / Insurance sub-index"
label variable monetary_fund         "货币基金指数（2019+未公布）/ Monetary fund sub-index (not published 2019+)"
label variable investment            "投资业务指数 / Investment sub-index"
label variable credit                "信贷业务指数 / Credit sub-index"
label variable credit_investigation  "信用业务指数（2019+未公布）/ Credit investigation sub-index (not published 2019+)"
label variable digitization_level    "数字化程度 / Digitization level"

* 数据集注释
notes _dta: "PKU数字普惠金融指数 市级数据 2011-2023"
notes _dta: "来源：北京大学数字金融研究中心 & 蚂蚁科技集团研究院"
notes _dta: "引用：郭峰等，《经济学季刊》2020年第19卷第4期"
notes _dta: "面板ID建议使用：pref_code_year14（与县域数据一致）"
notes _dta: "pref_code_year18适用于合并2018年后发布的数据"
notes _dta: "部分城市因撤地设市/县改区，同一城市2014与2018代码不同"
notes _dta: "缺失说明：monetary_fund和credit_investigation因监管原因2019-2023未公布"
notes _dta: "清洗脚本：codes/03_clean_city.do"

* ── 9. 设置面板结构 + 排序 ───────────────────────────────────────────────────
di _newline "=== 面板结构 ==="
xtset pref_code_year14 year
sort pref_code_year14 year

* ── 10. 描述统计 ─────────────────────────────────────────────────────────────
di _newline "=== 最终描述统计 ==="
summarize

* ── 11. 保存 ─────────────────────────────────────────────────────────────────
save "`output'", replace
di _newline "=== 保存完成 ==="
di "输出：`output'"
di "观测数：`=_N'，变量数：`=c(k)'"

log close
di "Log 已保存：`logfile'"
