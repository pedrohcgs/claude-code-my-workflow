# CLAUDE.MD -- PKU-DFIIC 数据清洗项目

**项目名称：** 北京大学数字普惠金融指数（PKU-DFIIC）数据清洗  
**工具栈：** Python + Stata  
**分支：** main

---

## 核心原则

- **Plan first** — 非 trivial 任务先进 plan mode，计划存 `quality_reports/plans/`
- **Verify after** — 每步完成后核查观测数、变量数、缺失模式
- **数据不修改** — 原始值如实保留，缺失即缺失，不插补
- **[LEARN] tags** — 被纠正时，写 `[LEARN:category] wrong → right` 到 MEMORY.md

跨会话上下文在 MEMORY.md；历史计划和 session log 在 quality_reports/。

---

## 文件夹结构

```
1_Cleaned_PKU_DFIIC/
├── PKU_DFIIC_province.dta    # 最终干净数据：省级（2011-2023）
├── PKU_DFIIC_city.dta        # 最终干净数据：市级（2011-2023）
├── PKU_DFIIC_county.dta      # 最终干净数据：县级（2014-2023）
├── CLAUDE.md                 # 本文件
├── MEMORY.md                 # 重要决策记录
├── README.md                 # 数据文档：变量含义、局限性、使用示例
├── codes/                    # 所有代码，按工作顺序编号
│   ├── 01_explore.py         # Python: 读 Excel → 探索 → 存临时 .dta
│   ├── 02_clean_province.do  # Stata: 清洗省级数据
│   ├── 03_clean_city.do      # Stata: 清洗市级数据
│   └── 04_clean_county.do    # Stata: 清洗县级数据
├── data_logs/                # 所有运行产生的 log 文件
├── data_temp/                # 清洗过程中的临时 .dta 文件
└── quality_reports/          # 工作流记忆系统（Claude 自动维护）
    ├── session_logs/
    ├── plans/
    └── specs/
```

---

## 常用命令

```bash
# 运行探索脚本（从项目根目录）
python3 codes/01_explore.py

# Stata 清洗（在 Stata 中运行，路径以项目根目录为准）
# do codes/02_clean_province.do
# do codes/03_clean_city.do
# do codes/04_clean_county.do
```

---

## 原始数据

| 文件 | 路径 |
|------|------|
| Excel 原始数据 | `/Volumes/douqianbin/0_Raw/PKU_DFIIC/北京大学数字普惠金融指数（PKU-DFIIC）2011-2023.xlsx` |

**Excel Sheets：**
- `Provinces` → `data_temp/province_raw.dta`（403行 × 14列）
- `Prefecture_Level_Cities` → `data_temp/city_raw.dta`（4369行 × 16列）
- `Counties` → `data_temp/county_raw.dta`（26090行 × 17列）
- `Regionalism_Code` → `data_temp/regionalism_code_raw.dta`（3253行 × 22列）

---

## 数据集状态

| 数据集 | 输入文件 | 输出文件 | 时间跨度 | 状态 |
|--------|---------|---------|---------|------|
| 省级 | province_raw.dta | PKU_DFIIC_province.dta | 2011-2023 | 待清洗 |
| 市级 | city_raw.dta | PKU_DFIIC_city.dta | 2011-2023 | 待清洗 |
| 县级 | county_raw.dta | PKU_DFIIC_county.dta | 2014-2023 | 待清洗 |

---

## 关键数据说明

**已知缺失模式（非错误，来自原始数据）：**
- `monetary_fund`、`investment`：2011 年早期产品未上线，为空
- `credit_investigation`、`monetary_fund`：2019-2023 因监管原因未公布
- `credit_investigation`：省级 2011 起、市级早期可能为空

**行政区划代码：**
- 市级数据同时保留 `pref_code_year14`（2014年底标准）和 `pref_code_year18`（2018年标准）
- 县级统一使用 2014 年底代码（`county_code_year14`）
- 合并其他数据集时注意代码版本匹配
