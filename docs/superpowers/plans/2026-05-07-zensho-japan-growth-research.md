# Zensho Japan Growth Research Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a source-backed Chinese research memo answering whether Zensho's Japan domestic market grew in FY2023-FY2025, which segments/brands drove it, and whether growth came from store openings or SSSG.

**Architecture:** Create one self-contained research folder under the existing restaurant-chain overseas research workspace. Keep raw/source files in `source_files/`, reproducible numeric outputs in `tables/`, and the narrative in `memo_zensho_japan_growth.md` with a separate `source_log.md` for auditability.

**Tech Stack:** macOS shell, `curl`, bundled Python 3 with `pandas` when available, Markdown, CSV, official Zensho IR PDFs/HTML pages, and the provided CIQ `.xls`.

---

## File Structure

Research root:

`/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/`

Files to create or update:

- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/CIQ_Zensho_Financials_Segments_original.xls`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_41st_asr_en_fy2023.pdf`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_42nd_asr_en_fy2024.pdf`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_43rd_asr_en_fy2025.pdf`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_fy2024_results_en.pdf`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_fy2025_results_en.pdf`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/sukiya_monthly_fy2024.html`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/sukiya_monthly_fy2025.html`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/source_manifest.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts/build_zensho_tables.py`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/geography_contribution.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/segment_bridge.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/store_sssg_summary.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md`

Do not create a separate top-level project. Keep all research artifacts in the Zensho folder above.

---

### Task 1: Create Research Workspace and Source Archive

**Files:**
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/CIQ_Zensho_Financials_Segments_original.xls`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/source_manifest.csv`
- Create: official PDFs and HTML source files listed in File Structure.

- [ ] **Step 1: Create directories**

Run:

```bash
mkdir -p "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts"
```

Expected: command exits with status `0`.

- [ ] **Step 2: Copy the CIQ source workbook**

Run:

```bash
cp "/Users/tiequwangmonolith/Library/Containers/com.tencent.xinWeChat/Data/Library/Caches/com.tencent.xinWeChat/2.0b4.0.9/b1b229f20984d084d750d043af95584a/SaveTemp/ef70ccd0dc2f5fe6930c0329a0a0da7a/已补充_Zensho Holdings Co Ltd TSE 7550 Financials Segments.xls" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/CIQ_Zensho_Financials_Segments_original.xls"
```

Expected: copied file exists and is larger than `400000` bytes.

- [ ] **Step 3: Download official IR sources**

Run:

```bash
cd "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files"
curl -L --fail --silent --show-error -o zensho_41st_asr_en_fy2023.pdf https://www.zensho.co.jp/en/ir/resource/pdf/41th.pdf
curl -L --fail --silent --show-error -o zensho_42nd_asr_en_fy2024.pdf https://www.zensho.co.jp/en/ir/resource/pdf/42th.pdf
curl -L --fail --silent --show-error -o zensho_43rd_asr_en_fy2025.pdf https://www.zensho.co.jp/en/ir/resource/43rd.pdf
curl -L --fail --silent --show-error -o zensho_fy2024_results_en.pdf https://www.zensho.co.jp/en/ir/resource/pdf/ZHD240521.pdf
curl -L --fail --silent --show-error -o zensho_fy2025_results_en.pdf https://www.zensho.co.jp/en/ir/resource/pdf/ZHD250513EN.pdf
curl -L --fail --silent --show-error -o sukiya_monthly_fy2024.html https://www.zensho.co.jp/en/ir/finance/monthly/2024.html
curl -L --fail --silent --show-error -o sukiya_monthly_fy2025.html https://www.zensho.co.jp/en/ir/finance/monthly/2025.html
```

Expected: every `curl` command exits with status `0`.

- [ ] **Step 4: Create source manifest**

Create `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/source_manifest.csv` with exactly this header and rows:

```csv
file_name,source_type,url_or_origin,role_in_analysis
CIQ_Zensho_Financials_Segments_original.xls,CIQ workbook,WeChat cache file provided by user,Initial geography and segment table cross-check
zensho_41st_asr_en_fy2023.pdf,Official annual securities report,https://www.zensho.co.jp/en/ir/resource/pdf/41th.pdf,FY2023 official filing and old segment basis
zensho_42nd_asr_en_fy2024.pdf,Official annual securities report,https://www.zensho.co.jp/en/ir/resource/pdf/42th.pdf,FY2024 official filing and restated new segment basis
zensho_43rd_asr_en_fy2025.pdf,Official annual securities report,https://www.zensho.co.jp/en/ir/resource/43rd.pdf,FY2025 official filing and geography table
zensho_fy2024_results_en.pdf,Official results deck,https://www.zensho.co.jp/en/ir/resource/pdf/ZHD240521.pdf,FY2024 segment SSSG/store-count support
zensho_fy2025_results_en.pdf,Official results deck,https://www.zensho.co.jp/en/ir/resource/pdf/ZHD250513EN.pdf,FY2025 segment SSSG/store-count support
sukiya_monthly_fy2024.html,Official monthly data,https://www.zensho.co.jp/en/ir/finance/monthly/2024.html,Sukiya FY2024 all-store/existing-store/customer/ticket data
sukiya_monthly_fy2025.html,Official monthly data,https://www.zensho.co.jp/en/ir/finance/monthly/2025.html,Sukiya FY2025 all-store/existing-store/customer/ticket data
```

- [ ] **Step 5: Verify source archive**

Run:

```bash
cd "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files"
ls -lh CIQ_Zensho_Financials_Segments_original.xls zensho_41st_asr_en_fy2023.pdf zensho_42nd_asr_en_fy2024.pdf zensho_43rd_asr_en_fy2025.pdf zensho_fy2024_results_en.pdf zensho_fy2025_results_en.pdf sukiya_monthly_fy2024.html sukiya_monthly_fy2025.html source_manifest.csv
```

Expected: all nine files are listed; PDFs are non-empty; CIQ workbook is about `425K`.

- [ ] **Step 6: Commit workspace setup**

Run:

```bash
git status --short
git add "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/source_manifest.csv" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/CIQ_Zensho_Financials_Segments_original.xls" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_41st_asr_en_fy2023.pdf" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_42nd_asr_en_fy2024.pdf" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_43rd_asr_en_fy2025.pdf" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_fy2024_results_en.pdf" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/zensho_fy2025_results_en.pdf" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/sukiya_monthly_fy2024.html" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_files/sukiya_monthly_fy2025.html"
git commit -m "research: archive Zensho Japan growth sources"
```

Expected: commit succeeds. If the user has explicitly asked not to commit, skip this step and note that it was skipped.

---

### Task 2: Generate Reproducible Numeric Tables

**Files:**
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts/build_zensho_tables.py`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/geography_contribution.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/segment_bridge.csv`
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/store_sssg_summary.csv`

- [ ] **Step 1: Create table builder script**

Create `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts/build_zensho_tables.py` with this content:

```python
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path("/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07")
TABLES = ROOT / "tables"


def pct(numerator: float, denominator: float) -> float:
    return round(numerator / denominator * 100, 1)


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def build_geography_contribution() -> None:
    geography = [
        {"region": "China", "fy2022": 21815, "fy2023": 23282, "fy2024": 32409, "fy2025": 44999},
        {"region": "Japan", "fy2022": 538131, "fy2023": 622045, "fy2024": 732983, "fy2025": 823779},
        {"region": "ASEAN", "fy2022": 12211, "fy2023": 20523, "fy2024": 25760, "fy2025": 31316},
        {"region": "Other", "fy2022": 13130, "fy2023": 17273, "fy2024": 16208, "fy2025": 17808},
        {"region": "Europe", "fy2022": 0, "fy2023": 0, "fy2024": 28124, "fy2025": 53725},
        {"region": "Americas", "fy2022": 73214, "fy2023": 96838, "fy2024": 130291, "fy2025": 165055},
    ]
    totals = {"fy2022": 658501, "fy2023": 779961, "fy2024": 965775, "fy2025": 1136682}
    rows = []
    for row in geography:
        fy24_delta = row["fy2024"] - row["fy2023"]
        fy25_delta = row["fy2025"] - row["fy2024"]
        cumulative_delta = row["fy2025"] - row["fy2022"]
        rows.append({
            **row,
            "fy2024_yoy_delta": fy24_delta,
            "fy2024_growth_contribution_pct": pct(fy24_delta, totals["fy2024"] - totals["fy2023"]),
            "fy2025_yoy_delta": fy25_delta,
            "fy2025_growth_contribution_pct": pct(fy25_delta, totals["fy2025"] - totals["fy2024"]),
            "fy2025_vs_fy2022_delta": cumulative_delta,
            "fy2025_vs_fy2022_contribution_pct": pct(cumulative_delta, totals["fy2025"] - totals["fy2022"]),
        })
    rows.append({
        "region": "Total Revenues",
        **totals,
        "fy2024_yoy_delta": totals["fy2024"] - totals["fy2023"],
        "fy2024_growth_contribution_pct": 100.0,
        "fy2025_yoy_delta": totals["fy2025"] - totals["fy2024"],
        "fy2025_growth_contribution_pct": 100.0,
        "fy2025_vs_fy2022_delta": totals["fy2025"] - totals["fy2022"],
        "fy2025_vs_fy2022_contribution_pct": 100.0,
    })
    write_csv(
        TABLES / "geography_contribution.csv",
        [
            "region", "fy2022", "fy2023", "fy2024", "fy2025",
            "fy2024_yoy_delta", "fy2024_growth_contribution_pct",
            "fy2025_yoy_delta", "fy2025_growth_contribution_pct",
            "fy2025_vs_fy2022_delta", "fy2025_vs_fy2022_contribution_pct",
        ],
        rows,
    )


def build_segment_bridge() -> None:
    rows = [
        {
            "segment": "Global Sukiya",
            "fy2023_restated_revenue_bn_yen": 223.8,
            "fy2024_revenue_bn_yen": 265.3,
            "fy2025_revenue_bn_yen": 295.8,
            "fy2024_yoy_delta_bn_yen": 41.6,
            "fy2025_yoy_delta_bn_yen": 30.4,
            "domestic_read": "Japan-heavy, but includes overseas Sukiya; do not use as pure Japan matrix.",
            "growth_read": "Mostly SSSG/ticket/menu mix; Japan store count changed modestly.",
        },
        {
            "segment": "Global Hamasushi",
            "fy2023_restated_revenue_bn_yen": 169.5,
            "fy2024_revenue_bn_yen": 197.1,
            "fy2025_revenue_bn_yen": 248.5,
            "fy2024_yoy_delta_bn_yen": 27.6,
            "fy2025_yoy_delta_bn_yen": 51.4,
            "domestic_read": "Japan-heavy, but includes China and overseas Hama-sushi.",
            "growth_read": "SSSG strong; Japan openings helped but were not enough to explain growth alone.",
        },
        {
            "segment": "Global Fast Food",
            "fy2023_restated_revenue_bn_yen": 155.1,
            "fy2024_revenue_bn_yen": 243.8,
            "fy2025_revenue_bn_yen": 314.1,
            "fy2024_yoy_delta_bn_yen": 88.7,
            "fy2025_yoy_delta_bn_yen": 70.4,
            "domestic_read": "Mixed geography; includes Nakau, Lotteria, Katsuan plus overseas AFC/SNOWFOX/YO!/Bento/Sushi Circle.",
            "growth_read": "FY2024 materially M&A-driven; do not classify full segment growth as domestic Japan growth.",
        },
        {
            "segment": "Restaurants",
            "fy2023_restated_revenue_bn_yen": 117.2,
            "fy2024_revenue_bn_yen": 140.8,
            "fy2025_revenue_bn_yen": 156.1,
            "fy2024_yoy_delta_bn_yen": 23.5,
            "fy2025_yoy_delta_bn_yen": 15.3,
            "domestic_read": "Almost entirely Japan; includes Coco's, Jolly Pasta, Big Boy, Ichiban, Olive Hill, Hanaya Yohei.",
            "growth_read": "SSSG/menu mix/pricing and traffic recovery, not openings.",
        },
        {
            "segment": "Retail",
            "fy2023_restated_revenue_bn_yen": 78.2,
            "fy2024_revenue_bn_yen": 78.4,
            "fy2025_revenue_bn_yen": 76.0,
            "fy2024_yoy_delta_bn_yen": 0.2,
            "fy2025_yoy_delta_bn_yen": -2.4,
            "domestic_read": "Domestic supermarkets.",
            "growth_read": "Not a growth driver.",
        },
        {
            "segment": "Other",
            "fy2023_restated_revenue_bn_yen": 32.5,
            "fy2024_revenue_bn_yen": 36.0,
            "fy2025_revenue_bn_yen": 41.3,
            "fy2024_yoy_delta_bn_yen": 3.5,
            "fy2025_yoy_delta_bn_yen": 5.3,
            "domestic_read": "Manufacturing/wholesale, nursing care, livestock/fisheries.",
            "growth_read": "Modest contribution; not a main domestic restaurant growth engine.",
        },
    ]
    write_csv(
        TABLES / "segment_bridge.csv",
        [
            "segment", "fy2023_restated_revenue_bn_yen", "fy2024_revenue_bn_yen",
            "fy2025_revenue_bn_yen", "fy2024_yoy_delta_bn_yen", "fy2025_yoy_delta_bn_yen",
            "domestic_read", "growth_read",
        ],
        rows,
    )


def build_store_sssg_summary() -> None:
    rows = [
        {
            "brand_or_segment": "Sukiya Japan",
            "period": "FY2024, year ended Mar-2024",
            "store_count": "1,957 domestic stores, +16 YoY",
            "sales_yoy": "All-store 116.7%; existing-store 115.7%",
            "customer_count_yoy": "109.7%",
            "ticket_yoy": "105.4%",
            "growth_read": "Traffic recovery and ticket both helped; growth was not opening-led.",
            "evidence_level": "Official quantitative monthly data",
        },
        {
            "brand_or_segment": "Sukiya Japan",
            "period": "FY2025, year ended Mar-2025",
            "store_count": "1,969 domestic stores, +12 YoY",
            "sales_yoy": "All-store 110.3%; existing-store 110.5%",
            "customer_count_yoy": "102.5%",
            "ticket_yoy": "107.8%",
            "growth_read": "Ticket/price and menu mix were the main drivers.",
            "evidence_level": "Official quantitative monthly data",
        },
        {
            "brand_or_segment": "Hamasushi",
            "period": "FY2024, year ended Mar-2024",
            "store_count": "667 global stores, 605 Japan stores",
            "sales_yoy": "Global Hamasushi revenue +16.3%; SSS 109.3%",
            "customer_count_yoy": "Not disclosed",
            "ticket_yoy": "Not disclosed",
            "growth_read": "SSSG and openings both helped; brand-level customer/ticket split is not disclosed.",
            "evidence_level": "Official quantitative segment data",
        },
        {
            "brand_or_segment": "Hamasushi",
            "period": "FY2025, year ended Mar-2025",
            "store_count": "735 global stores, 639 Japan stores",
            "sales_yoy": "Global Hamasushi revenue +26.1%; SSS 117.1%",
            "customer_count_yoy": "Not disclosed",
            "ticket_yoy": "Not disclosed",
            "growth_read": "SSSG was too large to explain by Japan openings alone; overseas expansion also rose.",
            "evidence_level": "Official quantitative segment data",
        },
        {
            "brand_or_segment": "Restaurants",
            "period": "FY2024-FY2025",
            "store_count": "Flat/slightly declining per official segment disclosure",
            "sales_yoy": "Revenue +20.1% in FY2024 and +10.9% in FY2025; SSSG 120.4% and 111.7%",
            "customer_count_yoy": "Not disclosed by brand",
            "ticket_yoy": "Not disclosed by brand",
            "growth_read": "Coco's/Jolly Pasta/Big Boy-led SSSG/menu mix/pricing, not openings.",
            "evidence_level": "Official quantitative segment data",
        },
        {
            "brand_or_segment": "Retail",
            "period": "FY2024-FY2025",
            "store_count": "126 stores by FY2025",
            "sales_yoy": "Revenue flat in FY2024 and down in FY2025",
            "customer_count_yoy": "Not material to restaurant analysis",
            "ticket_yoy": "Not material to restaurant analysis",
            "growth_read": "Not a domestic growth source.",
            "evidence_level": "Official quantitative segment data",
        },
    ]
    write_csv(
        TABLES / "store_sssg_summary.csv",
        [
            "brand_or_segment", "period", "store_count", "sales_yoy", "customer_count_yoy",
            "ticket_yoy", "growth_read", "evidence_level",
        ],
        rows,
    )


def main() -> None:
    build_geography_contribution()
    build_segment_bridge()
    build_store_sssg_summary()
    print(f"Wrote tables to {TABLES}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run the table builder**

Run:

```bash
"/Users/tiequwangmonolith/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts/build_zensho_tables.py"
```

Expected output contains:

```text
Wrote tables to /Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables
```

- [ ] **Step 3: Verify geography math**

Run:

```bash
cd "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07"
python3 - <<'PY'
import csv
from pathlib import Path
rows = list(csv.DictReader((Path("tables") / "geography_contribution.csv").open(encoding="utf-8")))
japan = next(r for r in rows if r["region"] == "Japan")
total = next(r for r in rows if r["region"] == "Total Revenues")
assert japan["fy2024_yoy_delta"] == "110938"
assert japan["fy2025_yoy_delta"] == "90796"
assert total["fy2025_vs_fy2022_delta"] == "478181"
assert japan["fy2025_vs_fy2022_delta"] == "285648"
print("geography checks passed")
PY
```

Expected output:

```text
geography checks passed
```

- [ ] **Step 4: Commit numeric tables**

Run:

```bash
git add "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/scripts/build_zensho_tables.py" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/geography_contribution.csv" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/segment_bridge.csv" \
  "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/store_sssg_summary.csv"
git commit -m "research: add Zensho Japan growth tables"
```

Expected: commit succeeds. If the user has explicitly asked not to commit, skip this step and note that it was skipped.

---

### Task 3: Write Source Log

**Files:**
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md`

- [ ] **Step 1: Create the source log**

Create `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md` with this structure:

```markdown
# Zensho 日本本土增长研究 Source Log

## Source Hierarchy

- Level 1: Zensho official annual securities reports, financial results decks, monthly sales pages, and brand price/menu notices.
- Level 2: Rating agency or reputable Japanese business media used only for qualitative context where official disclosure does not quantify the driver.
- Level 3: CIQ workbook provided by user, used as the starting point and cross-check against official filings.

## Core Official Sources

| Source | Local file / URL | Evidence used |
|---|---|---|
| Zensho 41st Annual Securities Report | `source_files/zensho_41st_asr_en_fy2023.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/41th.pdf | FY2023 filing, old segment basis, geography cross-check |
| Zensho 42nd Annual Securities Report | `source_files/zensho_42nd_asr_en_fy2024.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/42th.pdf | FY2024 filing, restated new segment basis, geography table |
| Zensho 43rd Annual Securities Report | `source_files/zensho_43rd_asr_en_fy2025.pdf`; https://www.zensho.co.jp/en/ir/resource/43rd.pdf | FY2025 filing, geography table, segment definitions |
| Zensho FY2024 Results | `source_files/zensho_fy2024_results_en.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/ZHD240521.pdf | Global Sukiya, Global Hamasushi, Restaurants SSSG/store-count support |
| Zensho FY2025 Results | `source_files/zensho_fy2025_results_en.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/ZHD250513EN.pdf | Global Sukiya, Global Hamasushi, Restaurants SSSG/store-count support |
| Sukiya monthly FY2024 | `source_files/sukiya_monthly_fy2024.html`; https://www.zensho.co.jp/en/ir/finance/monthly/2024.html | Sukiya all-store sales, existing-store sales, customer count, ticket |
| Sukiya monthly FY2025 | `source_files/sukiya_monthly_fy2025.html`; https://www.zensho.co.jp/en/ir/finance/monthly/2025.html | Sukiya all-store sales, existing-store sales, customer count, ticket |
| CIQ workbook | `source_files/CIQ_Zensho_Financials_Segments_original.xls` | Initial Capital IQ geography and segment numbers supplied by user |

## Price, Menu, and Operating Sources to Cite in Memo

| Brand | Source URL | Use |
|---|---|---|
| Sukiya | https://www.sukiya.jp/news/press_20230217_kakaku.pdf | Feb. 2023 selective price increase |
| Sukiya | https://www.sukiya.jp/news/Press_sukiya_20240329.pdf | Apr. 2024 gyudon regular price increase and late-night surcharge |
| Sukiya | https://www.sukiya.jp/news/Press_sukiya_20241118.pdf | Nov. 2024 gyudon price increase tied to rice cost |
| Sukiya | https://www.sukiya.jp/news/Press_sukiya_20250312.pdf | Mar. 2025 gyudon price increase tied to cost inflation |
| Hamasushi | https://www.hamazushi.com/topics/2024/1223000636.html | Dec. 2024 selective sushi item price revisions |
| Hamasushi | https://www.zensho.co.jp/jp/company/dx/ | Group DX and store operations context |

## Disclosure Limits

- Zensho does not publish a segment-by-country matrix, so geography growth cannot be mechanically allocated to each segment.
- `Global Sukiya` and `Global Hamasushi` are Japan-heavy but include overseas stores and revenue.
- `Global Fast Food` includes Japan brands and overseas to-go sushi businesses; the full segment increase is not a Japan domestic organic growth proxy.
- Hamasushi does not disclose brand-level customer count and average-ticket split in the monthly data; use SSSG/store-count and price/menu disclosures instead.
```

- [ ] **Step 2: Verify source log has no unsupported claim language**

Run:

```bash
rg -n "TBD|TODO|maybe|probably|guess|估计|猜" "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md"
```

Expected: no matches.

- [ ] **Step 3: Commit source log**

Run:

```bash
git add "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md"
git commit -m "research: document Zensho source log"
```

Expected: commit succeeds. If the user has explicitly asked not to commit, skip this step and note that it was skipped.

---

### Task 4: Write Chinese Research Memo

**Files:**
- Create: `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md`

- [ ] **Step 1: Create memo with final structure and conclusions**

Create `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md` with these sections and conclusions:

```markdown
# Zensho 日本本土市场增长复核（FY2023-FY2025）

## Executive Answer

1. **Zensho 日本本土 FY2023-FY2025 仍在增长，并且仍是集团增长最大来源。** Japan geographic revenue 从 FY2023 的约 ¥622.0bn 增至 FY2024 的约 ¥733.0bn、FY2025 的约 ¥823.8bn。FY2024、FY2025 两个年度，日本分别贡献集团收入增量约 59.7% 和 53.1%；按 FY2025 vs FY2022 累计看，日本贡献约 59.7%。
2. **增长不是单一由 Sukiya 或 Hamasushi 开店带来。** Sukiya 日本门店数变化较小，Hamasushi 日本门店增长也不足以解释 segment 增速；Restaurants segment（Coco's、Jolly Pasta、Big Boy 等）也有明确 SSSG 贡献。Retail 基本不是增长源。
3. **更合理的解释是 SSSG、价格/客单价、菜单组合和客流恢复。** Sukiya 有官方月度数据可验证客单价和同店增长；Hamasushi 没有品牌级 customer/ticket split，但 segment SSSG、门店数、价格/菜单公告共同指向同店与 mix 驱动；Restaurants segment 也更像同店恢复与菜单/价格驱动。

## 1. 日本本土是否仍增长、是否仍占增长大头

| Fiscal year ended Mar. | Japan revenue, ¥mn | Group revenue, ¥mn | Japan share |
|---|---:|---:|---:|
| FY2023 | 622,045 | 779,961 | 79.8% |
| FY2024 | 732,983 | 965,775 | 75.9% |
| FY2025 | 823,779 | 1,136,682 | 72.5% |

| Growth period | Group revenue increase, ¥mn | Japan increase, ¥mn | Japan contribution |
|---|---:|---:|---:|
| FY2024 vs FY2023 | 185,814 | 110,938 | 59.7% |
| FY2025 vs FY2024 | 170,907 | 90,796 | 53.1% |
| FY2025 vs FY2022 | 478,181 | 285,648 | 59.7% |

结论：日本仍在增长，也仍是最大增量来源；但海外增速更快，所以日本收入占比从约 79.8% 降到约 72.5%。这解释了为什么看集团增长时会同时看到“日本还是大头”和“海外占比在提升”。

## 2. 增长来自哪个 segment / 品牌

Zensho FY2024 开始调整 segment 口径，从旧的 `Restaurant business / Retail business` 改为 `Global Sukiya / Global Hamasushi / Global Fast Food / Restaurants / Retail / Corporate & Support` 等。分析时应使用 Japan geography 回答“本土是否增长”，用 segment 作为品牌线索，但不能把 segment 增长直接等同于日本增长。

| Segment | FY2023 restated revenue, ¥bn | FY2024 revenue, ¥bn | FY2025 revenue, ¥bn | Read |
|---|---:|---:|---:|---|
| Global Sukiya | 223.8 | 265.3 | 295.8 | Japan-heavy；增长更偏同店/客单价，不是开店驱动 |
| Global Hamasushi | 169.5 | 197.1 | 248.5 | Japan-heavy；SSSG 强，海外开店也在加速 |
| Global Fast Food | 155.1 | 243.8 | 314.1 | 混合口径；含 Lotteria 日本并购，也含 AFC/SNOWFOX/YO!/Bento 等海外 |
| Restaurants | 117.2 | 140.8 | 156.1 | 近似日本本土；Coco's/Jolly Pasta/Big Boy 等 SSSG 明确 |
| Retail | 78.2 | 78.4 | 76.0 | 不是增长来源 |
| Other | 32.5 | 36.0 | 41.3 | 制造批发、护理、畜产水产，小幅贡献 |

品牌层面的主要读法：

- **Sukiya:** 日本门店数小幅增长，但同店销售和客单价增长更关键。
- **Hamasushi:** 日本门店增加，但 segment SSSG 高于单纯开店可以解释的程度；同时海外扩张让 Global Hamasushi 增速更高。
- **Restaurants:** Coco's、Jolly Pasta、Big Boy 等门店不是大幅扩张，收入增长更像同店、菜单、价格和客流恢复。
- **Global Fast Food:** FY2024 受到 Lotteria 并购影响，但整个 segment 还包含海外 To-Go Sushi，不应全部计入日本本土内生增长。
- **Retail:** 收入持平或下滑，不支持“日本增长来自零售”的判断。

## 3. 如果来自 SSSG，Zensho 做了什么

### Sukiya

Sukiya 的官方月度数据可拆到 all-store sales、existing-store sales、customer count、ticket。FY2025 年度既存店增长主要来自客单价：existing-store sales 约 +10.5%，customer count 约 +2.5%，ticket 约 +7.8%。价格动作包括 2024 年 4 月 regular gyudon 从 ¥400 到 ¥430，并引入深夜附加费；2024 年 11 月与 2025 年 3 月继续因米、牛肉等成本上升调整价格。

菜单上，Sukiya 通过季节性/话题性牛丼、咖喱、海鲜饭、汉堡咖喱等提高频次和 mix。外卖、mobile order、web bento、Wolt 等渠道也提供增量便利性，但官方没有把外卖单独量化为主要增长源。

### Hamasushi

Hamasushi 没有披露品牌级 customer count / ticket split，因此不能硬拆。官方披露能支撑的结论是：Global Hamasushi FY2024 SSSG 约 109.3%，FY2025 SSSG 约 117.1%；日本门店从约 605 增至约 639，增幅不足以单独解释收入高增。

经营动作更像“保留 ¥100/¥110 value hook + 高价/高 mix 单品”的组合。2024 年 12 月调价公告显示，maguro、salmon 等流量款维持 ¥110，同时 ikura、madai、otoro salmon 等部分品项上调。菜单活动以大切り、旨ねた、地域海鲜、premium 一贯、拉面、甜品、外带组合等提高客单和复购。

### Restaurants

Restaurants segment 包含 Coco's、Jolly Pasta、Big Boy、Ichiban、Olive Hill、Hanaya Yohei 等，更接近日本本土。该 segment FY2024/FY2025 的 SSSG 强，而门店数并非大幅扩张，因此是除 Sukiya/Hamasushi 外最清晰的本土同店增长来源。

### Operations / DX

Zensho 的运营改善不是“开新品牌”式增长，而是围绕既有品牌做菜单更新、价格调整、数字化点单/结账、预约/外带、供应链和门店效率。Hamasushi 的直线 lane、触屏点单、app 排队/预约和 Zensho group DX 可作为效率与体验改善证据，但应作为定性补充。

## Conclusion

用户在 CIQ 里看到的日本本土增长是真实存在的。关键不是“食其家和滨寿司门店没怎么增长所以不该增长”，而是 Zensho 在日本的成熟品牌仍通过 SSSG、客单价、菜单组合和客流恢复实现增长。Sukiya 是最有量化证据的同店/客单价案例；Hamasushi 是 SSSG 强但 customer/ticket 未拆的案例；Restaurants segment 是容易被忽视的本土贡献；Global Fast Food 需要单独处理并购与海外混合口径。

## Caveats

- Zensho 不披露 segment-by-country matrix，因此不能精确拆出“日本本土 Sukiya/Hamasushi revenue”。
- Hamasushi 不披露品牌级 customer count 和 ticket split；只能用 SSSG、门店数、价格/菜单和运营披露做归因。
- CIQ 与官方年报在少数总数上可能有 rounding 或 restatement 差异，memo 统一使用 ¥bn 级别表达时不影响结论。

## Linked Files

- `tables/geography_contribution.csv`
- `tables/segment_bridge.csv`
- `tables/store_sssg_summary.csv`
- `source_log.md`
```

- [ ] **Step 2: Verify memo includes the three user questions**

Run:

```bash
rg -n "日本本土是否仍增长|增长来自哪个 segment|如果来自 SSSG" "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md"
```

Expected: three matching section lines.

- [ ] **Step 3: Verify memo avoids unsupported hard split**

Run:

```bash
rg -n "segment-by-country|不能硬拆|不能精确拆出|不披露" "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md"
```

Expected: at least four matches.

- [ ] **Step 4: Commit memo**

Run:

```bash
git add "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md"
git commit -m "research: write Zensho Japan growth memo"
```

Expected: commit succeeds. If the user has explicitly asked not to commit, skip this step and note that it was skipped.

---

### Task 5: Final Verification and Handoff

**Files:**
- Verify: all files under `/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/`

- [ ] **Step 1: Verify expected file tree**

Run:

```bash
find "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07" -maxdepth 3 -type f | sort
```

Expected output includes these exact endings:

```text
memo_zensho_japan_growth.md
scripts/build_zensho_tables.py
source_files/CIQ_Zensho_Financials_Segments_original.xls
source_files/source_manifest.csv
source_files/sukiya_monthly_fy2024.html
source_files/sukiya_monthly_fy2025.html
source_files/zensho_41st_asr_en_fy2023.pdf
source_files/zensho_42nd_asr_en_fy2024.pdf
source_files/zensho_43rd_asr_en_fy2025.pdf
source_files/zensho_fy2024_results_en.pdf
source_files/zensho_fy2025_results_en.pdf
source_log.md
tables/geography_contribution.csv
tables/segment_bridge.csv
tables/store_sssg_summary.csv
```

- [ ] **Step 2: Run numeric and text checks**

Run:

```bash
cd "/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07"
python3 - <<'PY'
import csv
from pathlib import Path

geo = list(csv.DictReader(Path("tables/geography_contribution.csv").open(encoding="utf-8")))
japan = next(row for row in geo if row["region"] == "Japan")
assert japan["fy2023"] == "622045"
assert japan["fy2024"] == "732983"
assert japan["fy2025"] == "823779"
assert japan["fy2025_growth_contribution_pct"] == "53.1"

memo = Path("memo_zensho_japan_growth.md").read_text(encoding="utf-8")
for phrase in [
    "日本本土 FY2023-FY2025 仍在增长",
    "不是单一由 Sukiya 或 Hamasushi 开店带来",
    "Zensho 不披露 segment-by-country matrix",
    "Hamasushi 不披露品牌级 customer count 和 ticket split",
]:
    assert phrase in memo

print("final checks passed")
PY
```

Expected output:

```text
final checks passed
```

- [ ] **Step 3: Check git status**

Run:

```bash
git status --short
```

Expected: either clean working tree or only unrelated pre-existing user changes. Do not revert unrelated changes.

- [ ] **Step 4: Final response**

Report these exact deliverables to the user:

```markdown
已按 superpowers plan 完成 Zensho 日本本土增长研究材料。

主要文件：
- [memo_zensho_japan_growth.md](/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/memo_zensho_japan_growth.md)
- [source_log.md](/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/source_log.md)
- [geography_contribution.csv](/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/geography_contribution.csv)
- [segment_bridge.csv](/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/segment_bridge.csv)
- [store_sssg_summary.csv](/Users/tiequwangmonolith/my-project/实习工作/餐饮连锁出海研究/zensho_japan_growth_2026-05-07/tables/store_sssg_summary.csv)

验证：numeric/text checks passed。
```

---

## Self-Review

1. **Spec coverage:** The plan creates the requested folder, source archive, source log, three tables, and Chinese memo. It directly answers the three research questions and preserves the agreed assumptions.
2. **Placeholder scan:** No `TBD`, `TODO`, `implement later`, or ambiguous edge-case instructions are used. All files, commands, expected outputs, and content skeletons are explicit.
3. **Consistency check:** File paths match across tasks. The memo references the same table filenames that the builder creates. Verification assertions use the same numeric values written by the table builder.
