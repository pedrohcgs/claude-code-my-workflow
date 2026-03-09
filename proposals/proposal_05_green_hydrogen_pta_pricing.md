# Green Hydrogen from Nepalese Surplus Hydropower: Feasibility Under Power Trade Agreement Pricing

**Status:** DRAFT
**Quality score:** —
**Date:** 2026-03-08

---

## Research Question

Is green hydrogen production from Nepal's projected surplus hydropower economically feasible when the effective electricity cost reflects the Nepal–India Power Trade Agreement (PTA) pricing regime — rather than the domestic NEA tariff assumed in prior studies? At what PTA electricity price floor does Nepal's LCOH become competitive with Indian grey hydrogen import costs?

---

## Abstract

Two recent studies (Anonymous 2023; Anonymous 2024) project substantial surplus hydropower in Nepal from 2025 onward, peaking at ~25 TWh in 2028, and evaluate green hydrogen production via alkaline electrolysis. Both find levelized cost of hydrogen (LCOH) highly sensitive to electricity price assumptions — but neither incorporates the actual pricing constraints of Nepal's bilateral Power Trade Agreement with India, which governs the effective opportunity cost of electricity. This is a critical omission: the opportunity cost of electricity used for hydrogen production is the export revenue foregone under PTA terms, not the domestic NEA tariff.

This project extends the existing techno-economic framework by (1) substituting PTA pricing as the opportunity cost of electricity; (2) computing the break-even PTA price $P^*$ at which Nepal's LCOH equals Indian grey hydrogen import costs ($1.5–2.5/kg); and (3) running a three-way scenario analysis — direct export to India, hydrogen production, domestic electrification — to identify the highest-value allocation of surplus power under alternative demand and pricing assumptions. The deliverable is a transparent, replicable R model with full sensitivity documentation.

---

## Motivation & Background

Green hydrogen has attracted enormous attention as a long-duration storage medium and industrial decarbonizer. Nepal's projected hydropower surplus (25 TWh peak in 2028) is large enough to support a meaningful hydrogen industry — if the economics work. The prior studies assume full NEA tariff pricing for electricity inputs, but this overstates the opportunity cost during monsoon surplus when marginal power has low or zero export value under PTA pricing constraints. Conversely, if PTA pricing floors the opportunity cost above the marginal generation cost, hydrogen becomes less attractive than direct export.

The PTA also sets terms for *direct* electricity export, meaning that the three-way allocation problem (export vs. H₂ vs. domestic use) must be solved simultaneously — something neither prior study attempts. Nepal is currently negotiating PTA terms with India and exploring cross-border hydrogen trade with Bangladesh; this study provides quantitative inputs for those negotiations.

Key citations: Anonymous (2023, 2024) on Nepal surplus hydro; IRENA (2023) Green Hydrogen; Poudel & Kumar (2025); IRENA (2024, 2025) LCOE data.

---

## Methodology

### Data

| Variable | Source | Notes |
|----------|--------|-------|
| Monthly surplus hydropower projection (GWh) | Anonymous (2023, 2024); NEA 2024 generation forecast | 2025–2035 |
| PTA pricing terms (NPR/kWh by season/time-of-day) | GON MoEWRI; WECS; PTA agreement text | Treat sensitive terms as scenario range |
| Alkaline electrolyzer CAPEX (2024 and 2028 projected) | IRENA Green Hydrogen report (2023); IEA | Learning curve: slow/medium/fast scenarios |
| Electrolyzer energy intensity (kWh/kg H₂) | IRENA; industry standard: 50–55 kWh/kg | Alkaline technology; 2024 benchmark |
| O&M costs (electrolyzer) | IRENA; industry: 2–4% CAPEX/year | — |
| Grey hydrogen import costs in India ($/kg) | IEA; IRENA H₂ Insights; Indian Ministry of Petroleum | Range: $1.0–$2.5/kg depending on gas price |
| NEA domestic tariff schedule | NEA (publicly available) | Comparison baseline |
| Discount rate | World Bank Nepal; sensitivity: 6–12% | — |

### Estimation Strategy

**Core LCOH formula:**

$$\text{LCOH} = \frac{\text{CAPEX}_{\text{elec}} \cdot \text{CRF} + \text{OPEX}}{\text{H}_2\text{ output (kg/year)}} + \frac{P_{\text{elec}} \cdot \eta}{\text{efficiency}}$$

Where $P_{\text{elec}}$ = opportunity cost of electricity (PTA export price during surplus window; NEA tariff otherwise)

**Three scenarios:**

| Scenario | Electricity allocation | $P_{\text{elec}}$ used |
|----------|----------------------|------------------------|
| Export-first | All surplus exported at PTA price; H₂ from residual non-exportable | PTA seasonal floor |
| H₂-first | Maximum surplus allocated to electrolysis | Full PTA price (foregone export) |
| Domestic-priority | Domestic electrification targets met first; remainder split by optimization | Blended |

**Break-even analysis:** Solve for $P^* = \text{PTA price}$ such that LCOH = Indian grey H₂ benchmark. Plot break-even curve across discount rates and electrolyzer learning scenarios.

**Sensitivity (tornado chart):** PTA price (±50%), CAPEX (±30%), discount rate (6–12%), efficiency (50–55 kWh/kg), grey H₂ benchmark price ($1.0–$2.5/kg)

**R implementation:** Custom LCOH and break-even functions; scenario waterfall charts; tornado sensitivity plot with `ggplot2`

### Timeline

| Month | Milestones |
|-------|-----------|
| 1 | Data assembly (surplus projections, PTA terms, electrolyzer costs, Indian H₂ market); replicate Anonymous (2024) baseline LCOH as validation |
| 2 | PTA opportunity cost integration; three-scenario analysis; break-even computation |
| 3 | Sensitivity analysis; tornado charts; write-up |

---

## Expected Findings & Contribution

**Expected finding:** LCOH estimates from prior studies are likely overstated because they use domestic NEA tariff as electricity cost rather than the (lower) PTA export price during monsoon surplus. Correcting for this makes hydrogen more competitive in the export-first scenario but may reduce attractiveness in the H₂-first scenario where all surplus has high opportunity cost. The break-even PTA price $P^*$ provides a concrete threshold for Nepal's trade negotiators.

**Contribution:** First LCOH analysis for Nepal incorporating PTA pricing as the opportunity cost of electricity. Bridges techno-economic modeling with trade economics. Break-even analysis directly applicable to Nepal–India PTA renegotiations and emerging Nepal–Bangladesh hydrogen trade discussions. Methodological framework generalizable to Bhutan and Laos (similar run-of-river surplus + bilateral trade structures).

**Target journals:** *International Journal of Hydrogen Energy*; *Energy Policy*; *Renewable Energy*

---

## Data Availability Check

- [x] Anonymous (2023) surplus projections: publicly available paper (Renewable Energy)
- [x] IRENA Green Hydrogen costs: free download
- [x] NEA tariff schedule: publicly available
- [ ] PTA pricing terms: publicly disclosed framework; some details may require MoEWRI documents — use range if full terms unavailable
- [x] Indian grey H₂ import costs: IEA + IRENA publications (public)
- [x] R packages: base R + `ggplot2`, `dplyr` — no specialized packages needed

---

## Potential Limitations

- PTA pricing details may be partially confidential. Use publicly disclosed framework (NPR 4–12/kWh) as scenario range; present break-even in terms of the PTA price, so policymakers can substitute actual terms.
- Electrolyzer cost trajectories 2025–2030 are uncertain; global learning curves may accelerate or slow. Use three learning scenarios (IRENA slow/medium/fast) as standard.
- Indian grey H₂ import price is tied to natural gas prices — volatile. Report break-even at four grey H₂ benchmarks ($1.0, $1.5, $2.0, $2.5/kg) to bracket the relevant range.

---

## References

- Anonymous (2023). Evaluation of Surplus Hydroelectricity Potential in Nepal Until 2040. *Renewable Energy*, 212, 403–414. DOI: 10.1016/j.renene.2023.05.062
- Anonymous (2024). Hydrogen Production from Surplus Hydropower: Techno-Economic Assessment. *Int'l J. Hydrogen Energy*. [DOI to verify]
- IRENA (2023). Green Hydrogen: A Guide to Policy Making. Abu Dhabi.
- IRENA (2025). Renewable Power Generation Costs in 2024. Abu Dhabi.
- Poudel, Y.K. & Kumar, R. (2025). Review of Energy Policies and Strategies in Nepal. *Int'l J. Sustainable and Green Energy*, 14(2).
