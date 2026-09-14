"""
File:     config.py
Purpose:  Central configuration for the Silence-of-the-Satisfied histogram pilot.
          The pilot tests ONE thing (proposal risk #1): does a cross-platform
          rating-distribution SHAPE gap exist at all? If not, the project stops.
Inputs:   env var APIFY_TOKEN; a municipal licensing CSV (see FRAME_CSV).
Outputs:  none (imported by the 0N_*.py scripts).

HONEST CAVEATS — read before running:
  * You must supply an Apify token (env APIFY_TOKEN) and confirm the ACTOR IDs +
    their input/output schemas below. Third-party actor schemas change and are
    NOT verified in this repo — 02_scrape_histograms.py parses defensively and
    logs any establishment whose star histogram it cannot locate.
  * Respect each platform's Terms of Service and rate limits. Raw responses are
    cached so re-runs do not re-hit the platforms.
"""
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parents[3]                 # repo root — no absolute paths
DATA_SCRAPED = ROOT / "data" / "scraped"
OUT = ROOT / "scripts" / "python" / "_outputs"
CACHE = DATA_SCRAPED / "cache"                             # raw actor responses (cache; do not commit)
for d in (DATA_SCRAPED, OUT, CACHE):
    d.mkdir(parents=True, exist_ok=True)

SEED = 20260914                                            # deterministic frame sample

# ---- Pilot scope -----------------------------------------------------------
METRO = "Chicago"
PILOT_N = 300                                              # a few hundred establishments (proposal §8)

# ---- Establishment frame (municipal licensing / inspection file) -----------
# Concrete source: Chicago "Food Inspections" open dataset (data.cityofchicago.org)
# has columns DBA Name / Address / Latitude / Longitude. Point FRAME_CSV at a
# local export and confirm the column names below.
FRAME_CSV = DATA_SCRAPED / "chicago_food_inspections.csv"
FRAME_COLS = {                                             # confirm against your export
    "name": "DBA Name",
    "address": "Address",
    "lat": "Latitude",
    "lon": "Longitude",
    "category": "Facility Type",                          # keep only restaurants (see 01_build_frame.py)
}
RESTAURANT_FACILITY_VALUES = {"Restaurant"}               # Facility Type values to keep

# ---- Apify ----------------------------------------------------------------
APIFY_TOKEN = os.environ.get("APIFY_TOKEN")               # never hardcode a token
# CONFIRM these actor IDs and that each returns a per-star rating breakdown.
# Placeholders use common public-actor slugs; verify the actual I/O before trusting.
GOOGLE_ACTOR = os.environ.get("APIFY_GOOGLE_ACTOR", "compass/crawler-google-places")
YELP_ACTOR = os.environ.get("APIFY_YELP_ACTOR", "yin/yelp-scraper")
ACTOR_TIMEOUT_S = 600
GOOGLE_RETRIES = 2
YELP_RETRIES = 4                                          # Yelp is more adversarial (proposal §3)
BACKOFF_BASE_S = 5

# ---- Matching (cross-platform ↔ frame) ------------------------------------
MATCH_RADIUS_M = 75                                       # tight coordinate agreement
NAME_SIM_THRESHOLD = 0.60                                 # token-set ratio in [0,1]

# ---- Star levels -----------------------------------------------------------
STARS = (1, 2, 3, 4, 5)
