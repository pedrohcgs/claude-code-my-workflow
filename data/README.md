# Data Sources

This directory contains data for the project. Raw and intermediate data files are **gitignored** (too large or sensitive for version control).

## How to Obtain the Data

| Dataset | Source | Access | Notes |
|---------|--------|--------|-------|
| Compustat | WRDS | Institutional subscription | Firm-level financials |
| CRSP | WRDS | Institutional subscription | Stock returns |
| Bank call reports | FFIEC / WRDS | Public | Bank balance sheets |
| TBD | TBD | TBD | TBD |

## Directory Structure

- `raw/` — Original downloaded data (never modify)
- `intermediate/` — Cleaned, merged, analysis-ready datasets

## Reproducibility

To reproduce the analysis from scratch:
1. Download raw data from the sources above
2. Place files in `data/raw/` following the naming conventions in the do-files
3. Run `scripts/Stata/master.do` from the project root
