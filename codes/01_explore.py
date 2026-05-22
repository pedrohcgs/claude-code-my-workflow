"""
01_explore.py
读取 PKU-DFIIC Excel 原始数据，输出探索报告，并将各 Sheet 存为临时 .dta 文件。

运行方式（从项目根目录）：
    python3 codes/01_explore.py

输出：
    data_logs/01_explore_log.txt   -- 探索报告
    data_temp/province_raw.dta     -- 省级原始数据
    data_temp/city_raw.dta         -- 市级原始数据
    data_temp/county_raw.dta       -- 县级原始数据
    data_temp/regionalism_code_raw.dta -- 行政区划代码对照表
"""

import sys
import os
import pandas as pd
import pyreadstat
from pathlib import Path
from datetime import datetime

# ── 路径配置 ──────────────────────────────────────────────────────────────────
RAW_EXCEL = Path("/Volumes/douqianbin/0_Raw/PKU_DFIIC/北京大学数字普惠金融指数（PKU-DFIIC）2011-2023.xlsx")
PROJECT_ROOT = Path(__file__).parent.parent
DATA_TEMP = PROJECT_ROOT / "data_temp"
DATA_LOGS = PROJECT_ROOT / "data_logs"
LOG_FILE = DATA_LOGS / "01_explore_log.txt"

DATA_TEMP.mkdir(exist_ok=True)
DATA_LOGS.mkdir(exist_ok=True)

# ── Sheet → 输出文件名映射 ────────────────────────────────────────────────────
SHEET_MAP = {
    "Provinces":              "province_raw.dta",
    "Prefecture_Level_Cities": "city_raw.dta",
    "Counties":               "county_raw.dta",
    "Regionalism_Code":       "regionalism_code_raw.dta",
}


class Tee:
    """同时写 stdout 和文件。"""
    def __init__(self, filepath):
        self.file = open(filepath, "w", encoding="utf-8")
        self.stdout = sys.stdout

    def write(self, data):
        self.stdout.write(data)
        self.file.write(data)

    def flush(self):
        self.stdout.flush()
        self.file.flush()

    def close(self):
        self.file.close()


def section(title: str):
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}")


def explore_sheet(df: pd.DataFrame, name: str):
    """输出单个 Sheet 的探索报告。"""
    section(f"Sheet: {name}")
    print(f"维度: {df.shape[0]} 行 × {df.shape[1]} 列")
    print(f"\n列名:\n  {list(df.columns)}")

    # dtype
    print(f"\n数据类型:")
    for col, dt in df.dtypes.items():
        print(f"  {col:<35} {dt}")

    # 缺失值
    miss = df.isnull().sum()
    miss_pct = (miss / len(df) * 100).round(1)
    print(f"\n缺失值统计:")
    for col in df.columns:
        if miss[col] > 0:
            print(f"  {col:<35} {miss[col]:>6} 缺失 ({miss_pct[col]}%)")
    if miss.sum() == 0:
        print("  无缺失值")

    # 年份分布（如有 year 列）
    if "year" in df.columns:
        print(f"\n各年份观测数:")
        counts = df["year"].value_counts().sort_index()
        for yr, cnt in counts.items():
            print(f"  {int(yr)}: {cnt}")

    # 数值型变量描述统计
    num_cols = df.select_dtypes(include="number").columns.tolist()
    if num_cols:
        print(f"\n数值型变量描述统计:")
        desc = df[num_cols].describe().round(2)
        print(desc.to_string())


def sanitize_col_name(name: str) -> str:
    """将列名转为 Stata 合法变量名：去空格/冒号/点，截取前 32 字符。"""
    import re
    name = re.sub(r"[\s:./\\]", "_", str(name))   # 替换非法字符
    name = re.sub(r"_+", "_", name).strip("_")      # 合并多个下划线
    return name[:32]


def save_dta(df: pd.DataFrame, out_path: Path, sheet_name: str):
    """用 pyreadstat 将 DataFrame 存为 .dta 文件。"""
    df_out = df.copy()

    # 列名合法化（Stata 不允许空格/冒号等）
    new_cols = {}
    for col in df_out.columns:
        new_name = sanitize_col_name(col)
        if new_name != col:
            new_cols[col] = new_name
    if new_cols:
        df_out.rename(columns=new_cols, inplace=True)
        print(f"  列名已规范化: {new_cols}")

    # str/object 列统一转 str
    for col in df_out.select_dtypes(include=["object", "str"]).columns:
        df_out[col] = df_out[col].astype(str).replace("None", "")

    pyreadstat.write_dta(df_out, str(out_path))
    print(f"\n  → 已保存: {out_path.relative_to(PROJECT_ROOT)} ({len(df_out)} 行)")


def main():
    tee = Tee(LOG_FILE)
    sys.stdout = tee

    print(f"PKU-DFIIC 数据探索报告")
    print(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"原始文件: {RAW_EXCEL}")

    # 确认文件存在
    if not RAW_EXCEL.exists():
        print(f"\n[ERROR] 找不到原始文件: {RAW_EXCEL}")
        sys.exit(1)

    # 读取所有目标 Sheet
    section("读取 Excel 文件")
    all_sheets = pd.read_excel(RAW_EXCEL, sheet_name=list(SHEET_MAP.keys()))
    print(f"成功读取 {len(all_sheets)} 个 Sheet")

    # 逐 Sheet 探索 + 保存
    for sheet_name, dta_filename in SHEET_MAP.items():
        df = all_sheets[sheet_name]
        explore_sheet(df, sheet_name)
        out_path = DATA_TEMP / dta_filename
        save_dta(df, out_path, sheet_name)

    # 汇总
    section("汇总")
    print("临时 .dta 文件已保存至 data_temp/:")
    for dta_filename in SHEET_MAP.values():
        p = DATA_TEMP / dta_filename
        size_kb = p.stat().st_size / 1024
        print(f"  {dta_filename:<40} {size_kb:>8.1f} KB")

    print(f"\nLog 文件: {LOG_FILE.relative_to(PROJECT_ROOT)}")
    print("\n[完成] 请继续在 Stata 中运行 02_clean_province.do 等脚本。")

    sys.stdout = tee.stdout
    tee.close()


if __name__ == "__main__":
    main()
