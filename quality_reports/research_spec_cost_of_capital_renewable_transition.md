# Research Specification: The Cost-of-Capital Trap and Renewable Energy Transition in Developing Countries

**Date:** 2026-03-09
**Researcher:** Carthage student project (3-month scope)
**Status:** DRAFT — for review and adjustment

---

## Research Question

Does a higher cost of capital causally retard renewable energy capacity deployment in developing countries, and by how much — measured in MW of foregone capacity per percentage-point increase in financing costs?

---

## Motivation

The global energy transition has accelerated dramatically: solar LCOE fell to $0.043/kWh globally in 2024 (IRENA), renewables now represent over 90% of new electricity capacity additions worldwide, and cumulative transition investment reached $2.3 trillion in 2025. Yet this aggregate story conceals enormous heterogeneity — most of the growth is concentrated in China, Europe, and the United States, while large swaths of the developing world are largely absent from the transition.

The standard explanation invokes "weak institutions" or "policy failures," but this is underspecified. A more precise and testable mechanism is the cost-of-capital trap: renewable energy technologies are overwhelmingly capital-intensive (high upfront CAPEX, near-zero marginal fuel cost), meaning their competitiveness relative to fossil fuels is hypersensitive to the discount rate applied to future cash flows. A solar plant that is cheaper than coal at a 6% discount rate becomes more expensive at a 15% rate — the range typical of emerging versus advanced economies. If this mechanism is operative, then the renewable transition in developing countries is not primarily blocked by policy design failures but by financial market conditions — a fundamentally different diagnosis with different policy implications (blended finance, risk guarantees, concessional capital) than the standard "improve governance" prescription.

A 2024 Nature Energy paper (Anonymous 2024) provides theoretical grounding and simulation evidence for this mechanism, but to date no large-panel empirical study with credible causal identification has tested it across developing countries. This proposal fills that gap.

---

## Hypothesis

**Primary:** A one percentage-point increase in the cost of capital facing renewable energy developers in a developing country reduces annual renewable capacity additions by X MW per capita (expected sign: negative; magnitude: to be estimated).

**Secondary:** The cost-of-capital effect is larger for solar PV and wind (highly capital-intensive, zero fuel cost) than for natural gas peakers (lower CAPEX, ongoing fuel cost) — consistent with the mechanism rather than a generic "investment climate" story.

**Corollary:** The effect is concentrated in countries with low multilateral finance access (where private capital cannot be substituted with concessional lending).

---

## Empirical Strategy

### Method
Two-Stage Least Squares (2SLS) panel IV, with country and year fixed effects.

**First stage:** Regress cost-of-capital proxy on the instrument (shift-share IV) and controls.

**Second stage:** Regress renewable capacity additions on instrumented cost of capital and controls.

### Instrument: Shift-Share (Bartik) Design

$$Z_{it} = \text{CapOpen}_{i,\text{pre}} \times \Delta\text{GlobalFinStress}_{t}$$

Where:
- $\text{CapOpen}_{i,\text{pre}}$ = country $i$'s capital account openness *before* the sample period (Chinn-Ito index, pre-2000 average) — predetermined, not affected by subsequent energy policy
- $\Delta\text{GlobalFinStress}_{t}$ = year-on-year change in global financial stress (VIX index or US Federal Funds Rate) — exogenous to any individual developing country's energy choices

**Logic:** Countries more financially integrated with global capital markets (high pre-determined openness) experience larger increases in domestic borrowing costs when global financial conditions tighten (2008 GFC, 2013 taper tantrum, 2022 US rate hike cycle). This differential exposure is plausibly exogenous to their renewable energy policies.

**Key identifying assumption (exclusion restriction):** Pre-determined capital account openness affects renewable capacity additions *only through* its effect on financing costs during global stress episodes — not through direct channels such as FDI in renewables or technology transfer. This assumption is partially testable: in low-stress years ($\Delta\text{GlobalFinStress}_t \approx 0$), the instrument should have no first-stage bite, so the interaction term should be inert — a testable prediction.

### Specification

**First stage:**
$$\widehat{\text{CoC}}_{it} = \alpha + \beta Z_{it} + \gamma X_{it} + \mu_i + \lambda_t + \varepsilon_{it}$$

**Second stage:**
$$\text{RenewCap}_{it} = \alpha + \delta \widehat{\text{CoC}}_{it} + \gamma X_{it} + \mu_i + \lambda_t + u_{it}$$

Where $\mu_i$ = country FE, $\lambda_t$ = year FE, $X_{it}$ = controls (see Data section)

### Robustness Checks
1. **Placebo instrument:** Replace $\Delta\text{GlobalFinStress}_t$ with a lagged or placebo stress shock — should produce null first stage
2. **Alternative cost-of-capital proxies:** lending rate spread, sovereign bond spread, EMBI+ spread
3. **Alternative outcomes:** Renewable share of electricity (%); renewable investment ($M); solar-only capacity additions
4. **Controlling for fossil fuel rents:** Interact with oil/gas rents to test whether resource curse moderates the effect
5. **Excluding China and India:** Confirm results are not driven by the two largest developing-country markets
6. **Stacked regression:** Identify off major global stress episodes (2008, 2013, 2022) separately; check consistency

---

## Data

### Primary Datasets

| Variable | Source | Coverage | Notes |
|----------|--------|----------|-------|
| Renewable capacity additions (MW/year) | IRENA Renewable Capacity Statistics | ~150 countries, 2000–2024 | Free download; technology-disaggregated |
| Renewable share of electricity (%) | WDI `EG.ELC.RNEW.ZS` | ~150 countries, 2000–2023 | Secondary outcome |
| Domestic lending rate / interest spread | WDI `FR.INR.LNDP` | ~120 developing countries | Cost-of-capital proxy |
| Private credit / GDP | World Bank Global Financial Development Database | ~150 countries, 1960–2020 | Financial depth control |
| Capital account openness | Chinn-Ito index (freely available, updated annually) | ~180 countries, 1970–2022 | Pre-determined shift variable |
| Global financial stress | FRED: US Federal Funds Rate; CBOE VIX | Annual, 2000–2024 | Share variable |
| GDP per capita (PPP) | WDI `NY.GDP.PCAP.PP.KD` | ~150 countries | Control |
| Fossil fuel rents (% GDP) | WDI `NY.GDP.TOTL.RT.ZS` | ~150 countries | Control; policy environment |
| Renewable resource endowment | Global Solar Atlas (ESMAP/WB); IRENA wind atlas | Country averages | Geographic control |
| World Governance Indicators | World Bank WGI | ~180 countries, 1996–2023 | Institutional controls |
| FDI inflows (% GDP) | WDI `BX.KLT.DINV.WD.GD.ZS` | ~150 countries | Channel/control |

### Sample
- **Unit:** Country-year
- **Countries:** ~110–130 developing countries (World Bank classification: low + middle income)
- **Period:** 2000–2023 (24 years)
- **Approximate N:** ~2,600–3,100 country-year observations (unbalanced panel)
- **Exclude:** High-income OECD countries; countries with <5 consecutive years of data

### Key Variables
- **Treatment (endogenous):** Domestic lending rate spread (WDI) — instrumented by shift-share IV
- **Outcome (primary):** Annual renewable capacity additions per capita (MW per million population)
- **Instrument:** $\text{CapOpen}_{i,\text{pre}} \times \Delta\text{VIX}_t$ or $\times \Delta\text{FFR}_t$

### R Implementation
```r
# Data pull
library(WDI); library(here); set.seed(42)
wdi_vars <- c("EG.ELC.RNEW.ZS", "FR.INR.LNDP", "NY.GDP.PCAP.PP.KD",
              "NY.GDP.TOTL.RT.ZS", "BX.KLT.DINV.WD.GD.ZS")
panel <- WDI(country = "all", indicator = wdi_vars,
             start = 2000, end = 2023, extra = TRUE)

# Estimation
library(fixest)
# First stage
fs <- feols(CoC ~ shift_share_iv + controls | country + year, data = panel)
# 2SLS
iv <- feols(renew_cap ~ controls | country + year | CoC ~ shift_share_iv, data = panel)
```

---

## Expected Results

**Main finding (expected):** A one percentage-point increase in instrumented cost of capital reduces annual renewable capacity additions by approximately 0.05–0.15 MW per million population — economically significant given that median developing-country additions are ~0.5–1.5 MW per million per year. This would imply that closing the financing cost gap between developing and advanced economies (roughly 8–10 pp) could roughly double or triple renewable deployment in developing countries absent any other policy change.

**Heterogeneity (expected):**
- Larger effect for solar PV and wind (zero fuel cost — fully exposed to discount rate) than gas peakers
- Smaller effect in countries with active IDA/IFC lending programs (concessional capital partially offsets market rate)
- Effect concentrated in the 2013 and 2022 global tightening episodes (where instrument has most variation)

**Potential null result:** If the cost-of-capital effect is statistically insignificant, this is itself informative — it would suggest that other constraints (grid infrastructure, policy design, land rights) dominate, and financial market conditions are secondary. Both a positive and null result are publishable if identification is credible.

---

## Contribution

This study provides the first large-panel causal estimate of the cost-of-capital effect on renewable energy transition in developing countries, using a Bartik-style IV to address the endogeneity of financing conditions. It directly tests the theoretical mechanism in Anonymous (2024, Nature Energy) and provides the first empirical foundation for quantifying blended finance's potential impact on renewable deployment — a question currently addressed only with simulations. The shift-share design is novel in the energy transition literature and may serve as a methodological template for related questions (e.g., does FDI in renewables respond to the same financing channel?).

**Target journals:** *Energy Economics*; *Nature Energy* (if identification is particularly clean); *Journal of Development Economics* (if heterogeneity/development angle is front-and-center)

---

## Open Questions for Adjustment

The following design choices are provisional and open for revision:

1. **Instrument choice:** VIX vs. US Federal Funds Rate as the stress variable — FFR is cleaner (policy-driven) but lower frequency; VIX is noisier but annual. Could use both as overidentified system and test Sargan-Hansen J-statistic.

2. **Cost-of-capital proxy:** WDI lending rate spread is noisy and has many missing values for LICs. Alternative: use sovereign EMBI spread (available for ~70 developing countries) for a cleaner but smaller sample. Trade-off: coverage vs. precision.

3. **Exclusion restriction validity:** The Chinn-Ito × VIX instrument may violate exclusion if financially open countries also receive more renewable FDI during calm periods (positive direct channel). Need to argue carefully why the interaction — not the level of openness — is the relevant variation, and test that result holds in sub-samples that exclude large FDI recipients.

4. **Time period:** Extending to 2024 would capture the 2022–2024 rate cycle but IRENA 2024 data may not yet be available at the country-year level. Confirm data vintage before finalizing sample end date.

5. **Outcome unit:** MW per capita vs. MW in levels vs. log(1 + MW) — the distribution of capacity additions is right-skewed with many zeros. PPML (Poisson Pseudo-Maximum Likelihood) may be preferable to OLS for the outcome; test both.
