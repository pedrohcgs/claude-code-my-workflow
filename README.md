# 北京大学数字普惠金融指数（PKU-DFIIC）清洗数据

**数据来源：** 北京大学数字金融研究中心 & 蚂蚁科技集团研究院  
**时间跨度：** 省级/市级 2011–2023；县级 2014–2023  
**清洗日期：** 2026-05-22  

---

## 引用

使用本数据请注明来源，并引用：

> 郭峰、王靖一、王芳、孔涛、张勋、程志云，《测度中国数字普惠金融发展：指数编制与空间特征》，《经济学季刊》，2020年第19卷第4期，第1401–1418页。

英文引用：
> Guo, F., Wang, J., Wang, F., Kong, T., Zhang, X., & Cheng, Z. (2020). Measuring China's Digital Financial Inclusion: Index Compilation and Spatial Characteristics. *China Economic Quarterly*, 19(4), 1401–1418.

---

## 输出文件

| 文件 | 地理层级 | 时间跨度 | 观测数 | 面板类型 |
|------|---------|---------|-------|---------|
| `PKU_DFIIC_province.dta` | 省级（31省） | 2011–2023 | 403 | 平衡面板 |
| `PKU_DFIIC_city.dta` | 市级（~337城市） | 2011–2023 | 4369 | 近似平衡面板 |
| `PKU_DFIIC_county.dta` | 县级（~2800县） | 2014–2023 | 26090 | 非平衡面板 |

**面板 ID：**
- 省级：`prov_code`（2位省级代码）
- 市级：`pref_code_year14`（与县级一致，推荐合并用）
- 县级：`county_code_year14`（6位代码，2014年底标准）

---

## 变量字典

### 通用变量（三个数据集均有）

| 变量名 | 中文含义 | 说明 |
|--------|---------|------|
| `year` | 年份 | 2011-2023（省/市）；2014-2023（县） |
| `index_aggregate` | 数字普惠金融总指数 | 综合指数 |
| `coverage_breadth` | 覆盖广度 | 数字金融覆盖广度分指数 |
| `usage_depth` | 使用深度 | 数字金融使用深度分指数 |
| `payment` | 支付业务指数 | 支付类业务分指数 |
| `insurance` | 保险业务指数 | 保险类业务分指数 |
| `monetary_fund` | 货币基金业务指数 | **2019–2023 因监管原因未公布（缺失）** |
| `investment` | 投资业务指数 | 早期年份未上线（部分缺失） |
| `credit` | 信贷业务指数 | 信贷类业务分指数 |
| `credit_investigation` | 信用业务指数 | **2019–2023 因监管原因未公布（缺失）** |
| `digitization_level` | 数字化程度 | 普惠金融数字化程度分指数 |

### 省级特有变量（`PKU_DFIIC_province.dta`）

| 变量名 | 含义 |
|--------|------|
| `prov_name` | 省份名称（中文） |
| `prov_name_eng` | 省份名称（英文） |
| `prov_code` | 省级行政区划代码（2位） |

### 市级特有变量（`PKU_DFIIC_city.dta`）

| 变量名 | 含义 |
|--------|------|
| `pref_name_year18` | 城市名称（2018年代码标准，中文） |
| `pref_name_year18_eng` | 城市名称（2018年代码标准，英文） |
| `pref_code_year18` | 城市行政区划代码（2018年标准） |
| `pref_name_year14` | 城市名称（2014年代码标准，中文） |
| `pref_code_year14` | 城市行政区划代码（2014年底标准）**推荐用于合并** |

### 县级特有变量（`PKU_DFIIC_county.dta`）

| 变量名 | 含义 |
|--------|------|
| `county_name_year14` | 县域名称（2014年底标准） |
| `county_code_year14` | 县域行政区划代码（6位，2014年底标准） |
| `prov_code` | 所属省级代码（2位） |
| `prov_name` | 所属省份名称（中文） |
| `pref_code` | 所属市级代码（通常4位，2014年标准） |
| `pref_name` | 所属城市名称（中文） |

---

## 缺失值说明

| 变量 | 省级缺失率 | 市级缺失率 | 县级缺失率 | 原因 |
|------|---------|---------|---------|------|
| `monetary_fund` | 53.8% | 53.8% | 54.4% | 2019+未公布；早期产品未上线 |
| `credit_investigation` | 69.2% | 69.2% | 61.2% | 2019+未公布；早期可能未覆盖 |
| `investment` | 23.1% | 23.1% | 0% | 早期（2011-2013）产品未上线 |

---

## 已知数据局限性

### 1. 子指数缺失（非数据错误）
`monetary_fund`（货币基金）和 `credit_investigation`（信用）分指数在 2019–2023 年因监管和公司数据安全审核原因未对外公布，表现为缺失值。这是原始数据本身的局限，非清洗错误。

### 2. 县级数据负值（原始数据如此）
县级数据部分观测的子指数存在负值（如 `digitization_level` 最小值 -165.39，`payment` 最小值 -70.17）。这是原始发布数据中已有的极端值，本数据集如实保留，未做修改。分析时建议检查异常值分布。

### 3. 市级双代码体系
2011–2023 年间，部分城市经历"撤地设市"或"县改区"等行政调整，导致同一城市在 2014 年和 2018 年使用不同的行政区划代码。市级数据同时保留两套代码：
- `pref_code_year14`：2014年底标准，与县级数据代码一致，**推荐用于与县级或早期数据合并**
- `pref_code_year18`：2018年标准，**推荐用于与近期数据（2018后发布）合并**

### 4. 新疆生产建设兵团（XPCC）代码问题
县级数据中，新疆生产建设兵团（XPCC）所属县域的 `pref_code` 呈现 6 位代码（最大值 659010），而非标准 4 位地级市代码。这是 XPCC 特殊行政体制导致的已知特征。

### 5. 县级数据覆盖扩展
2014–2015 年县级覆盖约 1754 个县，2016 年起扩展至约 2800 个县，导致面板为非平衡结构。

### 6. 港澳台数据缺失
港澳台地区数据未包含在本指数中。

---

## 代码结构

```
codes/
├── 01_explore.py        ← Python: 读 Excel，探索数据，存 data_temp/*.dta
├── 02_clean_province.do ← Stata: 清洗省级数据
├── 03_clean_city.do     ← Stata: 清洗市级数据
└── 04_clean_county.do   ← Stata: 清洗县级数据
```

**运行顺序：**
1. 在项目根目录运行：`python3 codes/01_explore.py`
2. 在 Stata 中依次运行（工作目录设为项目根目录）：
   ```stata
   do codes/02_clean_province.do
   do codes/03_clean_city.do
   do codes/04_clean_county.do
   ```

---

## 使用示例（Stata）

```stata
* 加载省级数据
use "PKU_DFIIC_province.dta", clear
xtset prov_code year

* 与其他省级数据合并（以省份代码为键）
merge 1:1 prov_code year using "your_data.dta"

* 加载市级数据并合并（以2014年代码为键）
use "PKU_DFIIC_city.dta", clear
merge 1:1 pref_code_year14 year using "your_city_data.dta"

* 加载县级数据
use "PKU_DFIIC_county.dta", clear
xtset county_code_year14 year   // 非平衡面板
```

---

## 原始数据路径

原始 Excel 文件存于只读目录，不纳入版本控制：  
`/Volumes/douqianbin/0_Raw/PKU_DFIIC/北京大学数字普惠金融指数（PKU-DFIIC）2011-2023.xlsx`
