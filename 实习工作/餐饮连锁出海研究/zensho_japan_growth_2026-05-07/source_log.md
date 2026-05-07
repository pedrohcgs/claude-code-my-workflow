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
| Zensho FY2024 Results | `source_files/zensho_fy2024_results_en.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/ZHD240521.pdf | FY2024 segment SSSG/store-count support |
| Zensho FY2025 Results | `source_files/zensho_fy2025_results_en.pdf`; https://www.zensho.co.jp/en/ir/resource/pdf/ZHD250513EN.pdf | FY2025 segment SSSG/store-count support |
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
| Sukiya | https://www.sukiya.jp/news/Press_sukiya_20240719wolt.pdf | Wolt delivery rollout context |
| Hamasushi | https://www.hamazushi.com/topics/2024/1223000636.html | Dec. 2024 selective sushi item price revisions |
| Hamasushi | https://www.hamazushi.com/topics/2023/1106000478.html | 2023 menu/campaign example |
| Hamasushi | https://www.hamazushi.com/topics/2024/1015000603.html | 2024 menu/campaign example |
| Hamasushi | https://www.hamazushi.com/topics/2025/0317000658.html | 2025 menu/campaign example |
| Group DX | https://www.zensho.co.jp/jp/company/dx/ | Group DX and store operations context |
| Hamasushi app | https://www.hama-sushi.co.jp/app/ | Queue/time reservation and app context |

## Table Outputs

| File | What it supports |
|---|---|
| `tables/geography_contribution.csv` | Japan revenue growth, group growth, and Japan contribution by period |
| `tables/segment_bridge.csv` | FY2023 restated segment bridge through FY2025 |
| `tables/store_sssg_summary.csv` | Store-count/SSSG evidence summary for Sukiya, Hamasushi, Restaurants, and Retail |

## Disclosure Limits

- Zensho does not publish a segment-by-country matrix, so geography growth cannot be mechanically allocated to each segment.
- `Global Sukiya` and `Global Hamasushi` are Japan-heavy but include overseas stores and revenue.
- `Global Fast Food` includes Japan brands and overseas to-go sushi businesses; the full segment increase is not a Japan domestic organic growth proxy.
- Hamasushi does not disclose brand-level customer count and average-ticket split in the monthly data; use SSSG/store-count and price/menu disclosures instead.
- CIQ, annual securities report tables, and result decks may differ slightly by rounding, restatement, or table scope. This research uses the provided CIQ geography table for the reproducible geography contribution CSV and uses official filings/decks for interpretation.
