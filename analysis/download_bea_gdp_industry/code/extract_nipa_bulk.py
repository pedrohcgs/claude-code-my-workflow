#!/usr/bin/env python3
"""
Extract industry-level income components from BEA NIPA bulk data.

Uses NipaDataA.txt (annual NIPA data) and SeriesRegister.txt (series metadata)
to extract compensation, proprietors' income, and related series for target
industries.

This is the FALLBACK approach when the BEA API key is not yet activated.
It extracts from the NIPA tables (income-side), not the GDP-by-Industry
tables (production-side). For the full VA decomposition, the BEA API or
interactive table download is still needed.

What we CAN get from NIPA:
  - Table 6.2D: Compensation of employees by industry (CE)
  - Table 6.12D: Nonfarm proprietors' income by industry
  - Table 6.1D: National income by industry
  - Table 6.13D: Nonfarm proprietors' employment
  - Table 6.15D: FTE employees by industry

What we STILL NEED from GDP-by-Industry:
  - Value added by industry
  - Gross operating surplus by industry
  - Taxes on production less subsidies by industry
"""

import csv
import os
import sys
from datetime import datetime
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUTS_DIR = os.path.join(SCRIPT_DIR, "..", "outputs")

# Series codes for our target industries
# Format: {series_code: (table, industry_label, naics_code)}
SERIES_MAP = {
    # Table 6.2D: Compensation of Employees by Industry
    "A4003C": ("comp", "Private industries", "private"),
    "N4012C": ("comp", "Construction", "23"),
    "N4013C": ("comp", "Manufacturing", "31-33"),
    "N4040C": ("comp", "Retail trade", "44-45"),
    "N4054C": ("comp", "Information", "51"),
    "N4059C": ("comp", "Finance and insurance", "52"),
    "N4067C": ("comp", "Professional, scientific, and technical services", "54"),
    "N4075C": ("comp", "Educational services", "61"),
    "N4076C": ("comp", "Health care and social assistance", "62"),
    "N4077C": ("comp", "Ambulatory health care services", "621"),
    "N4078C": ("comp", "Hospitals", "622"),
    "N4079C": ("comp", "Nursing and residential care facilities", "623"),

    # Table 6.1D: National Income by Industry
    "A736RC": ("natl_income", "Private industries", "private"),
    "N5007C": ("natl_income", "Construction", "23"),
    "N5008C": ("natl_income", "Manufacturing", "31-33"),
    "N5012C": ("natl_income", "Retail trade", "44-45"),
    "N5014C": ("natl_income", "Information", "51"),
    "N5017C": ("natl_income", "Educ/health/social assistance", "61-62"),

    # Table 6.12D: Nonfarm Proprietors' Income by Industry
    "N1803C": ("prop_income", "Construction", "23"),
    "N1804C": ("prop_income", "Manufacturing", "31-33"),
    "N1808C": ("prop_income", "Retail trade", "44-45"),
    "N1810C": ("prop_income", "Information", "51"),
    "N1812C": ("prop_income", "Finance and insurance", "52"),
    "N1815C": ("prop_income", "Professional, scientific, and technical services", "54"),
    "N1822C": ("prop_income", "Health care and social assistance", "62"),

    # Table 6.13D: Nonfarm Self-Employed (number)
    "N1706C": ("self_employed", "Construction", "23"),
    "N1707C": ("self_employed", "Manufacturing", "31-33"),
    "N1711C": ("self_employed", "Retail trade", "44-45"),
    "N1713C": ("self_employed", "Information", "51"),
    "N1715C": ("self_employed", "Finance and insurance", "52"),
    "N1718C": ("self_employed", "Professional, scientific, and technical services", "54"),
    "N1722C": ("self_employed", "Health care and social assistance", "62"),

    # Table 6.15D: FTE Employees by Industry (thousands)
    "A1850C": ("fte_employees", "Domestic industries", "total"),
    "N1854C": ("fte_employees", "Construction", "23"),
    "N1855C": ("fte_employees", "Manufacturing", "31-33"),
    "N1859C": ("fte_employees", "Retail trade", "44-45"),
    "N1861C": ("fte_employees", "Information", "51"),
    "N1863C": ("fte_employees", "Finance and insurance", "52"),
    "N1866C": ("fte_employees", "Professional, scientific, and technical services", "54"),
    "N1869C": ("fte_employees", "Educ/health/social assistance", "61-62"),
}


def main():
    print("=" * 60)
    print("Extract NIPA Bulk Data for Target Industries")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)

    data_file = os.path.join(OUTPUTS_DIR, "NipaDataA.txt")
    if not os.path.exists(data_file):
        print(f"ERROR: {data_file} not found.", file=sys.stderr)
        print("Download from: https://apps.bea.gov/national/Release/TXT/NipaDataA.txt",
              file=sys.stderr)
        sys.exit(1)

    # Read bulk data
    print(f"\nReading {data_file}...")
    target_codes = set(SERIES_MAP.keys())
    extracted = defaultdict(list)  # {series_code: [(year, value), ...]}
    total_lines = 0
    matched_lines = 0

    with open(data_file, "r") as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 3:
                continue
            total_lines += 1
            code = row[0].lstrip("%")  # First line has % prefix
            if code in target_codes:
                year_str = row[1]
                value_str = row[2].replace('"', '').replace(',', '')
                try:
                    year = int(year_str)
                    value = float(value_str)
                    extracted[code].append((year, value))
                    matched_lines += 1
                except ValueError:
                    pass

    print(f"  Total lines scanned: {total_lines:,}")
    print(f"  Matched lines: {matched_lines:,}")
    print(f"  Series found: {len(extracted)} of {len(target_codes)}")

    # Report missing series
    missing = target_codes - set(extracted.keys())
    if missing:
        print(f"\n  Missing series: {', '.join(sorted(missing))}")

    # Write extracted data as CSV, organized by component type
    components = defaultdict(list)
    for code, values in extracted.items():
        table, label, naics = SERIES_MAP[code]
        for year, value in values:
            components[table].append({
                "series_code": code,
                "year": year,
                "value": value,
                "industry_label": label,
                "naics_code": naics,
            })

    for table_name, rows in components.items():
        filepath = os.path.join(OUTPUTS_DIR, f"nipa_{table_name}.csv")
        rows.sort(key=lambda r: (r["naics_code"], r["year"]))
        with open(filepath, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=[
                "series_code", "year", "value", "industry_label", "naics_code"
            ])
            writer.writeheader()
            writer.writerows(rows)
        print(f"\n  Saved {table_name}: {len(rows)} rows -> nipa_{table_name}.csv")

        # Show sample
        healthcare = [r for r in rows if r["naics_code"] == "62"]
        if healthcare:
            recent = sorted(healthcare, key=lambda r: r["year"])[-3:]
            for r in recent:
                print(f"    {r['industry_label']} {r['year']}: {r['value']:,.0f}")

    # Write vintage
    vintage_path = os.path.join(OUTPUTS_DIR, "data_vintage.txt")
    with open(vintage_path, "w") as f:
        f.write(f"Data Source: BEA NIPA Annual Data (bulk download)\n")
        f.write(f"Download Timestamp: {datetime.now().isoformat()}\n")
        f.write(f"Source File: NipaDataA.txt\n")
        f.write(f"Series Register: SeriesRegister.txt\n")
        f.write(f"Total series extracted: {len(extracted)}\n")
        f.write(f"Total data points: {matched_lines}\n")
        f.write(f"\nComponents extracted:\n")
        for table_name, rows in components.items():
            years = sorted(set(r["year"] for r in rows))
            f.write(f"  {table_name}: {len(rows)} rows, years {years[0]}-{years[-1]}\n")
        f.write(f"\nNOTE: This is NIPA data (income-side). For full VA decomposition,\n")
        f.write(f"GDP-by-Industry data is also needed (requires BEA API or interactive tables).\n")

    print(f"\n{'=' * 60}")
    print("Extraction complete.")
    print(f"NOTE: This provides compensation, proprietors' income, and employment.")
    print(f"For VA decomposition (VA = CE + GOS + Taxes), you also need")
    print(f"GDP-by-Industry data from the BEA API or interactive tables.")


if __name__ == "__main__":
    main()
