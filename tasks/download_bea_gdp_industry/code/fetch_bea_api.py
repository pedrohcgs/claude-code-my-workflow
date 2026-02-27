#!/usr/bin/env python3
"""
Fetch BEA GDP-by-Industry data via the BEA API.

Downloads value added and its components (compensation of employees,
gross operating surplus, taxes on production less subsidies) by
NAICS industry, annual, all available years.

Usage:
    python3 fetch_bea_api.py

Requires:
    - BEA API key in ../input/bea_api_key.txt
    - Python 3.6+ (uses only stdlib: json, urllib, csv, os, datetime)

Outputs saved to ../output/:
    - bea_va_components.csv
    - bea_va_levels.csv
    - bea_table_inventory.txt
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

# --- Configuration ---
BEA_API_BASE = "https://apps.bea.gov/api/data"
DATASET = "GDPbyIndustry"

# Directories relative to this script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(SCRIPT_DIR, "..", "input")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "..", "output")


def read_api_key():
    """Read BEA API key from input directory."""
    key_file = os.path.join(INPUT_DIR, "bea_api_key.txt")
    if not os.path.exists(key_file):
        print(f"ERROR: API key not found at {key_file}", file=sys.stderr)
        print("Sign up for a free key at: https://apps.bea.gov/api/signup/", file=sys.stderr)
        sys.exit(1)
    with open(key_file) as f:
        return f.read().strip()


def bea_api_call(params):
    """Make a BEA API call and return parsed JSON."""
    url = f"{BEA_API_BASE}?{urlencode(params)}"
    print(f"  Calling: {BEA_API_BASE}?Method={params.get('Method', 'N/A')}"
          f"&TableName={params.get('TableName', 'N/A')}")
    try:
        req = Request(url)
        with urlopen(req, timeout=120) as response:
            data = json.loads(response.read().decode("utf-8"))
        return data
    except HTTPError as e:
        print(f"  HTTP Error {e.code}: {e.reason}", file=sys.stderr)
        return None
    except URLError as e:
        print(f"  URL Error: {e.reason}", file=sys.stderr)
        return None


def get_available_tables(api_key):
    """Discover available table names in the GDPbyIndustry dataset."""
    params = {
        "UserID": api_key,
        "Method": "GetParameterValues",
        "DataSetName": DATASET,
        "ParameterName": "TableID",
        "ResultFormat": "JSON",
    }
    data = bea_api_call(params)
    if data is None:
        return []

    try:
        results = data["BEAAPI"]["Results"]["ParamValue"]
        return results
    except (KeyError, TypeError):
        # Try alternate response structure
        try:
            results = data["BEAAPI"]["Results"]["Parameter"]["Value"]
            if isinstance(results, dict):
                results = [results]
            return results
        except (KeyError, TypeError):
            print("  WARNING: Could not parse table inventory", file=sys.stderr)
            return []


def fetch_table_data(api_key, table_id, year="ALL", frequency="A"):
    """Fetch data for a specific table from BEA API."""
    params = {
        "UserID": api_key,
        "Method": "GetData",
        "DataSetName": DATASET,
        "TableID": table_id,
        "Industry": "ALL",
        "Frequency": frequency,
        "Year": year,
        "ResultFormat": "JSON",
    }
    data = bea_api_call(params)
    if data is None:
        return []

    try:
        rows = data["BEAAPI"]["Results"]["Data"]
        return rows
    except (KeyError, TypeError):
        try:
            rows = data["BEAAPI"]["Results"][0]["Data"]
            return rows
        except (KeyError, TypeError, IndexError):
            print(f"  WARNING: No data returned for TableID={table_id}", file=sys.stderr)
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
    print("BEA GDP-by-Industry Data Download")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)

    api_key = read_api_key()
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Step 1: Discover available tables
    print("\n[1/3] Discovering available tables...")
    tables = get_available_tables(api_key)

    inventory_path = os.path.join(OUTPUT_DIR, "bea_table_inventory.txt")
    with open(inventory_path, "w") as f:
        f.write(f"BEA {DATASET} Table Inventory\n")
        f.write(f"Downloaded: {datetime.now().isoformat()}\n")
        f.write("=" * 60 + "\n\n")
        for t in tables:
            # Handle different response formats
            tid = t.get("TableID", t.get("Key", "?"))
            desc = t.get("Description", t.get("Desc", "No description"))
            f.write(f"TableID: {tid:>6}  {desc}\n")
    print(f"  Found {len(tables)} tables. Inventory saved to bea_table_inventory.txt")

    # Step 2: Fetch VA components table
    # The key tables we need:
    #   - Value added by industry (often TableID=1 or similar)
    #   - Components of value added (compensation, GOS, taxes)
    # We try several common table IDs. The exact IDs vary by BEA API version.
    # Strategy: fetch table inventory, identify the right ones, then download.

    # Common table IDs for GDP-by-Industry:
    #   1 = Value Added by Industry
    #   5 = Components of Value Added by Industry
    #   6 = Components of Value Added by Industry (%)
    #   8 = Chain-Type Quantity Indexes for Value Added by Industry

    print("\n[2/3] Fetching value added components by industry...")
    va_components_tables = ["5", "6", "1"]
    all_va_rows = []
    for tid in va_components_tables:
        rows = fetch_table_data(api_key, tid)
        if rows:
            for row in rows:
                row["SourceTableID"] = tid
            all_va_rows.extend(rows)
            print(f"  TableID={tid}: {len(rows)} rows")

    va_path = os.path.join(OUTPUT_DIR, "bea_va_components.csv")
    n_va = rows_to_csv(all_va_rows, va_path)
    print(f"  Total VA component rows: {n_va}")

    # Step 3: Fetch chain-type quantity indexes
    print("\n[3/3] Fetching chain-type quantity indexes...")
    chain_rows = fetch_table_data(api_key, "8")
    if not chain_rows:
        # Try alternative table IDs
        for alt_tid in ["25", "10"]:
            chain_rows = fetch_table_data(api_key, alt_tid)
            if chain_rows:
                break

    chain_path = os.path.join(OUTPUT_DIR, "bea_chain_indexes.csv")
    n_chain = rows_to_csv(chain_rows, chain_path)
    print(f"  Chain index rows: {n_chain}")

    # Step 4: Write vintage file
    vintage_path = os.path.join(OUTPUT_DIR, "data_vintage.txt")
    with open(vintage_path, "w") as f:
        f.write(f"Data Source: BEA GDP-by-Industry ({DATASET})\n")
        f.write(f"Download Timestamp: {datetime.now().isoformat()}\n")
        f.write(f"API Endpoint: {BEA_API_BASE}\n")
        f.write(f"Tables Fetched: {', '.join(va_components_tables)} (VA components), 8 (chain indexes)\n")
        f.write(f"VA Component Rows: {n_va}\n")
        f.write(f"Chain Index Rows: {n_chain}\n")
        f.write(f"Industry Filter: ALL (filtered downstream in Stata)\n")
        f.write(f"Frequency: Annual\n")
        f.write(f"Years: ALL available\n")

    print(f"\nDone. Files saved to {OUTPUT_DIR}/")
    print(f"  bea_va_components.csv ({n_va} rows)")
    print(f"  bea_chain_indexes.csv ({n_chain} rows)")
    print(f"  bea_table_inventory.txt ({len(tables)} tables)")
    print(f"  data_vintage.txt")


if __name__ == "__main__":
    main()
