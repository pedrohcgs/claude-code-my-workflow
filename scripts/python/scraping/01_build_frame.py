"""
File:      01_build_frame.py
Purpose:   Build the pilot establishment frame from a municipal licensing/inspection
           file — distinct restaurants with valid coordinates — and draw a
           deterministic sample of PILOT_N (proposal §3, §8).
Inputs:    config.FRAME_CSV (municipal file).
Outputs:   data/scraped/frame_pilot.csv  (name, address, lat, lon).
Run order: first.
"""
from __future__ import annotations
import sys
import numpy as np
import pandas as pd

import config

rng = np.random.default_rng(config.SEED)   # seed ONCE; used only for the frame sample


def main() -> int:
    if not config.FRAME_CSV.exists():
        print(f"[01_build_frame] MISSING frame file: {config.FRAME_CSV}\n"
              f"  Download a municipal licensing/inspection export (e.g. Chicago "
              f"'Food Inspections' from data.cityofchicago.org) and place it there, "
              f"or point config.FRAME_CSV at your file.", file=sys.stderr)
        return 1

    c = config.FRAME_COLS
    df = pd.read_csv(config.FRAME_CSV, usecols=lambda x: x in set(c.values()))
    df = df.rename(columns={c["name"]: "name", c["address"]: "address",
                            c["lat"]: "lat", c["lon"]: "lon",
                            c["category"]: "category"})

    # Restaurants only, valid coordinates, one row per (name, address).
    df = df[df["category"].isin(config.RESTAURANT_FACILITY_VALUES)]
    df = df.dropna(subset=["name", "address", "lat", "lon"])
    df["name"] = df["name"].astype(str).str.strip()
    df["address"] = df["address"].astype(str).str.strip()
    df = df[(df["lat"].between(-90, 90)) & (df["lon"].between(-180, 180))]
    df = df.drop_duplicates(subset=["name", "address"]).reset_index(drop=True)

    n_avail = len(df)
    if n_avail == 0:
        print("[01_build_frame] No restaurants after filtering — check FRAME_COLS / "
              "RESTAURANT_FACILITY_VALUES.", file=sys.stderr)
        return 1

    take = min(config.PILOT_N, n_avail)
    idx = rng.choice(n_avail, size=take, replace=False)
    frame = df.iloc[np.sort(idx)][["name", "address", "lat", "lon"]].reset_index(drop=True)

    out = config.DATA_SCRAPED / "frame_pilot.csv"
    frame.to_csv(out, index=False)
    print(f"[01_build_frame] {n_avail} distinct restaurants available; "
          f"sampled {take} → {out}")
    if take < config.PILOT_N:
        print(f"[01_build_frame] NOTE: only {take} available (< PILOT_N={config.PILOT_N}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
