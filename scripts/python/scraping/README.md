# scripts/python/scraping/ — the histogram pilot (tests risk #1)

This pilot answers **one** question as cheaply and decisively as possible (proposal §8; the
make-or-break "does a shape gap exist at all" risk): for the same establishment, is the **Google**
rating-distribution *shape* less polarized than **Yelp**'s (H1)? If the distributions are
indistinguishable, the project stops here having cost almost nothing.

It uses only **published establishment-level star histograms** — free, complete, and identical to what
consumers see — so it avoids the main measurement risk in review studies (non-random review scraping).

## Run order

| Script | Does |
| --- | --- |
| `01_build_frame.py` | Build the pilot frame (distinct restaurants + coords) from a municipal licensing/inspection file; deterministic sample of `PILOT_N`. |
| `02_scrape_histograms.py` | Pull each establishment's per-star histogram from Google + Yelp via Apify; verify the match (coord radius + name); log retrievability + match rate. |
| `03_shape_gap.py` | Compute shape moments per platform; paired within-establishment H1 tests; **GO / STOP verdict** + moments table + figure. |

```bash
pip install pandas numpy scipy matplotlib apify-client
export APIFY_TOKEN=...                 # required; never hardcode
# optional: export APIFY_GOOGLE_ACTOR=... APIFY_YELP_ACTOR=...
python scripts/python/scraping/01_build_frame.py
python scripts/python/scraping/02_scrape_histograms.py
python scripts/python/scraping/03_shape_gap.py
```

## You must supply / confirm

1. **`APIFY_TOKEN`** (env var).
2. **A licensing file** at `data/scraped/chicago_food_inspections.csv` (or repoint `config.FRAME_CSV`).
   Concrete source: Chicago *Food Inspections* open dataset (`data.cityofchicago.org`) — has
   `DBA Name / Address / Latitude / Longitude`. Confirm the column names in `config.FRAME_COLS`.
3. **The Apify actor IDs** (`config.GOOGLE_ACTOR`, `config.YELP_ACTOR`) **and that each returns a
   per-star rating breakdown.** This is the one thing that cannot be verified from inside this repo —
   third-party actor input/output schemas vary and change. `02_scrape_histograms.py` parses defensively
   (tries several common histogram shapes) and logs any establishment whose histogram it cannot locate as
   `no_histogram` rather than dropping or fabricating it. **Verify the extractor against your chosen
   actor's real output on a handful of places before trusting a full run.**

## Honesty + hygiene

- **Respect each platform's Terms of Service and rate limits.** Yelp is more adversarial (more retries,
  slower). Raw actor responses are cached under `data/scraped/cache/` so re-runs do not re-hit platforms.
- **No fabricated data** — the scripts produce output only from real actor responses.
- Reproducibility: `pathlib` paths (no absolutes), a single seed for the frame sample, versioned via
  `/capture-environment` before any real run.

## Reading the verdict (`scripts/python/_outputs/pilot_verdict.txt`)

- **GO** — all 3 core shape moments (variance, polarization, middle mass) differ in the predicted
  direction and significantly → proceed to Stage 2 (review-level collection for H2/H6–H8).
- **MIXED** — 1–2 of 3 confirmed → inspect moments + figure; consider a larger frame first.
- **STOP** — no core moment differs → distributions look indistinguishable; the project ends here.

Because 5-bin histograms with small counts are coarse, the verdict weighs **direction + median effect
size**, not p-values alone, and reports results both on all matched establishments and restricted to
those with ≥ `MIN_REVIEWS` per platform. Figure: `fig_shape_gap.{pdf,png}` (points off the 45° line = a gap).
