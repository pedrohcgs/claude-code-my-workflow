# Do Off-Grid Renewable Subsidies Increase Energy Access? A District-Level Evaluation of Nepal's AEPC Program

**Status:** DRAFT
**Quality score:** —
**Date:** 2026-03-08

---

## Research Question

Did Nepal's Alternative Energy Promotion Centre (AEPC) off-grid subsidy programs — solar home systems and micro-hydro units — significantly increase household energy access in treated districts relative to untreated districts? Does the effect differ by district-level governance quality?

---

## Abstract

Nepal's AEPC has disbursed subsidies for off-grid renewable energy (primarily solar home systems and micro-hydro) to rural districts since the early 2000s, with rollout timing varying substantially across Nepal's 77 districts. Despite NPR billions in cumulative disbursements and international attention as a model program, no peer-reviewed econometric evaluation exists. Existing assessments are internal government reports without credible control groups.

This project exploits the staggered, geographically varied rollout of AEPC subsidies to estimate causal effects on household electrification rates using a staggered difference-in-differences design (Callaway & Sant'Anna 2021). The secondary question tests whether effects are moderated by district governance quality — a key finding from Shittu et al. (2024) at the cross-country level that has not been tested within a single-country subnational context. Data combine Nepal Census electrification data (2001, 2011, 2021) with AEPC program rollout records and district governance ratings.

---

## Motivation & Background

Nepal's AEPC is frequently cited in international energy access literature as a successful subsidy model for LDCs, yet its causal impact on electrification has never been rigorously estimated. Shittu et al. (2024) show at the cross-country level that institutional quality moderates how effectively energy subsidies translate into energy access. Nepal's 77 districts vary substantially in governance quality (as rated by the Ministry of Federal Affairs and General Administration Local Governance Rating), providing subnational variation to test this mechanism within a single country — controlling for all national-level confounders.

The identification strategy exploits the variation in *when* districts received AEPC programs, not just *whether* they did — essential for valid DID estimation when rollout is staggered over time.

Key citations: Shittu et al. (2024); Callaway & Sant'Anna (2021); Dinkelman (2011); Poudel & Kumar (2025).

---

## Methodology

### Data

| Variable | Source | Notes |
|----------|--------|-------|
| AEPC program rollout by district and year | AEPC Annual Reports; MoEWRI | Requires manual digitization — allow 2–3 weeks |
| Household electrification rate (% HH) | Nepal Census (2001, 2011, 2021); CBS | 3 time points — interpolation needed |
| Off-grid capacity installed (kW, by district) | AEPC Annual Reports | Alternative outcome variable |
| District governance quality | Local Governance Rating (MoFAGA) | Heterogeneity variable; confirm data availability |
| Nighttime light luminosity (annual) | NOAA DMSP (1992–2013); VIIRS (2012–2024) | Annual proxy for electrification when Census gaps |
| District-level economic controls | CBS District Profile; National Planning Commission | Population, poverty rate |

### Estimation Strategy

**Estimator:** Staggered DID — Callaway & Sant'Anna (2021) `did` package; avoids TWFE bias from heterogeneous treatment timing

**Treatment:** Year of first AEPC program introduction by district (binary; varies 2003–2018 across districts)

**Outcome:** District household electrification rate (primary); nighttime light luminosity (annual proxy, secondary)

**Heterogeneity:** Interaction between ATT and district governance quality (above/below median index)

**Pre-tests:**
1. Event study plot — visual parallel trends assessment (pre-treatment periods)
2. Bacon decomposition — identify weight of "problematic" 2×2 DID pairs
3. Sun & Abraham (2021) interaction-weighted estimator — robustness check

### Timeline

| Month | Milestones |
|-------|-----------|
| 1 | AEPC rollout data collection and digitization; Census electrification extraction; nighttime light download (NOAA); treatment timing dataset construction |
| 2 | Staggered DID estimation; event study plots; parallel trends assessment; Bacon decomposition |
| 3 | Governance heterogeneity analysis; nighttime light robustness; SUTVA sensitivity; write-up |

---

## Expected Findings & Contribution

**Expected finding:** Positive and significant ATT of AEPC programs on electrification, consistent with program intent. Effect likely larger in better-governed districts (consistent with Shittu et al. 2024 cross-country pattern), suggesting that governance quality should factor into AEPC targeting decisions.

**Contribution:** First peer-reviewed causal evaluation of Nepal's AEPC using quasi-experimental methods. Tests the institutional quality moderation hypothesis in a within-country subnational setting — methodologically stronger than cross-country panels for isolating this channel. Direct policy implications for AEPC scale-up and geographic targeting.

**Target journals:** *Energy Policy*; *World Development*; *Energy for Sustainable Development*

---

## Data Availability Check

- [ ] AEPC rollout data: publicly available in Annual Reports, but requires digitization — CONFIRM with AEPC before starting
- [x] Nepal Census: CBS website, freely available
- [x] Nighttime lights: NOAA open data, download via R `nightlightstats` or manual
- [ ] Local Governance Rating: MoFAGA — confirm annual coverage and district-level disaggregation
- [x] R packages: `did`, `fixest`, `ggplot2` — all on CRAN

**CRITICAL:** Contact AEPC and MoFAGA before committing to this proposal. Data digitization risk could consume Month 1 entirely.

---

## Potential Limitations

- Nepal Census has only 3 electrification observations (2001, 2011, 2021) — limited temporal variation. Nighttime light luminosity as annual proxy is a crucial bridge; validate correlation with Census observations.
- SUTVA: neighboring districts may benefit from grid extension spillovers following off-grid penetration. Sensitivity: exclude district pairs sharing borders; add distance-weighted spillover control.
- AEPC program rollout may be endogenous to pre-existing poverty levels (programs targeted to poorest districts). Address with: (1) controlling for baseline poverty; (2) testing for pre-trends; (3) restricting sample to similar poverty-level districts.

---

## References

- Callaway, B. & Sant'Anna, P.H.C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200–230.
- Shittu, I., Saqib, A., Abdul Latiff, A.R. & Baharudin, S.A. (2024). Energy subsidies and energy access in developing countries: Does institutional quality matter? *SAGE Open*. DOI: 10.1177/21582440241271118
- Dinkelman, T. (2011). The effects of rural electrification on employment. *American Economic Review*, 101(7), 3078–3108.
- Sun, L. & Abraham, S. (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. *Journal of Econometrics*, 225(2), 175–199.
- Poudel, Y.K. & Kumar, R. (2025). Review of Energy Policies and Strategies in Nepal. *Int'l J. Sustainable and Green Energy*, 14(2).
