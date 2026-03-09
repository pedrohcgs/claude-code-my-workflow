# Has Nepal's Energy Surplus Changed the Growth Nexus? Time-Series Evidence, 2000–2024

**Status:** DRAFT
**Quality score:** —
**Date:** 2026-03-08

---

## Research Question

Has Nepal's shift from electricity scarcity (pre-2018) to structural surplus (post-2018) altered the direction and magnitude of the energy–growth nexus? Specifically: does electricity consumption Granger-cause GDP growth in the surplus era, or has the binding constraint shifted from supply to transmission and demand-side absorption?

---

## Abstract

The energy–growth nexus literature — from Kraft & Kraft (1978) to the Apergis & Payne (2009) panel extensions — was built almost entirely on scarcity contexts. Nepal presents a rare natural experiment in energy regime change: a well-documented transition from chronic shortage (load shedding up to 16 hrs/day, 2008–2016) to structural electricity surplus from ~2025, driven by near-doubling of installed hydro capacity. No published peer-reviewed study examines whether the Granger-causal direction between energy and GDP reverses or weakens once supply is no longer the binding constraint.

This project applies ARDL bounds testing and VECM to annual Nepalese data from 2000 to 2024, testing for a structural break around 2018 using the Zivot–Andrews procedure. The primary hypothesis is that electricity consumption Granger-caused GDP growth in the scarcity period but that this relationship weakens or reverses post-surplus — consistent with demand-side absorption capacity and transmission infrastructure becoming the new bottleneck. A secondary contribution is documenting Nepal's energy intensity trajectory relative to South Asian peers as the surplus era begins.

---

## Motivation & Background

Nepal achieved near-universal electricity access (~94% household access by 2023) through aggressive hydro development, but did so while enduring severe supply shortages — up to 16 hours of daily load shedding at the nadir (2012–2013). Ghimire et al. (2024) document that the government's 2018 capacity target was missed by ~50% (2,684 MW achieved vs. 5,000 MW targeted) yet per-capita consumption remained just 351 kWh/year — less than half the target — suggesting demand constraints had already emerged alongside supply. The ADB (2020) projects GDP to be 87% higher by 2030 relative to baseline if Nepal develops even one-fifth of its viable hydro potential, but this assumes the energy–growth link remains positive and strong.

The key question is whether that assumption holds in the surplus era. If demand-side absorption (industry, appliances, transmission) is now the constraint, energy policy should shift from generation investment to grid modernization and industrialization — a fundamentally different policy implication.

Key citations: Kraft & Kraft (1978); Apergis & Payne (2009); Ghimire et al. (2024); ADB (2020); Poudel & Kumar (2025).

---

## Methodology

### Data

| Variable | Source | Notes |
|----------|--------|-------|
| Electricity consumption (GWh/year) | NEA Annual Reports + WDI (`EG.USE.ELEC.KH.PC`) | 2000–2024 |
| Real GDP (constant 2017 int'l $, PPP) | WDI (`NY.GDP.MKTP.PP.KD`) | PPP-adjusted — mandatory |
| Energy intensity | WDI `EG.EGY.PRIM.PP.KD` | Cross-check calculation |
| Gross fixed capital formation | WDI (`NE.GFI.TOTL.KD`) | Control |
| Trade openness (% GDP) | WDI (`NE.TRD.GNFS.ZS`) | Control |

### Estimation Strategy

1. **Unit root pre-tests:** ADF (`ur.df()`) + KPSS (`ur.kpss()`) — report both; Zivot–Andrews (`ur.za()`) for structural break date
2. **Cointegration:** ARDL bounds test (Pesaran et al. 2001) via `ARDL` package; lag selection by AIC
3. **Short-run dynamics:** VECM via `vars` package; Granger causality within VAR
4. **Structural break:** Chow test at 2018; compare pre/post coefficients
5. **Robustness:** Alternative break dates (2016, 2017, 2019); alternative lag structures; HAC standard errors

### Timeline

| Month | Milestones |
|-------|-----------|
| 1 | WDI data pull (`WDI` package); manual NEA data collection; unit root tests; descriptive statistics |
| 2 | ARDL bounds test; VECM estimation; Granger causality; structural break test |
| 3 | Robustness checks; energy intensity comparison (South Asian peers); write-up |

---

## Expected Findings & Contribution

**Expected finding:** Positive energy→GDP Granger causality pre-2018 (scarcity era); weakened or reversed direction post-2018 (demand-side binding). If confirmed, this is the first econometric documentation of a nexus regime shift driven by supply surplus rather than structural transformation.

**Contribution:** Fills a genuine gap — no published study uses post-surplus-era Nepal data. Directly informs Nepal's export-vs-industrialize debate: if the growth nexus has weakened, channeling surplus to industry (not export) should be the priority. Connects classic nexus literature to the specific context of hydropower-dependent LDCs exiting energy poverty.

**Target journals:** *Energy Policy*; *International Journal of Energy Economics and Policy*; *Energy Economics*

---

## Data Availability Check

- [x] WDI: available via `WDI` R package — zero access barriers
- [x] NEA Annual Reports: neanepal.com.np — publicly available (manual download, ~3 hours)
- [x] No proprietary data required
- [x] R packages: `urca`, `vars`, `ARDL`, `WDI` — all on CRAN

---

## Potential Limitations

- Post-surplus window (2018–2024) is only 7 annual observations — structural break evidence will be suggestive, not definitive. Use quarterly NEA data if available to expand T.
- Nepal's TPES is dominated by biomass for cooking; electricity consumption alone may understate total energy use. Run parallel TPES-based analysis and discuss the two-track energy system explicitly.
- VAR/VECM results are sensitive to lag selection — report three information criteria (AIC, BIC, HQ) and check stability (companion matrix eigenvalues < 1).

---

## References

- Kraft, J. & Kraft, A. (1978). On the relationship between energy and GNP. *Journal of Energy and Development*, 3(2), 401–403.
- Apergis, N. & Payne, J.E. (2009). Energy consumption and economic growth in Central America. *Energy Economics*, 31(6), 906–912.
- Ghimire, S., Tiwari, S. et al. (2024). Evolution and future prospects of hydropower sector in Nepal. *Heliyon*. DOI: 10.1016/j.heliyon.2024.e31139
- ADB (2020). Hydropower Development and Economic Growth in Nepal. Asian Development Bank.
- Poudel, Y.K. & Kumar, R. (2025). Review of Energy Policies and Strategies in Nepal. *Int'l J. Sustainable and Green Energy*, 14(2), 66–79.
