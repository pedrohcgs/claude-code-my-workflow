# Claim Verification Report — `Paper/main.tex`
**Date:** 2026-04-27  
**Method:** Chain-of-Verification against table source files  
**Sources:** `Paper/Tables/ManyIVTab.tex`, `ManyIVTab_V2.tex`, `Oracle.tex`, `InstrumentValidityIVTab.tex`

---

## Summary

| Outcome | Count |
|---|---|
| ✅ PASS | 18 |
| ❌ Fixed | 4 |
| ⚠️ Cannot verify from tables | 1 |

**Overall: PASS** (after fixes applied)

---

## Fixed Discrepancies

### D1 — AVAD upper GDP% (body text)
- **Claim:** "between 26% and **32%** of per capita GDP"
- **Calculation:** 107,824 / 330,949 = **32.58%** → rounds to **33%**
- **Fix applied:** changed to 33%

### D2 — AVAC lower GDP% (body text)
- **Claim:** "between **32%** and 41% of per capita GDP"
- **Calculation:** 108,349 / 330,949 = **32.74%** → rounds to **33%**
- **Fix applied:** changed to 33%

### D3 — AVAC upper GDP% (body text)
- **Claim:** "between 32% and **41%** of per capita GDP"
- **Calculation:** 138,180 / 330,949 = **41.75%** → rounds to **42%**
- **Fix applied:** changed to 42%

### D4 — Spain CET range in Introduction
- **Claim:** "between €22,000 and €25,000 for Spain"
- **Source (Vallejo-Torres 2018 abstract):** "between €21,000 and €24,000"
- **Fix applied:** corrected to €21,000–€24,000; Australia value corrected to AUD 28,033

---

## Additional Fix (compile error exposed by babel change)
- **`P_m^*_{a}`** — double subscript error at line 390. Fixed to `P^*_{a,m}`.

---

## Verified Claims (all PASS)

| ID | Claim | Source | Result |
|---|---|---|---|
| N1 | CET = 86,498 DOP | ManyIVTab col 1: 86.498 × 1,000 | ✅ |
| N2 | CI lower = 40,832 DOP | ManyIVTab col 1: [40.832, 132.165] | ✅ |
| N3 | CI upper = 132,165 DOP | ManyIVTab col 1 | ✅ |
| N4 | Elasticity = −0.356 (SE 0.114) | ManyIVTab col 1 Panel B | ✅ |
| N5 | CET = 26% of GDP | 86,498/330,949 = 26.14% → 26% | ✅ |
| N6 | CI lower = 12.3% of GDP | 40,832/330,949 = 12.34% → 12.3% | ✅ |
| N7 | CI upper = 39.9% of GDP | 132,165/330,949 = 39.94% → 39.9% | ✅ |
| N8 | AVAD range upper = 107,824 DOP | ManyIVTab col 4 | ✅ |
| N9 | Oracle AVAD = 94,615 DOP | Oracle.tex col 1 | ✅ |
| N10 | Oracle AVAD = 29% of GDP | 94,615/330,949 = 28.59% → 29% | ✅ |
| N11 | Oracle AVAC = 128,164 DOP | Oracle.tex col 2 | ✅ |
| N12 | Oracle AVAC = 39% of GDP | 128,164/330,949 = 38.73% → 39% | ✅ |
| N13 | AVAC col 1 = 108,349 DOP | ManyIVTab_V2 col 1 | ✅ |
| N14 | AVAC col 4 = 138,180 DOP | ManyIVTab_V2 col 4 | ✅ |
| N15 | C-statistic = 3.72, p-value = 0.44 | InstrumentValidityIVTab col 5 | ✅ |
| N16 | F-statistic > 16.38 all specs | Min F = 18.73 (col 3) > 16.38 | ✅ |
| N17 | N = 10,626 (preferred spec) | All ManyIVTab cols | ✅ |
| N18 | Martin (2021): £5,000–£10,000/QALY | Martin 2021 abstract | ✅ |

## Unverifiable

| ID | Claim | Reason |
|---|---|---|
| U1 | Per capita GDP 2016 = 330,949 DOP | Requires official BCRD data not yet confirmed from source |
