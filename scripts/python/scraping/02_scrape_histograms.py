"""
File:      02_scrape_histograms.py
Purpose:   For each frame establishment, pull the published per-star rating
           HISTOGRAM from Google and Yelp via Apify, verify the returned place
           matches the frame (tight coordinate radius + name similarity), and
           write a normalized long table. Also logs retrievability + match rate
           (proposal §3 measurement note; risk #2).
Inputs:    data/scraped/frame_pilot.csv; Apify (via apify_runner).
Outputs:   data/scraped/histograms_long.csv  (est_id, platform, star, count, verified)
           data/scraped/scrape_log.csv        (est_id, platform, status)
Run order: after 01_build_frame.py.

CONFIRM before trusting: the per-platform input builders and the histogram/coord/
name extractors below are written defensively against COMMON actor outputs but are
NOT verified in this repo. Any record whose histogram cannot be located is logged
as `no_histogram` rather than silently dropped or fabricated.
"""
from __future__ import annotations
import math, re, sys
import pandas as pd

import config
from apify_runner import run_actor

# --------------------------------------------------------------------------- #
# Geometry + name similarity (no external deps)
# --------------------------------------------------------------------------- #
def haversine_m(lat1, lon1, lat2, lon2) -> float:
    R = 6_371_000.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = math.radians(lat2 - lat1), math.radians(lon2 - lon1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * R * math.asin(min(1.0, math.sqrt(a)))

def name_sim(a: str, b: str) -> float:
    """Jaccard over lowercased alphanumeric tokens — in [0, 1]."""
    ta = set(re.findall(r"[a-z0-9]+", (a or "").lower()))
    tb = set(re.findall(r"[a-z0-9]+", (b or "").lower()))
    if not ta or not tb:
        return 0.0
    return len(ta & tb) / len(ta | tb)

# --------------------------------------------------------------------------- #
# Per-platform actor input + defensive extractors  (CONFIRM for your actors)
# --------------------------------------------------------------------------- #
def google_input(row) -> dict:
    return {"searchStringsArray": [f'{row["name"]} {row["address"]}'],
            "maxCrawledPlacesPerSearch": 1, "language": "en"}

def yelp_input(row) -> dict:
    return {"searchTerms": [row["name"]], "locations": [config.METRO], "maxItems": 1}

def _first(d: dict, *keys):
    for k in keys:
        if isinstance(d, dict) and d.get(k) not in (None, "", []):
            return d[k]
    return None

def extract_histogram(rec: dict, platform: str) -> dict | None:
    """Return {1..5: count} or None if not locatable. Tries common shapes."""
    dist = _first(rec, "reviewsDistribution", "ratingDistribution",
                  "reviewCountsByRating", "starDistribution", "histogram")
    if dist is None:
        return None
    # Shape A: dict keyed by word ({oneStar:..,..,fiveStar:..})
    words = {"oneStar": 1, "twoStar": 2, "threeStar": 3, "fourStar": 4, "fiveStar": 5}
    if isinstance(dist, dict) and any(w in dist for w in words):
        h = {s: 0 for s in config.STARS}
        for w, s in words.items():
            if dist.get(w) is not None:
                h[s] = int(dist[w])
        return h
    # Shape B: dict keyed by star number/string ({"1":..,"5":..})
    if isinstance(dist, dict):
        try:
            h = {s: int(dist.get(str(s), dist.get(s, 0)) or 0) for s in config.STARS}
            if sum(h.values()) > 0:
                return h
        except (TypeError, ValueError):
            pass
    # Shape C: list of 5 counts, ascending 1★→5★
    if isinstance(dist, (list, tuple)) and len(dist) == 5:
        try:
            return {s: int(dist[i] or 0) for i, s in enumerate(config.STARS)}
        except (TypeError, ValueError):
            return None
    return None

def extract_coords(rec: dict, platform: str):
    loc = _first(rec, "location", "coordinates", "coordinate") or {}
    lat = _first(rec, "latitude", "lat") or (loc.get("lat") if isinstance(loc, dict) else None)
    lon = _first(rec, "longitude", "lng", "lon") or (loc.get("lng") if isinstance(loc, dict) else None)
    try:
        return float(lat), float(lon)
    except (TypeError, ValueError):
        return None, None

def extract_name(rec: dict, platform: str) -> str:
    return str(_first(rec, "title", "name", "businessName") or "")

# --------------------------------------------------------------------------- #
def scrape_platform(row, platform, actor, run_input, retries):
    """Return (histogram|None, status)."""
    try:
        items = run_actor(actor, run_input, retries=retries)
    except RuntimeError as e:
        print(f"    [{platform}] error: {e}", file=sys.stderr)
        return None, "error"
    if not items:
        return None, "no_result"
    rec = items[0]
    hist = extract_histogram(rec, platform)
    if hist is None or sum(hist.values()) == 0:
        return None, "no_histogram"
    # Verify the returned place is the frame establishment.
    verified = None
    rlat, rlon = extract_coords(rec, platform)
    nsim = name_sim(row["name"], extract_name(rec, platform))
    if rlat is not None and rlon is not None:
        dist_m = haversine_m(row["lat"], row["lon"], rlat, rlon)
        verified = (dist_m <= config.MATCH_RADIUS_M) and (nsim >= config.NAME_SIM_THRESHOLD)
        if not verified:
            return None, "match_failed"
    else:
        verified = None if nsim >= config.NAME_SIM_THRESHOLD else False
        if verified is False:
            return None, "match_failed"
    hist["_verified"] = verified            # None = coord-unverified but name-matched
    return hist, "ok"


def main() -> int:
    frame_path = config.DATA_SCRAPED / "frame_pilot.csv"
    if not frame_path.exists():
        print("[02] run 01_build_frame.py first.", file=sys.stderr)
        return 1
    frame = pd.read_csv(frame_path)

    long_rows, log_rows = [], []
    for est_id, row in frame.iterrows():
        for platform, actor, build, retries in (
            ("google", config.GOOGLE_ACTOR, google_input, config.GOOGLE_RETRIES),
            ("yelp", config.YELP_ACTOR, yelp_input, config.YELP_RETRIES),
        ):
            hist, status = scrape_platform(row, platform, actor, build(row), retries)
            log_rows.append({"est_id": est_id, "platform": platform, "status": status})
            if hist is not None:
                verified = hist.pop("_verified")
                for s in config.STARS:
                    long_rows.append({"est_id": est_id, "name": row["name"],
                                      "platform": platform, "star": s,
                                      "count": hist[s], "verified": verified})
        if (est_id + 1) % 25 == 0:
            print(f"[02] {est_id + 1}/{len(frame)} establishments processed")

    long = pd.DataFrame(long_rows)
    log = pd.DataFrame(log_rows)
    long.to_csv(config.DATA_SCRAPED / "histograms_long.csv", index=False)
    log.to_csv(config.DATA_SCRAPED / "scrape_log.csv", index=False)

    # Retrievability + match summary (proposal §3; risk #2).
    print("\n[02] status counts by platform:")
    print(log.groupby(["platform", "status"]).size().unstack(fill_value=0).to_string())
    have = long.groupby("platform")["est_id"].nunique()
    both = long.pivot_table(index="est_id", columns="platform", values="count",
                            aggfunc="sum").dropna()
    print(f"\n[02] establishments with a histogram — "
          f"{have.to_dict()}; matched on BOTH platforms: {len(both)} "
          f"({100 * len(both) / len(frame):.0f}% of frame)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
