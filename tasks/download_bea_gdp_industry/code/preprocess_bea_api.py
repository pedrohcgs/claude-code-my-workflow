#!/usr/bin/env python3
"""
Preprocess BEA GDP-by-Industry API data into clean CSV panels.

Takes the raw bea_va_components.csv from fetch_bea_api.py and produces:
  - bea_va_panel.csv: Industry × Year panel with VA, CE, GOS, TOPI

Table 6 structure:
  For each industry-year, there are 4 rows in Table 6:
    - "Compensation of employees" (CE)
    - "Gross operating surplus" (GOS)
    - "Taxes on production and imports less subsidies" (TOPI)
    - [Industry name] = Value Added total

Table 1 structure:
  One row per industry-year = Value Added in billions
"""

import csv
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "..", "output")

# Target industries (BEA industry codes -> our NAICS codes)
INDUSTRY_MAP = {
    "23": "23",       # Construction
    "31G": "31-33",   # Manufacturing
    "44RT": "44-45",  # Retail trade
    "51": "51",       # Information
    "52": "52",       # Finance and insurance
    "54": "54",       # Professional services
    "61": "61",       # Educational services
    "62": "62",       # Health care and social assistance
    "621": "621",     # Ambulatory health care
    "622": "622",     # Hospitals
    "623": "623",     # Nursing and residential care
    "624": "624",     # Social assistance
    "6": "61-62",     # Educ + Health combined
    "GOVA": "total",  # Total (all industries)
    "GDP": "total",   # GDP (alternate code)
}

# Additional labels
INDUSTRY_LABELS = {
    "23": "Construction",
    "31-33": "Manufacturing",
    "44-45": "Retail trade",
    "51": "Information",
    "52": "Finance and insurance",
    "54": "Professional, scientific, and technical services",
    "61": "Educational services",
    "62": "Health care and social assistance",
    "621": "Ambulatory health care services",
    "622": "Hospitals",
    "623": "Nursing and residential care facilities",
    "624": "Social assistance",
    "61-62": "Educational services, health care, and social assistance",
    "total": "All industries (GDP)",
    "private": "Private industries",
}


def classify_component(description):
    """Classify a Table 6 row by its component type."""
    desc_lower = description.lower()
    if "compensation" in desc_lower:
        return "comp_employees"
    elif "gross operating surplus" in desc_lower:
        return "gos"
    elif "taxes on production" in desc_lower:
        return "topi"
    else:
        return "value_added"


def main():
    input_path = os.path.join(OUTPUT_DIR, "bea_va_components.csv")
    if not os.path.exists(input_path):
        print("ERROR: bea_va_components.csv not found. Run fetch_bea_api.py first.",
              file=sys.stderr)
        sys.exit(1)

    with open(input_path) as f:
        rows = list(csv.DictReader(f))

    print(f"Read {len(rows)} rows from bea_va_components.csv")

    # --- Process Table 6 (VA components by industry) ---
    # Build: {(industry, year): {comp_employees, gos, topi, value_added}}
    panel = {}

    for row in rows:
        if row["SourceTableID"] != "6":
            continue

        bea_code = row["Industry"]
        year = row["Year"]

        # Map to our NAICS code
        if bea_code not in INDUSTRY_MAP:
            # Check if it's "private" industries
            if bea_code in ("PVT", "GVAPVT"):
                naics = "private"
            else:
                continue
        else:
            naics = INDUSTRY_MAP[bea_code]

        component = classify_component(row["IndustrYDescription"])
        val_str = row["DataValue"].replace(",", "").strip()
        try:
            value = float(val_str)
        except ValueError:
            continue

        key = (naics, year)
        if key not in panel:
            panel[key] = {
                "naics_code": naics,
                "year": year,
                "industry_label": "",
                "comp_employees": None,
                "gos": None,
                "topi": None,
                "value_added": None,
            }

        panel[key][component] = value
        if component == "value_added":
            panel[key]["industry_label"] = row["IndustrYDescription"]

    # Fill industry labels from our mapping where missing
    for key, rec in panel.items():
        if not rec["industry_label"]:
            rec["industry_label"] = INDUSTRY_LABELS.get(rec["naics_code"], "")

    # Also get VA levels from Table 1 as validation
    va_from_t1 = {}
    for row in rows:
        if row["SourceTableID"] != "1":
            continue
        bea_code = row["Industry"]
        if bea_code in INDUSTRY_MAP:
            naics = INDUSTRY_MAP[bea_code]
        elif bea_code in ("PVT", "GVAPVT"):
            naics = "private"
        else:
            continue
        year = row["Year"]
        val_str = row["DataValue"].replace(",", "").strip()
        try:
            va_from_t1[(naics, year)] = float(val_str)
        except ValueError:
            pass

    # Validate: Table 6 VA total should match Table 1 VA level
    mismatches = 0
    for key, rec in panel.items():
        if key in va_from_t1 and rec["value_added"] is not None:
            t1_va = va_from_t1[key]
            t6_va = rec["value_added"]
            if abs(t1_va - t6_va) > 0.2:
                mismatches += 1
    if mismatches > 0:
        print(f"  WARNING: {mismatches} mismatches between Table 1 and Table 6 VA")

    # --- Write output ---
    output_path = os.path.join(OUTPUT_DIR, "bea_va_panel.csv")
    fieldnames = ["naics_code", "year", "industry_label",
                  "value_added", "comp_employees", "gos", "topi"]

    records = sorted(panel.values(), key=lambda r: (r["naics_code"], r["year"]))

    with open(output_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"Wrote {len(records)} rows to bea_va_panel.csv")

    # Summary
    industries = sorted(set(r["naics_code"] for r in records))
    years = sorted(set(r["year"] for r in records))
    print(f"Industries: {len(industries)}")
    print(f"Years: {years[0]}-{years[-1]} ({len(years)} total)")
    print(f"Industries: {', '.join(industries)}")

    # Healthcare summary
    hc = [r for r in records if r["naics_code"] == "62" and r["year"] == "2023"]
    if hc:
        r = hc[0]
        print(f"\nHealthcare (62) in 2023:")
        print(f"  Value Added: ${r['value_added']}B")
        print(f"  Compensation: ${r['comp_employees']}B")
        print(f"  GOS: ${r['gos']}B")
        print(f"  TOPI: ${r['topi']}B")
        if r["value_added"] and r["comp_employees"]:
            ls = r["comp_employees"] / r["value_added"]
            print(f"  Labor Share (CE/VA): {ls:.3f}")


if __name__ == "__main__":
    main()
