# `data/` — Local data (mostly gitignored)

This directory holds project data. **Raw and licensed data are gitignored and must
never be committed** — see [`.claude/rules/confidential-data.md`](../.claude/rules/confidential-data.md).

## Layout

| Path | Contents | Tracked in git? |
| --- | --- | --- |
| `data/wrds/` | Raw WRDS extracts (CRSP, Compustat, SDC/new-issues, Datastream) | **No** — licensed, redistribution-restricted |
| `data/raw/` | Other raw inputs (e.g. downloaded Ritter IPO files) | **No** |
| `data/derived/` | Derived, non-confidential aggregates used by the paper/deck | Case-by-case (aggregates only) |
| `data/README.md` | This file | Yes |

## Access

- **WRDS:** requires an institutional subscription. Credentials go in a gitignored
  `.Renviron` (`WRDS_USER=` / `WRDS_PASS=`), read at runtime — never hardcoded, never
  committed.
- **Ritter IPO data:** public-with-attribution from Jay Ritter's site; download into
  `data/raw/` and cite the source. Still not committed as raw files here.

Only **code** (`scripts/`) and **derived, aggregated, non-confidential outputs** are
committed. When unsure whether an output is aggregate enough to share, treat it as
licensed until confirmed.

---

## Acquisition checklist (what to pull, per source)

The pipeline (`scripts/R/`) runs on **synthetic data** until these are supplied.
**Everything is accessed via WRDS** (one RPostgres connection) — including Datastream
and Orbis. Set credentials in a gitignored `.Renviron` at the repo root, then unset
`IPO_USE_SYNTHETIC` to switch to real pulls.

**`.Renviron` keys** (never commit this file):

```
WRDS_USER=your_wrds_login
WRDS_PASS=...              # or use ~/.pgpass
```

The WRDS schema names are now **confirmed defaults in the code** (no per-institution
library guessing needed), overridable via env only if your WRDS layout differs:
`IPO_DS_SCHEMA` (default `tr_ds_equities`), `IPO_ORBIS_TIERS`
(default `bvd_orbis_large,bvd_orbis_medium,bvd_orbis_small`), `IPO_CG_SCHEMA`
(`comp`), `IPO_WS_SCHEMA` (`tr_ws`).

Optional switches: `IPO_SAMPLE_START` / `IPO_SAMPLE_END` (default 1995 / 2024);
`IPO_USE_ORBIS=1` to enable the optional Orbis cross-check.

| Source | Pull | Key fields |
| --- | --- | --- |
| **CRSP** (US) | daily+monthly stock, names, delisting, market index (`crsp.msi`), FF rf (`ff.factors_monthly`) | `permno`, `shrcd` (10/11), `exchcd` (1/2/3), first `date`, `prc`, `ret`, `dlret`, `dlstcd`, `vwretd` |
| **Compustat NA + CCM** (US) | firm characteristics via `crsp.ccmxpf_lnkhist` | `gvkey`, `ipodate`, `sale`, `at`, `sich` |
| **Ritter files** (US) | public download → `data/raw/ritter/` (offer prices, founding dates, underwriter rank, VC/dual-class); needs a `permno`↔`offer_price` crosswalk | from site.warrington.ufl.edu/ritter/ipo-data (cite with attribution) |
| **Datastream** (EU/UK, `tr_ds_equities`) | Security master `wrds_ds_names_full` (`infocode`, `cmpyctrycode` ISO-2 [UK=`GB`], `typecode='EQ'`, `isprimqt=1`, `statuscode` A/D/S, `isin`); daily file `wrds_ds2dsf` (`ri` total-return index, `ret` local daily return, `close` **unadjusted** [UK offer-price proxy at first trade], `adjclose`, `numshrs`, `mktcap`, `currency`) | first-trade = MIN `marketdate` per `infocode` (never `startdate` — it clusters at the DS2 extract start); **union active+dead** = keep all `statuscode`; coverage confirmed 1964→present |
| **Compustat Global + Worldscope** (EU/UK) | `comp.g_company.ipodate` (`loc` ISO-3), incorporation (Worldscope `tr_ws.wrds_ws_company.item18273`), ISIN link (`item6105`) | Compustat `ipodate` cross-checks the DS first-trade date; the Worldscope IPO/first-traded code stays unused (research flagged `WC05905` as likely wrong) |
| **Orbis** (EU/UK, `bvd_orbis_{large,medium,small}`) — **OPTIONAL** | robustness cross-check only: `ob_identifiers_*.sd_isin`→`bvdid`, `ob_legal_info_*` (`dateinc`, `ipo_date`, `delisted_date`); unioned across tiers | OFF by default (`IPO_USE_ORBIS=1`); not a returns/offer-price source, not load-bearing |

All schema/field names above were **confirmed against the live WRDS data dictionary on
2026-07-04**; `assert_fields()` re-validates them at load. Still to confirm on the first
full run: the EU per-venue benchmark index `infocode`s, the ISIN link policy across
DS/CG/WS/Orbis, and (for Continental underpricing, a later extension) the offer-price source.
