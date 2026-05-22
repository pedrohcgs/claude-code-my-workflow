/*
02_clean_province.do
清洗 PKU-DFIIC 省级数据（2011-2023）

运行方式（从项目根目录，或在 Stata 中设好工作目录）：
    do codes/02_clean_province.do

输入：  data_temp/province_raw.dta
输出：  PKU_DFIIC_province.dta（根目录）
Log：   data_logs/02_clean_province.log
*/

clear all
set more off

* ── 路径设置 ─────────────────────────────────────────────────────────────────
* 以项目根目录为工作目录运行本脚本
local input   "data_temp/province_raw.dta"
local output  "PKU_DFIIC_province.dta"
local logfile "data_logs/02_clean_province.log"

log using "`logfile'", replace text

di "============================================================"
di "  PKU-DFIIC 省级数据清洗"
di "  `c(current_date)' `c(current_time)'"
di "============================================================"

* ── 1. 读入数据 ──────────────────────────────────────────────────────────────
use "`input'", clear
di "读入数据：`=_N' 行 × `=c(k)' 列"

* ── 2. 核验观测数 ────────────────────────────────────────────────────────────
di _newline "=== 核验观测数 ==="
* 31 省 × 13 年（2011-2023）= 403
di "实际观测数：`=_N'（预期 403，31省 × 13年）"
assert _N == 403
di "PASS: 观测数 = 403"

* ── 3. 核验年份范围 ──────────────────────────────────────────────────────────
di _newline "=== 年份分布 ==="
assert year >= 2011 & year <= 2023
tab year

* ── 4. 检查重复 ──────────────────────────────────────────────────────────────
di _newline "=== 重复行检查（year × prov_code）==="
duplicates report year prov_code
local n_unique = r(unique_value)
duplicates list year prov_code
di "唯一组合数：`n_unique'，总行数：`=_N'"
assert `n_unique' == _N
di "PASS: 无重复"

* ── 5. 指数值域描述（指数值不限于0-100，随数字金融发展逐年增长）──────────
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

* ── 6. 记录缺失模式 ──────────────────────────────────────────────────────────
di _newline "=== 缺失值统计 ==="
di "monetary_fund 各年缺失情况："
tab year if missing(monetary_fund)
di "credit_investigation 各年缺失情况："
tab year if missing(credit_investigation)
di "investment 各年缺失情况："
tab year if missing(investment)

* ── 7. 变量标签 ──────────────────────────────────────────────────────────────
label variable year               "年份 / Year"
label variable prov_name          "省份名称（中文）/ Province name (Chinese)"
label variable prov_name_eng      "省份名称（英文）/ Province name (English)"
label variable prov_code          "省级行政区划代码 / Province code"
label variable index_aggregate    "数字普惠金融总指数 / DFI aggregate index"
label variable coverage_breadth   "覆盖广度 / Coverage breadth"
label variable usage_depth        "使用深度 / Usage depth"
label variable payment            "支付业务指数 / Payment sub-index"
label variable insurance          "保险业务指数 / Insurance sub-index"
label variable monetary_fund      "货币基金指数（2019+未公布）/ Monetary fund sub-index (not published 2019+)"
label variable investment         "投资业务指数 / Investment sub-index"
label variable credit             "信贷业务指数 / Credit sub-index"
label variable credit_investigation "信用业务指数（2019+未公布）/ Credit investigation sub-index (not published 2019+)"
label variable digitization_level "数字化程度 / Digitization level"

* 数据集注释
notes _dta: "PKU数字普惠金融指数 省级数据 2011-2023"
notes _dta: "来源：北京大学数字金融研究中心 & 蚂蚁科技集团研究院"
notes _dta: "引用：郭峰等，《经济学季刊》2020年第19卷第4期"
notes _dta: "缺失说明：monetary_fund和credit_investigation因监管原因2019-2023未公布"
notes _dta: "清洗脚本：codes/02_clean_province.do"

* ── 8. 设置面板结构 + 排序 ───────────────────────────────────────────────────
di _newline "=== 面板结构 ==="
xtset prov_code year
sort prov_code year

* ── 9. 描述统计 ──────────────────────────────────────────────────────────────
di _newline "=== 最终描述统计 ==="
summarize

* ── 10. 保存 ─────────────────────────────────────────────────────────────────
save "`output'", replace
di _newline "=== 保存完成 ==="
di "输出：`output'"
di "观测数：`=_N'，变量数：`=c(k)'"

log close
di "Log 已保存：`logfile'"
