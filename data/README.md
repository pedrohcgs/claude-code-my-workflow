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
DS_LIB=...                 # your WRDS Datastream library name (browse WRDS to find it)
ORBIS_LIB=...              # your WRDS Orbis/BvD library (only if IPO_USE_ORBIS=1)
```

Optional switches: `IPO_SAMPLE_START` / `IPO_SAMPLE_END` (default 1995 / 2024);
`IPO_USE_ORBIS=1` to enable the optional Orbis cross-check.

| Source | Pull | Key fields |
| --- | --- | --- |
| **CRSP** (US) | daily+monthly stock, names, delisting, market index (`crsp.msi`), FF rf (`ff.factors_monthly`) | `permno`, `shrcd` (10/11), `exchcd` (1/2/3), first `date`, `prc`, `ret`, `dlret`, `dlstcd`, `vwretd` |
| **Compustat NA + CCM** (US) | firm characteristics via `crsp.ccmxpf_lnkhist` | `gvkey`, `ipodate`, `sale`, `at`, `sich` |
| **Ritter files** (US) | public download → `data/raw/ritter/` (offer prices, founding dates, underwriter rank, VC/dual-class); needs a `permno`↔`offer_price` crosswalk | from site.warrington.ufl.edu/ritter/ipo-data (cite with attribution) |
| **Datastream** (EU/UK, via WRDS `$DS_LIB`) | `RI` (returns), `UP` (UK offer price @ `BDATE`), `P#S` (first-trade dating), `BDATE`; **union active + dead lists** | confirm the `$DS_LIB` table/column names in WRDS; validated by `assert_fields()` |
| **Compustat Global + Worldscope** (EU/UK) | `comp.g_company.ipodate`, incorporation (Worldscope field **18273** = `item18273`), accounting | verify the Worldscope IPO/first-traded code (research flagged `WC05905` as likely wrong — use Compustat `ipodate` + Datastream instead) |
| **Orbis** (EU/UK, via WRDS `$ORBIS_LIB`) — **OPTIONAL** | robustness cross-check only: BvD-ID linking + incorporation date | OFF by default; not a returns/offer-price source, not load-bearing |

**Confirm before trusting** (assertions fire at load — see `functions_data.R::assert_fields`):
the Worldscope IPO field code; Compustat `ipodate` release history; the UK-only
`BDATE`−1 offset (verify per Continental venue).
