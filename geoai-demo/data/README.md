# data/

## What to put here

**File:** `Volve production data.xlsx` (two sheets: "Daily Production Data",
"Monthly Production Data"; ~15,600 daily rows, 2008–2016).

### Where to get it (fastest — recommended)

Kaggle: <https://www.kaggle.com/datasets/lamyalbert/volve-production-data>
Free account → **Download** → unzip → drop `Volve production data.xlsx` in this
folder. This is the just-the-production-table extract; it is all the demo needs.

### Official channel (heavier)

Equinor now distributes Volve **only via Databricks Marketplace**
(<https://www.equinor.com/energy/volve-data-sharing> → "Access open data").
The single listing there — **"Volve Data Village"** — is the *entire ~5 TB*
archive (seismic, logs, models, production) delivered through Databricks Delta
Sharing, with a 90-day auto-removal. You would need a Databricks workspace
(Free Edition works) to open it, then export the production table to CSV. Only
worth it if you want the official provenance on record.

The old file portal (`data.equinor.com`) is retired.

### After the file is here

The loader (`R/01_load_data.R`) searches `data/` for a file whose name contains
"production" ending in `.xlsx`/`.xls`, then falls back to any `.xlsx` or `.csv`.

## Expected columns (the loader is tolerant of naming variants)

| Purpose | Typical Volve column |
|---|---|
| Date | `DATEPRD` |
| Well name | `NPD_WELL_BORE_NAME` |
| Oil volume (Sm³) | `BORE_OIL_VOL` |
| Gas volume (Sm³) | `BORE_GAS_VOL` |
| Water volume (Sm³) | `BORE_WAT_VOL` |
| On-stream hours | `ON_STREAM_HRS` |
| Producer vs injector | `WELL_TYPE` (`OP` / `WI`) or `FLOW_KIND` |

## Attribution & licence

Volve data © Equinor and the former Volve licence partners (ExxonMobil E&P
Norway AS, Bayerngas Norge AS), released under the **Equinor Open Data Licence**
for research, study and development. Cite Equinor in any published material.

**Commercial note:** the licence states *"The data set shall not be resold."*
Using Volve to build and demo this tool is within the licence (learning /
innovation is the stated purpose). Do **not** repackage or sell the Volve data
itself. Paid-client deployments must use the client's own data or Kazakhstan
public data — not Volve.

## Not tracked in git

Everything in this folder except this README is git-ignored (raw data,
`processed/` outputs, and the synthetic test file).
