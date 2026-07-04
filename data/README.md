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
