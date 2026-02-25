#!/usr/bin/env python3
"""
Fetch supplementary NIPA tables from BEA API.

Downloads:
  1. Proprietors' income by industry (for Gollin mixed-income adjustment)
  2. Consumption of fixed capital by industry (for gross-vs-net sensitivity)

Usage:
    python3 fetch_nipa_supplements.py

Requires:
    - BEA API key in ../../download_bea_gdp_industry/inputs/bea_api_key.txt
      (shared with main BEA download task)
    - Python 3.6+ (stdlib only)

Outputs saved to ../outputs/:
    - nipa_proprietors_income.csv
    - nipa_cfc.csv
    - nipa_table_inventory.txt
    - data_vintage.txt
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

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUTS_DIR = os.path.join(SCRIPT_DIR, "..", "inputs")
OUTPUTS_DIR = os.path.join(SCRIPT_DIR, "..", "outputs")
# Shared API key location
API_KEY_PATH = os.path.join(
    SCRIPT_DIR, "..", "..", "download_bea_gdp_industry", "inputs", "bea_api_key.txt"
)


def read_api_key():
    """Read BEA API key from shared location."""
    # Check local first, then shared
    local_key = os.path.join(INPUTS_DIR, "bea_api_key.txt")
    for path in [local_key, API_KEY_PATH]:
        if os.path.exists(path):
            with open(path) as f:
                return f.read().strip()
    print(f"ERROR: API key not found.", file=sys.stderr)
    print(f"Place key at: {local_key}", file=sys.stderr)
    print(f"Or at: {API_KEY_PATH}", file=sys.stderr)
    sys.exit(1)


def bea_api_call(params):
    """Make a BEA API call and return parsed JSON."""
    url = f"{BEA_API_BASE}?{urlencode(params)}"
    print(f"  Calling: Method={params.get('Method', 'N/A')}, "
          f"TableName={params.get('TableName', 'N/A')}, "
          f"DataSetName={params.get('DataSetName', 'N/A')}")
    try:
        req = Request(url)
        with urlopen(req, timeout=120) as response:
            return json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError) as e:
        print(f"  Error: {e}", file=sys.stderr)
        return None


def get_nipa_tables(api_key):
    """Discover available NIPA table names."""
    params = {
        "UserID": api_key,
        "Method": "GetParameterValues",
        "DataSetName": "NIPA",
        "ParameterName": "TableName",
        "ResultFormat": "JSON",
    }
    data = bea_api_call(params)
    if data is None:
        return []
    try:
        return data["BEAAPI"]["Results"]["ParamValue"]
    except (KeyError, TypeError):
        return []


def fetch_nipa_table(api_key, table_name, frequency="A", year="ALL"):
    """Fetch NIPA table data."""
    params = {
        "UserID": api_key,
        "Method": "GetData",
        "DataSetName": "NIPA",
        "TableName": table_name,
        "Frequency": frequency,
        "Year": year,
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


def fetch_fixed_assets(api_key, table_name, year="ALL"):
    """Fetch Fixed Assets table data."""
    params = {
        "UserID": api_key,
        "Method": "GetData",
        "DataSetName": "FixedAssets",
        "TableName": table_name,
        "Year": year,
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


def rows_to_csv(rows, filepath):
    """Write list of dicts to CSV."""
    if not rows:
        print(f"  WARNING: No rows to write for {filepath}", file=sys.stderr)
        return 0
    fieldnames = list(rows[0].keys())
    with open(filepath, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    return len(rows)


def main():
    print("=" * 60)
    print("BEA NIPA Supplementary Tables Download")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)

    api_key = read_api_key()
    os.makedirs(OUTPUTS_DIR, exist_ok=True)

    # Step 1: Discover NIPA tables
    print("\n[1/4] Discovering NIPA tables...")
    tables = get_nipa_tables(api_key)

    inventory_path = os.path.join(OUTPUTS_DIR, "nipa_table_inventory.txt")
    with open(inventory_path, "w") as f:
        f.write(f"BEA NIPA Table Inventory\n")
        f.write(f"Downloaded: {datetime.now().isoformat()}\n")
        f.write("=" * 60 + "\n\n")
        # Filter for tables relevant to income by industry
        for t in tables:
            name = t.get("TableName", t.get("Key", "?"))
            desc = t.get("Description", t.get("Desc", ""))
            if any(kw in desc.lower() for kw in ["proprietor", "income by industry",
                                                   "compensation", "self-employ"]):
                f.write(f"*** {name}: {desc}\n")
            else:
                f.write(f"    {name}: {desc}\n")
    print(f"  Found {len(tables)} NIPA tables")

    # Step 2: Fetch proprietors' income by industry
    # NIPA Table 6.12D: Nonfarm Proprietors' Income by Industry
    # Alternative: Table 6.12A-D (different time periods)
    print("\n[2/4] Fetching proprietors' income by industry...")
    prop_income_tables = ["T61200D", "T61200C", "T61200B", "T61200A"]
    all_prop_rows = []
    for tname in prop_income_tables:
        rows = fetch_nipa_table(api_key, tname)
        if rows:
            for row in rows:
                row["SourceTable"] = tname
            all_prop_rows.extend(rows)
            print(f"  {tname}: {len(rows)} rows")

    # If table-name format didn't work, try numeric format
    if not all_prop_rows:
        print("  Trying alternative table name formats...")
        for tname in ["T60712D", "T60712C"]:
            rows = fetch_nipa_table(api_key, tname)
            if rows:
                for row in rows:
                    row["SourceTable"] = tname
                all_prop_rows.extend(rows)
                print(f"  {tname}: {len(rows)} rows")

    prop_path = os.path.join(OUTPUTS_DIR, "nipa_proprietors_income.csv")
    n_prop = rows_to_csv(all_prop_rows, prop_path)
    print(f"  Total proprietors' income rows: {n_prop}")

    # Step 3: Fetch consumption of fixed capital by industry
    # Fixed Assets Table 6.2: Current-Cost Depreciation of Private Fixed Assets by Industry
    # or Table 6.4: Chain-Type Quantity Indexes
    print("\n[3/4] Fetching consumption of fixed capital by industry...")
    cfc_tables = ["FAAt602", "FAAt604"]
    all_cfc_rows = []
    for tname in cfc_tables:
        rows = fetch_fixed_assets(api_key, tname)
        if rows:
            for row in rows:
                row["SourceTable"] = tname
            all_cfc_rows.extend(rows)
            print(f"  {tname}: {len(rows)} rows")

    cfc_path = os.path.join(OUTPUTS_DIR, "nipa_cfc.csv")
    n_cfc = rows_to_csv(all_cfc_rows, cfc_path)
    print(f"  Total CFC rows: {n_cfc}")

    # Step 4: Write vintage file
    print("\n[4/4] Writing vintage file...")
    vintage_path = os.path.join(OUTPUTS_DIR, "data_vintage.txt")
    with open(vintage_path, "w") as f:
        f.write(f"Data Source: BEA NIPA Supplementary Tables\n")
        f.write(f"Download Timestamp: {datetime.now().isoformat()}\n")
        f.write(f"API Endpoint: {BEA_API_BASE}\n")
        f.write(f"\nProprietors' Income Tables:\n")
        f.write(f"  Tables attempted: {', '.join(prop_income_tables)}\n")
        f.write(f"  Rows downloaded: {n_prop}\n")
        f.write(f"\nConsumption of Fixed Capital Tables:\n")
        f.write(f"  Tables attempted: {', '.join(cfc_tables)}\n")
        f.write(f"  Rows downloaded: {n_cfc}\n")

    print(f"\nDone. Files saved to {OUTPUTS_DIR}/")
    if n_prop == 0:
        print("  WARNING: No proprietors' income data downloaded.", file=sys.stderr)
        print("  You may need to identify the correct table names from the inventory.",
              file=sys.stderr)
    if n_cfc == 0:
        print("  WARNING: No CFC data downloaded.", file=sys.stderr)


if __name__ == "__main__":
    main()
