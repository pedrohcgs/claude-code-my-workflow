# Is Nepal's Hydropower Actually Cheap? Effective LCOE Accounting for Seasonality, Transmission Loss, and Export Pricing

**Status:** DRAFT
**Quality score:** —
**Date:** 2026-03-08

---

## Research Question

What is the effective levelized cost of electricity (LCOE) from Nepal's run-of-river hydropower when accounting for seasonal output mismatch, transmission and distribution losses (~20–25%), and constrained pricing under the Nepal–India Power Trade Agreement (PTA)? Is it competitive against solar PV + battery storage alternatives at Nepal's latitude?

---

## Abstract

Global IRENA benchmarks (2024) report hydropower LCOE at $0.057/kWh — above both onshore wind ($0.034) and solar PV ($0.043). Yet Nepal's hydro capacity is routinely described as its primary comparative advantage. This apparent contradiction is never resolved in the published literature because global figures do not account for Nepal-specific factors: (1) severe seasonal mismatch between monsoon surplus and dry-season shortage, (2) average T&D losses of ~20–25%, (3) PTA export prices often below cost-recovery tariffs, and (4) absence of storage capacity. This project constructs a transparent, replicable effective LCOE for Nepal's hydropower fleet using public NEA and DOED data, then compares it against the effective LCOE of a solar PV + lithium-ion storage system designed for comparable seasonal reliability. Sensitivity analysis varies PTA pricing, discount rate, and storage duration. The goal: a cost comparison Nepal's planners can update annually.

---

## Motivation & Background

The global energy transition benchmark from IRENA shows renewables (solar, wind) are now the cheapest new electricity globally (IRENA 2025). But Nepal's situation is more complex: its run-of-river hydro generates predominantly in the monsoon season (May–October), leaving a severe dry-season deficit that the country currently covers with power imports from India. The PTA (2014, updated 2021) governs cross-border pricing — and those negotiated prices may not reflect the full economic value of Nepalese hydro.

Understanding the effective LCOE of existing and planned hydro — correctly adjusted for seasonality, losses, and trade constraints — is the foundational calculation for deciding whether Nepal should (a) export surplus power, (b) invest in storage, or (c) develop solar to complement dry-season gaps. No published paper provides this calculation.

Key citations: IRENA (2024, 2025); Poudel & Kumar (2025); Anonymous (2023, 2024) on Nepal surplus hydro.

---

## Methodology

### Data

| Variable | Source | Notes |
|----------|--------|-------|
| Monthly generation by plant type | NEA Annual Reports (2018–2024) | Seasonal capacity factors |
| T&D losses (%) | NEA Annual Reports | Transmission + distribution separately if available |
| PTA pricing (NPR/kWh) | GON MoEWRI; WECS publications | Use as opportunity cost range |
| Project capital costs | World Bank project documents; DOED register | Sensitivity: ±30% |
| O&M costs | Industry standard: 2–3% of CAPEX/year | Triangulate with NEA reports |
| Solar irradiance (monthly, by region) | NASA POWER API (free, lat/lon) | Run for Terai, mid-hills, mountain zones |
| Battery storage cost | IRENA 2024 ($192/kWh utility-scale) | Sensitivity: learning curve scenarios |
| Discount rate | World Bank Nepal country estimate | Test r = 6%, 8%, 10%, 12% |

### Estimation Strategy

**Core LCOE formula:**

$$\text{LCOE} = \frac{\sum_{t=0}^{T} \frac{C_t + O_t}{(1+r)^t}}{\sum_{t=0}^{T} \frac{E_t \cdot (1 - L_t)}{(1+r)^t}}$$

Where: $E_t$ = gross generation, $L_t$ = T&D loss rate (applied to *delivered* energy denominator)

**Seasonal adjustment:** Weight monthly capacity factors from NEA hydrology to derive annual effective delivered LCOE

**PTA sensitivity:** Vary opportunity cost of electricity from NPR 4.0/kWh (PTA floor) to NPR 12.0/kWh (long-run avoided cost); this shifts the *effective* LCOE by making high-value export uses costly

**Solar + storage comparison:** NASA POWER irradiance → capacity factor → LCOE using IRENA installed cost; add storage at $192/kWh to cover dry-season gap; compute system LCOE

**Output:** Table of effective LCOE scenarios; tornado sensitivity chart; seasonal cost comparison (wet vs. dry season)

### Timeline

| Month | Milestones |
|-------|-----------|
| 1 | NEA data collection; NASA POWER API pulls; DOED capital cost assembly; LCOE function in R |
| 2 | Hydro effective LCOE computation; solar+storage benchmark; PTA sensitivity analysis |
| 3 | Three-way scenario comparison; tornado plots; write-up |

---

## Expected Findings & Contribution

**Expected finding:** Effective LCOE of Nepal's run-of-river hydro, once adjusted for T&D losses (~25%) and seasonal mismatch, likely exceeds the unadjusted $0.057/kWh benchmark. Solar + short-duration storage is likely competitive for the dry-season gap at Nepal's latitude, given IRENA's reported South Asian solar costs. The PTA pricing regime substantially affects whether hydrogen or direct export is the better use of monsoon surplus.

**Contribution:** First transparent, replicable LCOE comparison for Nepal incorporating seasonality, losses, and treaty pricing. Directly informs Nepal's surplus allocation debate (export vs. store vs. produce H₂). Methodological framework applicable to other run-of-river hydro economies (Bhutan, Laos, Ethiopia).

**Target journals:** *Renewable Energy*; *Energy Policy*; *Applied Energy*

---

## Data Availability Check

- [x] NEA Annual Reports: publicly available (neanepal.com.np)
- [x] NASA POWER irradiance API: free, no registration
- [x] IRENA cost data: freely downloadable
- [ ] DOED project capital costs: partially public — verify coverage before committing
- [x] No proprietary data required (if capital cost gap filled by sensitivity analysis)

---

## Potential Limitations

- Project-level capital cost data is sparse for Nepal — many BOT projects don't disclose final costs. Conduct ±30% sensitivity; report as primary scenario uncertainty.
- PTA pricing terms are politically sensitive and subject to renegotiation — treat as scenario variable with wide range.
- Discount rate dominates LCOE in capital-intensive technologies: report four rates (6%, 8%, 10%, 12%) as standard.

---

## References

- IRENA (2025). Renewable Power Generation Costs in 2024. Abu Dhabi.
- IRENA (2024). Renewable Power Generation Costs in 2023. Abu Dhabi.
- Poudel, Y.K. & Kumar, R. (2025). Review of Energy Policies and Strategies in Nepal. *Int'l J. Sustainable and Green Energy*, 14(2).
- Anonymous (2023). Evaluation of Surplus Hydroelectricity Potential in Nepal Until 2040. *Renewable Energy*, 212, 403–414.
- Anonymous (2024). Hydrogen Production from Surplus Hydropower. *Int'l J. Hydrogen Energy*.
