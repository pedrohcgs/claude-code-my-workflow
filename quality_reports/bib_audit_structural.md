# Bibliography Structural Audit
**Date:** 2026-04-27
**Bibliography:** `Paper/BID_Bib.bib` (33 entries after duplicate removal)
**File scanned:** `Paper/main.tex`

---

## Summary

| Check | Critical | Medium | Low |
|---|---|---|---|
| Missing entries | 0 | — | — |
| Duplicate keys | 1 (fixed) | — | — |
| Unused entries | — | — | 6 |
| Entry quality | 0 | 5 (legacy month fields) | — |

**Overall: PASS** — no blocking issues remain.

---

## Fixed

### Duplicate key: `Lee2022`
The key appeared twice — once as `@article{Lee2022` and once as `@Article{Lee2022`. Both described the same paper (Lee, McCrary, Moreira & Porter, AER 2022). The first occurrence (lowercase, missing `url` field) was removed. The second occurrence (with `url`) was retained.

Note: `Lee2022` is not cited in `main.tex` — it is an unused entry.

---

## Unused Entries (informational — not an error)

These keys are defined in `BID_Bib.bib` but never cited in `main.tex`:

| Key | Reference | Action |
|---|---|---|
| `Brouwer2019` | Brouwer et al. (2019), *Eur J Health Econ* — CET when is it too expensive | Keep — potentially useful for revision |
| `Filmer1999` | Filmer & Pritchett (1999), *Social Sci & Med* — public spending on health | Keep or remove — not currently cited |
| `Lee2022` | Lee et al. (2022), AER — Valid t-Ratio Inference for IV | Keep — may be cited in robustness section |
| `NCHS2017` | National Center for Health Statistics (2017) | Keep or remove |
| `rubin1974estimating` | Rubin (1974), *J Educational Psychology* — causal effects | Remove if not needed |
| `Siverskog2021` | Siverskog & Henriksson (2021), *IJTAHC* — CET role in priority setting | Keep — related to literature review |

**Recommendation:** no action required now; review before final submission.

---

## Missing Entries

**None.** All 26 citation keys used in `main.tex` are present in `BID_Bib.bib`.

---

## Entry Quality

All 26 cited entries have required fields (author, title, year, journal/institution). No malformed author fields or encoding issues detected.

**Pre-existing biber warnings (non-blocking):**
Five entries use legacy string month fields that biber flags but handles correctly:
- `Claxton2015`: `month = {feb}`
- `Culyer2016`: `month = {October}`
- `Edney2018`: `month = {February}`
- `Martin2021`: `month = {jul}`
- `Bailey2022`: `month = {aug}`

These do not affect compilation or citation rendering. To silence: change to integer months (e.g., `month = 2`) or remove the field.

---

## Citation Keys Used in `main.tex` (26 total)

| Key | Entry type | Status |
|---|---|---|
| Bailey2022 | @Article | ✅ |
| Benson2019 | @Article | ✅ |
| Brazil2021 | @TechReport | ✅ |
| Chernozhukov2008 | @Article | ✅ |
| Claxton2015 | @Article | ✅ |
| Culyer2016 | @Article | ✅ |
| Edney2018 | @Article | ✅ |
| Edney2022 | @Article | ✅ |
| Eichenbaum1988 | @Article | ✅ |
| Espinosa2021 | @Article | ✅ |
| Espinosa2024 | @Article | ✅ |
| GBDC2019 | @Misc | ✅ |
| Hayashi2000 | @Book | ✅ |
| K.Newey1985 | @Article | ✅ |
| Lavancier2016 | @Article | ✅ |
| Marshall2010 | @Inbook | ✅ |
| Martin2021 | @Article | ✅ |
| OPS2008 | @Booklet | ✅ |
| Pandey2018 | @TechReport | ✅ |
| PichonRiviere2021 | @TechReport | ✅ |
| PichonRiviere2023 | @Article | ✅ |
| Sampson2022 | @Article | ✅ |
| StockYogo2005 | @inbook | ✅ |
| Vallejo2018 | @article | ✅ |
| WHO2022 | @Misc | ✅ |
| Woods2016 | @article | ✅ |
