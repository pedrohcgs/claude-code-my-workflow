# Nepal's Energy Future Under SSP2 and SSP3: A Demand Downscaling Analysis to 2040

**Status:** DRAFT
**Quality score:** —
**Date:** 2026-03-08

---

## Research Question

How do Nepal's energy demand projections through 2040 change under SSP2 (middle-of-the-road) versus SSP3 (regional rivalry) assumptions, once scenario parameters are adjusted for Nepal's structural features: remittance-driven consumption, India energy price dependence, and a predominantly rural biomass-cooking population undergoing rapid appliance adoption?

---

## Abstract

The Shared Socioeconomic Pathways (SSPs) framework — the canonical tool for climate-energy scenario work since IPCC AR6 — was calibrated for large world regions, not small landlocked developing economies. Nepal's energy demand is structurally unusual: remittances (~25% of GDP) fund rapid appliance adoption even as industrial energy demand remains low; cooking energy remains dominated by biomass (>60% of rural TPES); and electricity demand is partially decoupled from domestic GDP by cross-border trade and India price linkages.

This project downscales SSP2 and SSP3 energy demand projections to Nepal through 2040 by (1) estimating Nepal-specific income, urbanization, and remittance elasticities of electricity and biomass demand from a South Asian panel dataset; (2) constructing a transparent two-sector demand model (electricity + biomass); and (3) comparing projections against Ghimire et al.'s (2024) bottom-up target (41,265 GWh electricity by 2030). The deliverable is a replicable R model for updating Nepal's energy demand projections as SSP parameters are revised (updated IAM quantifications expected 2026).

---

## Motivation & Background

Nepal's NEA and government targets are largely bottom-up engineering projections (Ghimire et al. 2024). These are not embedded in a scenario framework that links demand to alternative global development pathways. Under SSP3 (regional rivalry — slower global growth, weaker trade), Nepal's remittance income would fall significantly, dampening appliance-driven electricity demand. Under SSP2 (middle-of-the-road), remittances remain stable but urbanization accelerates, shifting energy use from biomass toward electricity. Neither scenario has been quantified for Nepal.

The novelty lies specifically in the remittance elasticity of electricity demand — a channel underdocumented in energy economics despite affecting dozens of remittance-dependent LDCs (Haiti, Tajikistan, Honduras, Kyrgyzstan). Nepal is an ideal case because remittances are large, well-measured (WDI), and plausibly exogenous to domestic electricity policy.

Key citations: Riahi et al. (2017); Ghimire et al. (2024); WECS Energy Synopsis Report (2023); IIASA SSP Database.

---

## Methodology

### Data

| Variable | Source | Notes |
|----------|--------|-------|
| SSP2/SSP3 GDP, population, urbanization | IIASA SSP Database (free) | Use 2025 updated projections |
| Nepal electricity consumption (annual) | WDI (`EG.USE.ELEC.KH.PC`) + NEA Annual Reports | 2000–2024 |
| Remittances (% GDP) | WDI (`BX.TRF.PWKR.DT.GD.ZS`) | Nepal + comparators |
| TPES by fuel (biomass, electricity, petroleum) | WECS Energy Synopsis Report (2023; free, GON) | Nepal-specific; IEA if available |
| Appliance ownership | Nepal Living Standards Survey (CBS) | 2003, 2011, 2023 waves |
| South Asian panel (for elasticity estimation) | WDI: Nepal, Bangladesh, Sri Lanka, Bhutan, Pakistan | 2000–2023 |

### Estimation Strategy

**Step 1: Estimate elasticities** using South Asian panel (5 countries × 23 years = ~115 observations):
- Income elasticity of electricity demand (ε_Y): `plm` FE panel regression
- Urbanization elasticity of biomass share: `plm` FE panel regression
- Remittance elasticity of electricity demand (novel): add remittances/GDP as regressor; test significance

**Step 2: Build Nepal two-sector demand model:**
- Sector A (electricity): $E_t = E_0 \cdot \left(\frac{Y_t}{Y_0}\right)^{\varepsilon_Y} \cdot \left(\frac{R_t}{R_0}\right)^{\varepsilon_R}$
- Sector B (biomass): $B_t = B_0 \cdot \left(\frac{Urban_t}{Urban_0}\right)^{\varepsilon_U}$ (biomass falls as urbanization rises)

**Step 3: Apply SSP2 and SSP3 paths** from IIASA to Y_t, R_t, Urban_t → project E_t and B_t to 2040

**Step 4: Compare** SSP2 vs. SSP3 electricity projections against NEA targets and Ghimire et al. (2024)

**R packages:** `WDI`, `plm`, `fixest`, `ggplot2`, `dplyr`

### Timeline

| Month | Milestones |
|-------|-----------|
| 1 | WDI data pull (South Asian panel); IIASA SSP download; WECS biomass data; elasticity estimation |
| 2 | Two-sector demand model construction; SSP2 vs. SSP3 projections to 2040 |
| 3 | Comparison with NEA/Ghimire targets; sensitivity (elasticity uncertainty bands); write-up |

---

## Expected Findings & Contribution

**Expected finding:** SSP3 (regional rivalry) substantially reduces Nepal's projected electricity demand relative to SSP2 via the remittance channel — a divergence not captured by standard bottom-up engineering projections. Biomass demand falls faster under SSP2 (faster urbanization) than under SSP3 (stalled rural-urban transition), with significant implications for health and climate co-benefits.

**Contribution:** First SSP-downscaled energy demand model for Nepal with an explicit remittance channel. Generates a planning tool for NEA and Ministry of Energy updatable as SSP parameters evolve. Methodological contribution: remittance elasticity estimation adds to the literature on demand-side drivers in remittance-dependent LDCs — generalizable to ~30 comparable countries.

**Target journals:** *Energy for Sustainable Development*; *Energy Policy*; *Applied Energy*

---

## Data Availability Check

- [x] IIASA SSP Database: free download (ssp-db.iiasa.ac.at)
- [x] WDI South Asian panel: `WDI` R package
- [x] WECS Energy Synopsis Report 2023: free, GON website
- [ ] Nepal Living Standards Survey: CBS — confirm digital access to appliance ownership microdata
- [x] R packages: `WDI`, `plm`, `fixest`, `ggplot2` — all on CRAN

---

## Potential Limitations

- South Asian panel has ~115 observations for elasticity estimation — sufficient but not large. Interpret elasticities with appropriate uncertainty bands; propagate uncertainty into demand projections.
- Biomass IEA free tier may not disaggregate Nepal fuel mix sufficiently. WECS Energy Synopsis is the primary fallback — verify coverage before starting.
- SSP IAM quantifications are being updated in 2026. Use 2025 GDP/population revision (already released); note that IAM energy intensities may change with 2026 update.
- **Best suited for:** student with prior exposure to panel econometrics and comfort with scenario modeling frameworks.

---

## References

- Riahi, K. et al. (2017). The Shared Socioeconomic Pathways and their energy, land use, and GHG emissions implications. *Global Environmental Change*. DOI: 10.1016/j.gloenvcha.2016.05.009
- Ghimire, S., Tiwari, S. et al. (2024). Evolution and future prospects of hydropower sector in Nepal. *Heliyon*. DOI: 10.1016/j.heliyon.2024.e31139
- WECS (2023). Energy Synopsis Report, Fiscal Year 2078/79. Water and Energy Commission Secretariat, Government of Nepal.
- IIASA (2024). SSP Scenario Database v2.0. iiasa.ac.at/models-tools-data/ssp
