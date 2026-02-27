#!/usr/bin/env python3
"""
Fetch BEA Gross Output and Intermediate Inputs by industry.

Downloads TableID 15 (Gross Output) and 20 (Intermediate Inputs),
then computes VA/GO ratios and identifies NHE-affiliated industries.

Outputs:
    - bea_gross_output.csv: Raw gross output data
    - bea_intermediate_inputs.csv: Raw intermediate inputs data
    - bea_va_go_ratios.csv: VA, GO, II, VA/GO by industry-year
"""

import json
import csv
import os
import sys
from datetime import datetime
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError
from urllib.parse import urlencode

BEA_API_BASE = "https://apps.bea.gov/api/data"
DATASET = "GDPbyIndustry"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(SCRIPT_DIR, "..", "input")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "..", "output")

# Expanded industry map: includes healthcare AND NHE-affiliated industries
INDUSTRY_MAP = {
    # Core healthcare (NAICS 62)
    "62": "62",
    "621": "621",
    "622": "622",
    "623": "623",
    "624": "624",
    # NHE-affiliated industries (non-healthcare NAICS that serve healthcare)
    "3254": "3254",    # Pharmaceutical and medicine manufacturing
    "339": "339",      # Miscellaneous manufacturing (incl. medical devices 3391)
    "5241": "5241",    # Insurance carriers (incl. health insurance)
    "52": "52",        # Finance and insurance (parent)
    "42": "42",        # Wholesale trade (drug/device distribution)
    "31G": "31-33",    # Manufacturing (total)
    "325": "325",      # Chemical manufacturing (parent of pharma)
    # Comparison industries
    "23": "23",
    "44RT": "44-45",
    "51": "51",
    "54": "54",
    "61": "61",
    "6": "61-62",
    # Aggregates
    "GOVA": "total",
    "GDP": "total",
}

INDUSTRY_LABELS = {
    "62": "Health care and social assistance",
    "621": "Ambulatory health care services",
    "622": "Hospitals",
    "623": "Nursing and residential care",
    "624": "Social assistance",
    "3254": "Pharmaceutical manufacturing",
    "339": "Miscellaneous mfg (incl. medical devices)",
    "5241": "Insurance carriers",
    "52": "Finance and insurance",
    "42": "Wholesale trade",
    "31-33": "Manufacturing",
    "325": "Chemical manufacturing",
    "23": "Construction",
    "44-45": "Retail trade",
    "51": "Information",
    "54": "Professional services",
    "61": "Educational services",
    "61-62": "Education + Health care",
    "total": "All industries",
}


def read_api_key():
    key_file = os.path.join(INPUT_DIR, "bea_api_key.txt")
    with open(key_file) as f:
        return f.read().strip()


def bea_api_call(params):
    url = f"{BEA_API_BASE}?{urlencode(params)}"
    print(f"  Calling: TableID={params.get('TableID', 'N/A')}")
    try:
        req = Request(url)
        with urlopen(req, timeout=120) as response:
            data = json.loads(response.read().decode("utf-8"))
        return data
    except (HTTPError, URLError) as e:
        print(f"  Error: {e}", file=sys.stderr)
        return None


def fetch_table(api_key, table_id):
    params = {
        "UserID": api_key,
        "Method": "GetData",
        "DataSetName": DATASET,
        "TableID": table_id,
        "Industry": "ALL",
        "Frequency": "A",
        "Year": "ALL",
        "ResultFormat": "JSON",
    }
    data = bea_api_call(params)
    if data is None:
        return []
    try:
        return data["BEAAPI"]["Results"]["Data"]
    except (KeyError, TypeError):
        try:
            return data["BEAAPI"]["Results"][0]["Data"]
        except (KeyError, TypeError, IndexError):
            return []


def parse_value(val_str):
    try:
        return float(val_str.replace(",", "").strip())
    except (ValueError, AttributeError):
        return None


def main():
    print("=" * 60)
    print("BEA Gross Output & Intermediate Inputs Download")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)

    api_key = read_api_key()

    # Fetch Gross Output (Table 15) and Intermediate Inputs (Table 20)
    print("\n[1/2] Fetching Gross Output by Industry (Table 15)...")
    go_rows = fetch_table(api_key, "15")
    print(f"  Got {len(go_rows)} rows")

    print("\n[2/2] Fetching Intermediate Inputs by Industry (Table 20)...")
    ii_rows = fetch_table(api_key, "20")
    print(f"  Got {len(ii_rows)} rows")

    # Save raw data
    for rows, filename in [(go_rows, "bea_gross_output.csv"),
                           (ii_rows, "bea_intermediate_inputs.csv")]:
        if rows:
            path = os.path.join(OUTPUT_DIR, filename)
            fieldnames = list(rows[0].keys())
            with open(path, "w", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(rows)
            print(f"  Saved {filename} ({len(rows)} rows)")

    # Parse into industry-year panels
    go_panel = {}  # (naics, year) -> gross_output
    for row in go_rows:
        bea_code = row.get("Industry", "")
        if bea_code in INDUSTRY_MAP:
            naics = INDUSTRY_MAP[bea_code]
        elif bea_code in ("PVT", "GVAPVT"):
            naics = "private"
        else:
            continue
        year = row.get("Year", "")
        val = parse_value(row.get("DataValue", ""))
        if val is not None:
            go_panel[(naics, year)] = val

    ii_panel = {}  # (naics, year) -> intermediate_inputs
    for row in ii_rows:
        bea_code = row.get("Industry", "")
        if bea_code in INDUSTRY_MAP:
            naics = INDUSTRY_MAP[bea_code]
        elif bea_code in ("PVT", "GVAPVT"):
            naics = "private"
        else:
            continue
        year = row.get("Year", "")
        val = parse_value(row.get("DataValue", ""))
        if val is not None:
            ii_panel[(naics, year)] = val

    # Load existing VA data
    va_path = os.path.join(OUTPUT_DIR, "bea_va_panel.csv")
    va_panel = {}
    if os.path.exists(va_path):
        with open(va_path) as f:
            for row in csv.DictReader(f):
                key = (row["naics_code"], row["year"])
                val = parse_value(row.get("value_added", ""))
                if val is not None:
                    va_panel[key] = val

    # Merge into VA/GO ratio panel
    print("\n--- Computing VA/GO Ratios ---")
    all_keys = sorted(set(go_panel.keys()) | set(va_panel.keys()))

    records = []
    for naics, year in all_keys:
        go = go_panel.get((naics, year))
        va = va_panel.get((naics, year))
        ii = ii_panel.get((naics, year))
        va_go_ratio = va / go if (va and go and go > 0) else None

        records.append({
            "naics_code": naics,
            "year": year,
            "industry_label": INDUSTRY_LABELS.get(naics, ""),
            "value_added": va,
            "gross_output": go,
            "intermediate_inputs": ii,
            "va_go_ratio": round(va_go_ratio, 4) if va_go_ratio else None,
        })

    # Write merged panel
    out_path = os.path.join(OUTPUT_DIR, "bea_va_go_ratios.csv")
    fieldnames = ["naics_code", "year", "industry_label",
                  "value_added", "gross_output", "intermediate_inputs",
                  "va_go_ratio"]
    with open(out_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)
    print(f"Wrote {len(records)} rows to bea_va_go_ratios.csv")

    # Print summary for recent year
    print("\n" + "=" * 70)
    print("VA/GO Ratios by Industry (2023 or most recent)")
    print("=" * 70)
    print(f"{'Industry':<45} {'VA/GO':>8} {'VA ($B)':>10} {'GO ($B)':>10}")
    print("-" * 70)

    summary_industries = [
        "62", "621", "622", "623",
        "3254", "339", "5241", "42",
        "31-33", "51", "52", "54", "23", "44-45",
        "total",
    ]

    for naics in summary_industries:
        # Try 2023, then 2022
        for yr in ["2023", "2022", "2024"]:
            key = (naics, yr)
            if key in go_panel:
                go = go_panel.get(key)
                va = va_panel.get(key)
                ratio = va / go if (va and go and go > 0) else None
                label = INDUSTRY_LABELS.get(naics, naics)
                ratio_str = f"{ratio:.3f}" if ratio else "N/A"
                va_str = f"{va:.1f}" if va else "N/A"
                go_str = f"{go:.1f}" if go else "N/A"
                print(f"{label:<45} {ratio_str:>8} {va_str:>10} {go_str:>10}")
                break

    # NHE decomposition
    print("\n" + "=" * 70)
    print("NHE-Affiliated Industries (2023)")
    print("=" * 70)
    print("CMS NHE includes spending that generates VA in these BEA industries:")
    nhe_industries = ["62", "3254", "339", "5241", "42"]
    total_va = 0
    for naics in nhe_industries:
        for yr in ["2023", "2022"]:
            key = (naics, yr)
            if key in va_panel:
                va = va_panel[key]
                label = INDUSTRY_LABELS.get(naics, naics)
                print(f"  {label:<45} VA = ${va:.1f}B")
                total_va += va
                break
    gdp = va_panel.get(("total", "2023")) or va_panel.get(("total", "2022"))
    if gdp:
        print(f"\n  Sum of NHE-affiliated VA:  ${total_va:.1f}B ({total_va/gdp*100:.1f}% of GDP)")
        hc_va = va_panel.get(("62", "2023")) or va_panel.get(("62", "2022"))
        if hc_va:
            print(f"  Healthcare VA alone (62):  ${hc_va:.1f}B ({hc_va/gdp*100:.1f}% of GDP)")


if __name__ == "__main__":
    main()
