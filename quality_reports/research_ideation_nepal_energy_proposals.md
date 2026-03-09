# Research Ideation: Nepal & Global Energy Economics — Student Proposals

**Date:** 2026-03-08
**Input:** Based on lit review in `quality_reports/lit_review_nepal_global_energy_economics.md` — generate 3–5 feasible summer (3-month) research proposals with title, RQ, abstract, methodology, data sources, and contribution.

---

## Overview

Nepal's energy sector has undergone a structural regime change: a decade of severe load shedding (up to 16 hrs/day through 2016) has given way to a structural electricity surplus since ~2025, with hydropower dominating generation (~90% of electricity) and export revenues growing rapidly. This transition reopens foundational questions — does more electricity actually accelerate growth now that supply is no longer the binding constraint? — while also creating entirely new policy questions: what is the highest-value use of surplus power? Is Nepal's renewable energy policy effectiveness comparable to its peers? And how does the global energy transition, now racing well ahead of 2020 projections (solar at $0.043/kWh, $2.3T invested in 2025), intersect with the specific constraints of a landlocked, remittance-driven Himalayan economy?

Five proposals below address distinct gaps in the 2023–2026 literature, ordered from highest to lowest feasibility for a 3-month student project. All use publicly accessible data. All connect to debates in *Energy Economics*, *Energy Policy*, or *Nature Energy* — journals where even replication-plus studies can find a home.

---

## Proposal 1 — The Energy–Growth Nexus in the Surplus Era: Evidence from Nepal, 2000–2024

**Feasibility:** HIGH | **Contribution:** HIGH | **Priority:** 1

### Research Question

Has Nepal's shift from electricity scarcity (pre-2018) to structural surplus (post-2018) altered the direction and magnitude of the energy–growth nexus? Specifically: does electricity consumption Granger-cause GDP growth in the surplus era, or has the binding constraint shifted from supply to transmission and demand-side absorption?

### Abstract

The energy–growth nexus literature — from Kraft & Kraft (1978) to the Apergis & Payne (2009) panel extensions — was built almost entirely on contexts of energy scarcity. Nepal presents a natural experiment in regime change: a well-documented transition from chronic shortage (load shedding up to 16 hrs/day, 2008–2016) to structural surplus (2025 onward), driven by a near-doubling of installed hydro capacity. No published study examines whether the Granger-causal direction reverses or weakens once supply is no longer binding.

This project applies time-series cointegration methods (ARDL bounds testing and VECM) to Nepal's annual data from 2000 to 2024, testing for a structural break around 2018 using the Zivot–Andrews procedure. The primary hypothesis is that electricity consumption Granger-causes GDP in the scarcity period but that this relationship weakens or reverses post-surplus — consistent with demand-side and transmission constraints becoming the new bottleneck. A secondary contribution is documenting Nepal's post-surplus energy intensity trajectory to benchmark against regional peers.

### Methodology

**Estimator:** ARDL bounds test (Pesaran et al. 2001) for long-run cointegration; VECM for short-run dynamics; Granger causality tests within VAR framework
**Structural break:** Zivot–Andrews unit root test; Chow test at 2018 breakpoint
**Pre-tests (mandatory):** ADF + KPSS unit root tests (report both); Pesaran CD test (not applicable for single-country time series — use HAC SE instead)

**Variable construction:**
| Variable | Source | Notes |
|----------|--------|-------|
| Electricity consumption (GWh) | NEA Annual Reports + WDI (`EG.USE.ELEC.KH.PC`) | Annual, 2000–2024 |
| Real GDP (constant 2017 int'l $, PPP) | WDI (`NY.GDP.MKTP.PP.KD`) | Use PPP-adjusted |
| Energy intensity (koe/$1000 PPP GDP) | Calculated from TPES/GDP | Cross-check with WDI `EG.EGY.PRIM.PP.KD` |
| Capital formation (gross fixed) | WDI (`NE.GFI.TOTL.KD`) | Control variable |
| Trade openness (% GDP) | WDI (`NE.TRD.GNFS.ZS`) | Control variable |

**R packages:** `urca` (ADF/KPSS/Zivot-Andrews), `vars` (VAR/Granger), `ARDL` (bounds test), `dLagM` (ARDL alternative), `WDI` (data pull)

**Timeline:**
| Month | Tasks |
|-------|-------|
| 1 | Data collection (WDI R package + NEA reports), cleaning, descriptive statistics, unit root pre-tests |
| 2 | ARDL estimation, VECM, Granger causality; structural break testing |
| 3 | Robustness checks (alternative break dates, different lag structures), write-up |

### Data Availability Check
- [ ] WDI: fully available via `WDI` R package — no access barriers
- [ ] NEA Annual Reports: publicly available at neanepal.com.np (download manually, ~3 hours)
- [ ] No proprietary data required
- [ ] R packages: `urca`, `vars`, `ARDL`, `WDI` — all on CRAN

### Expected Contribution

Fills a genuine gap: first published study to test the energy–growth nexus in Nepal *after* the surplus transition. If the causal direction weakens post-surplus, this provides evidence that transmission infrastructure and demand-side policy (not generation capacity) are the binding constraints — directly informing Nepal's $3B export-or-industrialize decision. Publishable in *Energy Policy* or *International Journal of Energy Economics and Policy*.

### Potential Pitfalls

1. **Short post-surplus window (2018–2024 = 7 observations):** Mitigate by using quarterly data from NEA if available; or interpret the structural break as directional evidence rather than a definitive causality test.
2. **Nepal's TPES dominated by biomass:** GDP–electricity nexus may not capture total energy–growth relationship. Mitigate by running parallel analysis with TPES and explicitly discussing the biomass cooking energy split.
3. **Lag selection sensitivity:** VAR/VECM results sensitive to lag choice. Report AIC, BIC, and HQ criteria; check companion matrix eigenvalues for stability.

**Related Work:** Kraft & Kraft (1978); Apergis & Payne (2009); Ghimire et al. (2024); ADB (2020)

---

## Proposal 2 — Is Nepal's Hydropower Actually Cheap? Effective LCOE Accounting for Seasonality, Transmission Loss, and Export Pricing

**Feasibility:** HIGH | **Contribution:** HIGH | **Priority:** 2

### Research Question

What is the effective levelized cost of electricity (LCOE) from Nepal's run-of-river hydropower when accounting for seasonal output mismatch, domestic transmission losses (~25%), and the constrained pricing regime under the Nepal–India Power Trade Agreement (PTA)? Is it competitive against solar PV + storage alternatives at Nepal's latitude, or does the seasonal dry-season deficit substantially erode hydro's apparent cost advantage?

### Abstract

Global benchmarks from IRENA (2024) report hydropower LCOE at $0.057/kWh — higher than both onshore wind ($0.034) and solar PV ($0.043). Yet Nepal's prodigious run-of-river hydro capacity is typically presented as its primary comparative advantage. This apparent contradiction is never resolved in the published literature because global LCOE figures do not account for Nepal-specific factors: (1) severe seasonal mismatch (monsoon surplus, dry-season shortage), (2) average transmission and distribution losses of ~20–25%, (3) export revenue capped by PTA pricing with India (often below domestic cost-recovery tariffs), and (4) the absence of storage to bridge the seasonal gap.

This project constructs an effective LCOE for Nepal's hydropower fleet using publicly available NEA generation, loss, and tariff data, then compares it against the effective LCOE of a hypothetical solar PV + lithium-ion storage system designed to provide comparable seasonal reliability. Sensitivity analysis varies the PTA export price, storage duration, and capacity factor assumptions. The goal is a transparent, replicable cost comparison that Nepal's energy planners can update annually.

### Methodology

**Approach:** Techno-economic LCOE modeling (bottom-up), not econometric estimation
**Primary output:** Effective LCOE ($/kWh) for hydro vs. solar+storage under multiple scenarios

**LCOE formula (standard):**
$$\text{LCOE} = \frac{\sum_{t=0}^{T} \frac{C_t + O_t}{(1+r)^t}}{\sum_{t=0}^{T} \frac{E_t \cdot (1 - L_t)}{(1+r)^t}}$$

Where: $C_t$ = capital expenditure, $O_t$ = O&M, $E_t$ = gross generation, $L_t$ = transmission loss rate, $r$ = discount rate

**Seasonal adjustment:** Compute monthly capacity factors from NEA hydrology data; weight LCOE by month to derive annual effective LCOE
**PTA pricing sensitivity:** Vary export price from NPR 4.0/kWh (current PTA floor) to NPR 10.0/kWh (estimated long-run avoided cost)
**Solar benchmark:** Use IRENA 2024 installed cost for South Asia + Nepal irradiance data (NASA POWER dataset, freely available)

**Data sources:**
| Variable | Source |
|----------|--------|
| Generation by month, by plant | NEA Annual Reports (2018–2024) |
| T&D losses | NEA Annual Reports |
| Installed capacity, capital costs | DOED project register; World Bank project documents |
| PTA pricing terms | Government of Nepal MoEWRI documents |
| Solar irradiance (monthly, by region) | NASA POWER API (free, lat/lon based) |
| Battery storage costs | IRENA 2024 ($192/kWh); BloombergNEF 2025 |
| Discount rate | World Bank Nepal country cost-of-capital estimates |

**R implementation:** Compute LCOE function; `ggplot2` for cost-scenario waterfall charts; sensitivity tornado plot

**Timeline:**
| Month | Tasks |
|-------|-------|
| 1 | Data collection (NEA reports, DOED register, NASA POWER API), seasonal capacity factor construction |
| 2 | LCOE computation for hydro; solar+storage benchmark; PTA sensitivity analysis |
| 3 | Scenario comparison, tornado plots, write-up |

### Expected Contribution

First published transparent LCOE comparison for Nepal that incorporates seasonality, T&D losses, and PTA pricing constraints simultaneously. Directly informs the policy debate: should Nepal's surplus go to regional export (constrained by PTA), domestic industry, or should storage investment be prioritized to smooth seasonal mismatch? Publishable in *Energy Policy* or *Renewable Energy*.

### Potential Pitfalls

1. **NEA project-level capital cost data is sparse:** Many projects' actual construction costs are not publicly disclosed. Mitigate by using World Bank project document estimates and conducting wide sensitivity analysis on capital cost (±30%).
2. **PTA pricing terms are politically sensitive and may change:** Flag as a scenario variable, not a fixed parameter.
3. **Discount rate choice dominates LCOE in capital-intensive technologies:** Report results for r = 6%, 8%, 10%, 12% as separate scenarios.

**Related Work:** IRENA (2024, 2025); Anonymous (2023, 2024) on Nepal surplus hydro; Poudel & Kumar (2025)

---

## Proposal 3 — Do Rural Electrification Subsidies Increase Energy Access in Nepal? A District-Level Panel Study

**Feasibility:** MEDIUM-HIGH | **Contribution:** HIGH | **Priority:** 3

### Research Question

Did Nepal's Alternative Energy Promotion Centre (AEPC) off-grid subsidy programs — solar home systems (SHS) and micro-hydro units — significantly increase household energy access in treated districts relative to untreated districts, and does the effect differ by pre-program institutional quality (measured by district governance indices)?

### Abstract

Nepal's AEPC has disbursed subsidies for off-grid renewable energy (primarily solar home systems and micro-hydro) to rural districts since the early 2000s, with rollout timing varying substantially across Nepal's 77 districts. Despite NPR billions in cumulative disbursements, no rigorous econometric evaluation of the AEPC program has been published in a peer-reviewed journal. Existing evaluations are internal government assessments without control groups.

This project exploits the staggered rollout of AEPC subsidies across districts to estimate the average treatment effect on the treated (ATT) using a staggered difference-in-differences design (Callaway & Sant'Anna 2021), with household electrification rates as the primary outcome. Heterogeneity analysis tests whether the effect is stronger in districts with higher pre-program governance quality — building on Shittu et al.'s (2024) finding that institutional quality moderates the subsidy → energy access link in developing-country panels.

### Methodology

**Estimator:** Staggered DID (Callaway & Sant'Anna 2021) to handle heterogeneous treatment timing; Sun & Abraham (2021) interaction-weighted estimator as robustness check
**Treatment:** Year of first AEPC subsidy program introduction by district
**Outcome:** District-level household electrification rate (% households with electricity access)
**Heterogeneity:** Interaction with district governance quality index (Local Governance Rating, if available; otherwise CBC district-level index)

**Pre-test:** Parallel trends visualization (event study plot, pre-treatment periods); Bacon decomposition to assess weight of "bad" 2x2 comparisons

**Data sources:**
| Variable | Source | Notes |
|----------|--------|-------|
| AEPC program rollout by district and year | AEPC Annual Reports; MoEWRI | Requires manual extraction — ~2 weeks |
| Household electrification by district | Nepal Census (2001, 2011, 2021); CBS household surveys | 3 data points; interpolation needed |
| District governance quality | Local Governance Rating (MoFAGA); World Bank subnational governance | Verify availability |
| District GDP proxy | CBS district-level data; NPC Economic Survey | Limited; use nighttime lights as proxy if unavailable |
| Off-grid capacity installed (kW) | AEPC Annual Reports | Alternative outcome variable |

**R packages:** `did` (Callaway & Sant'Anna), `fixest` (TWFE baseline), `ggplot2` for event study plots

**Timeline:**
| Month | Tasks |
|-------|-------|
| 1 | AEPC data collection and digitization; Census electrification data; treatment timing construction |
| 2 | Staggered DID estimation; event study plots; parallel trends assessment |
| 3 | Heterogeneity analysis (governance interaction); robustness checks; write-up |

### Expected Contribution

First peer-reviewed causal evaluation of Nepal's AEPC program using quasi-experimental methods. Connects to the international literature on subsidy effectiveness (Shittu et al. 2024; Dinkelman 2011 on South Africa electrification). Policy-relevant: results directly inform whether AEPC scale-up is justified and whether targeting should be conditioned on governance quality. Strong fit for *Energy Policy* or *World Development*.

### Potential Pitfalls

1. **District-level data granularity:** Nepal's Census only covers electrification at 3 points (2001, 2011, 2021) — limited time variation. Mitigate by using AEPC-compiled intermediate household survey data or nighttime light luminosity (NOAA DMSP/VIIRS) as annual proxy.
2. **AEPC data availability:** Program rollout records may not be fully digitized. Budget 3–4 weeks for data collection and verification with AEPC.
3. **SUTVA violation:** Neighboring districts may benefit from spillovers (grid extension following off-grid penetration). Mitigate by including geographic spillover controls or excluding border-district pairs.

**Related Work:** Shittu et al. (2024); Dinkelman (2011); Allcott et al. (2016); Callaway & Sant'Anna (2021)

---

## Proposal 4 — Nepal's Energy Demand Under SSP2 and SSP3: A Downscaled Scenario Analysis

**Feasibility:** MEDIUM | **Contribution:** MEDIUM-HIGH | **Priority:** 4

### Research Question

How do Nepal's energy demand projections through 2040 change under SSP2 (middle-of-the-road) versus SSP3 (regional rivalry) assumptions, once scenario parameters are adjusted for Nepal's specific structural features: remittance-driven consumption, India energy price dependence, and a predominantly rural biomass-cooking population undergoing rapid appliance adoption?

### Abstract

The Shared Socioeconomic Pathways (SSPs) framework — canonical for climate-energy scenario work since IPCC AR6 — was calibrated for large world regions, not small landlocked developing economies. Nepal's energy demand drivers are structurally unusual: remittances (~25% of GDP) fund rapid appliance adoption even as industrial energy demand remains low; cooking energy remains dominated by biomass (>60% of TPES in rural areas); and electricity demand is partially decoupled from domestic GDP by cross-border trade with India.

This project downscales SSP2 and SSP3 energy demand projections to Nepal by (1) re-parameterizing income elasticities using Nepal-specific WDI data; (2) building a two-sector demand model separating electricity demand (GDP-linked + remittance-linked) from biomass cooking demand (urbanization-linked); and (3) stress-testing the 2040 demand projections against Ghimire et al.'s (2024) bottom-up forecast (41,265 GWh by 2030). The deliverable is a transparent, replicable R model for updating Nepal energy demand projections as SSP parameters are revised (SSP update expected 2026).

### Methodology

**Approach:** Scenario downscaling + energy demand modeling; not primarily econometric but uses estimated elasticities
**Framework:** Two-sector model: (1) electricity demand function of GDP + remittances + appliance stock; (2) biomass demand function of rural population + cooking fuel switching probability

**Step 1: Estimate Nepal-specific elasticities** from WDI panel (Nepal + South Asian neighbors, 2000–2023):
- Income elasticity of electricity demand (ε_Y): OLS with FE
- Urbanization elasticity of biomass share: OLS with FE
- Remittance elasticity (novel): regress per-capita electricity on remittance/GDP ratio

**Step 2: Downscale SSP2 and SSP3 GDP/population/urbanization paths** from IIASA SSP database to Nepal

**Step 3: Project electricity and biomass demand** through 2040 under each scenario; compare against NEA targets and Ghimire et al. (2024) forecasts

**Data sources:**
| Variable | Source |
|----------|--------|
| SSP2/SSP3 GDP, population, urbanization | IIASA SSP Database (free download) |
| Nepal electricity consumption (annual) | WDI + NEA Annual Reports |
| Remittances (% GDP) | WDI (`BX.TRF.PWKR.DT.GD.ZS`) |
| TPES by fuel (biomass, electricity, petroleum) | IEA (basic free tier) or WECS Energy Synopsis Report (free, Nepal government) |
| Appliance ownership (household survey) | Nepal Living Standards Survey (CBS) |

**R packages:** `WDI`, `plm`, `fixest`, `ggplot2`

**Timeline:**
| Month | Tasks |
|-------|-------|
| 1 | Elasticity estimation (WDI panel); SSP database download and Nepal subsetting |
| 2 | Two-sector demand model construction; 2040 projections under SSP2 vs. SSP3 |
| 3 | Comparison with NEA/Ghimire targets; sensitivity analysis; write-up |

### Expected Contribution

Fills the gap noted in the literature review: no published country-level SSP downscaling exists for Nepal. Generates a planning tool directly usable by Nepal's Ministry of Energy and NEA. Methodologically, the remittance elasticity estimation is novel — remittance-driven appliance adoption is underdocumented in the energy demand literature despite affecting dozens of remittance-dependent LDCs. Good fit for *Energy for Sustainable Development* or *Energy Policy*.

### Potential Pitfalls

1. **Short time series for elasticity estimation:** Nepal WDI electricity data from ~1990; only ~30 observations. Include South Asian neighbors (Bangladesh, Bhutan, Sri Lanka, Pakistan) in panel to gain power; interpret Nepal-specific coefficients as prior-informed.
2. **Biomass data quality:** IEA free tier may not disaggregate by fuel. Use WECS Energy Synopsis Report (Nepal government; confirmed available) as primary source.
3. **SSP update mid-project:** Updated IAM quantifications expected 2026. Use 2025 GDP/population revision (already released) and note IAM update as a limitation.

**Related Work:** Riahi et al. (2017); Ghimire et al. (2024); WECS Energy Synopsis Report (2023)

---

## Proposal 5 — Green Hydrogen from Nepalese Hydropower: Feasibility Under Realistic Power Trade Agreement Pricing

**Feasibility:** MEDIUM-HIGH | **Contribution:** HIGH | **Priority:** 3 (tied)

### Research Question

Is green hydrogen production from Nepal's projected surplus hydropower economically feasible when the effective electricity price reflects the Nepal–India Power Trade Agreement (PTA) pricing regime, rather than the full domestic NEA tariff? At what PTA price floor does green hydrogen become competitive with grey hydrogen import costs in India's industrial market?

### Abstract

Two recent studies (Anonymous 2023, 2024) project substantial surplus hydropower in Nepal from 2025 onward, peaking at ~25 TWh in 2028, and evaluate green hydrogen production via alkaline electrolysis. Both studies find LCOH highly sensitive to electricity price — but neither incorporates the actual pricing regime under Nepal's bilateral Power Trade Agreement with India, which constrains the effective export price and thus the opportunity cost of electricity devoted to hydrogen production. This is a critical omission: if PTA pricing caps the electricity opportunity cost below the NEA tariff, LCOH estimates are systematically overstated; if PTA pricing floors it above the marginal cost of surplus generation, hydrogen may not be competitive against direct power export.

This project extends the existing techno-economic model by (1) incorporating PTA pricing as the opportunity cost of electricity; (2) computing a break-even PTA price at which Nepal LCOH equals Indian grey hydrogen import costs; and (3) running a three-way scenario analysis (export electricity vs. produce hydrogen vs. domestic electrification) to identify the highest-value use of surplus power under different demand and pricing assumptions.

### Methodology

**Approach:** Techno-economic LCOH modeling + break-even and scenario analysis
**Core model extension:** Modify the existing LCOH framework from Anonymous (2024) to use PTA price as opportunity cost

**LCOH formula:**
$$\text{LCOH} = \frac{\text{CAPEX}_{\text{electrolyzer}} \cdot \text{CRF} + \text{OPEX}}{\text{H}_2 \text{ output (kg/year)}} + \frac{P_{\text{electricity}} \cdot \text{energy intensity (kWh/kg)}}{\text{efficiency}}$$

Where $P_{\text{electricity}}$ = effective opportunity cost of electricity (PTA price or domestic tariff, whichever is higher)

**Three scenarios:**
1. **Export-first:** All surplus sold to India at PTA price; LCOH is residual from non-exportable (off-season) surplus
2. **H₂-first:** Maximum surplus allocated to electrolysis; LCOH computed at full PTA opportunity cost
3. **Domestic-priority:** Surplus after domestic electrification target allocated between H₂ and export

**Break-even analysis:** Solve for PTA price $P^*$ at which Nepal LCOH = Indian grey H₂ import cost (~$1.5–2.5/kg)

**Data sources:**
| Variable | Source |
|----------|--------|
| Surplus hydropower projection (monthly) | Anonymous (2023, 2024); NEA generation plans |
| PTA pricing terms (current and range) | GON MoEWRI documents; WECS reports |
| Alkaline electrolyzer CAPEX (2024–2030) | IRENA Green Hydrogen report (2023); IEA |
| Grey hydrogen import costs in India | IEA, IRENA H₂ reports; Indian Ministry of Petroleum |
| NEA domestic tariff schedule | NEA website (publicly available) |
| Nepal electricity demand forecast | Ghimire et al. (2024); NEA 2024 forecast |

**R packages:** Custom LCOH function; `ggplot2` for scenario waterfall charts and break-even curves

**Timeline:**
| Month | Tasks |
|-------|-------|
| 1 | Data assembly (surplus projections, PTA terms, electrolyzer costs, Indian H₂ market prices); model replication of Anonymous (2024) baseline |
| 2 | PTA pricing integration; three-scenario analysis; break-even computation |
| 3 | Sensitivity analysis (discount rate, electrolyzer learning curves, PTA price range); write-up |

### Expected Contribution

Provides the first LCOH estimate for Nepal that uses a defensible electricity opportunity cost grounded in treaty pricing rather than domestic tariff assumptions. The break-even PTA price directly informs Nepal's negotiating position in PTA renewal discussions. Bridges the gap between the growing green H₂ techno-economic literature and South Asian trade economics. Publishable in *International Journal of Hydrogen Energy* or *Energy Policy*.

### Potential Pitfalls

1. **PTA pricing details may be partially confidential:** Use publicly disclosed framework prices and treaty summaries; conduct wide sensitivity (NPR 4–12/kWh range). Treat undisclosed parameters as scenario variables.
2. **Electrolyzer cost trajectories are uncertain:** 2024 costs well-documented from IRENA; 2028–2030 projections vary widely. Use three learning-curve scenarios (slow/medium/fast).
3. **Indian grey H₂ import price volatility:** Tied to natural gas prices. Report break-even at multiple grey H₂ benchmarks ($1.0, $1.5, $2.0, $2.5/kg).

**Related Work:** Anonymous (2023, 2024) on Nepal surplus hydro; IRENA (2023) Green Hydrogen; Poudel & Kumar (2025)

---

## Ranking

| Proposal | Feasibility | Contribution | Data Risk | Priority |
|----------|-------------|-------------|-----------|----------|
| P1: Energy–Growth Nexus (post-surplus) | HIGH | HIGH | LOW (WDI + NEA reports) | **1** |
| P2: Effective LCOE for Nepal Hydro | HIGH | HIGH | MEDIUM (capital cost data) | **2** |
| P3: AEPC Subsidy Evaluation (DID) | MEDIUM-HIGH | HIGH | MEDIUM-HIGH (AEPC data digitization) | **3** |
| P5: Green H₂ under PTA Pricing | MEDIUM-HIGH | HIGH | MEDIUM (PTA terms) | **3** |
| P4: SSP Downscaling for Nepal | MEDIUM | MEDIUM-HIGH | MEDIUM (biomass data) | **4** |

---

## Suggested Next Steps

1. **P1 immediately actionable:** Download WDI data today via `WDI` package in R; collect NEA Annual Reports (2000–2024) from neanepal.com.np — both possible in Week 1 at zero cost.
2. **P2 and P5 pair well:** P2 establishes the hydro LCOE baseline; P5 uses it as input. A motivated student could do both sequentially.
3. **P3 data risk:** Contact AEPC directly for program rollout data before committing — 2 weeks of data collection can derail a 3-month project. Confirm data availability first.
4. **P4 best for a student with strong econometrics background:** The downscaling exercise requires comfort with panel regressions AND scenario modeling. More suitable if student has prior exposure to IAMs.
5. **Run `/interview-me`** on whichever proposal is selected — the interactive interview will sharpen the identification strategy and surface assumptions before writing begins.

---

## Proposal Files

Ready to write full proposal documents to `proposals/` — use the template in `proposals/README.md`. Suggested filenames:
- `proposals/proposal_01_energy_growth_nexus_nepal.md`
- `proposals/proposal_02_effective_lcoe_nepal_hydro.md`
- `proposals/proposal_03_aepc_subsidy_evaluation.md`
- `proposals/proposal_04_ssp_downscaling_nepal.md`
- `proposals/proposal_05_green_hydrogen_pta_pricing.md`
