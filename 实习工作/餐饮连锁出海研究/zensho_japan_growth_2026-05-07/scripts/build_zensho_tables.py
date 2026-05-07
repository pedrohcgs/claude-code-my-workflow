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
