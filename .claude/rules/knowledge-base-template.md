---
paths:
  - "literature/**/*.md"
  - "proposals/**/*.md"
  - "scripts/**/*.R"
---

# Knowledge Base: Nepal & Global Energy Economics

<!-- Living knowledge base — update as the project grows.
     Claude reads this before creating or modifying any literature or proposal content. -->

---

## Key Concepts & Notation

| Symbol / Abbreviation | Meaning | Notes |
|-----------------------|---------|-------|
| EI | Energy intensity (energy per unit GDP) | Typically koe/$1000 PPP GDP |
| LCOE | Levelized cost of energy ($/MWh) | Lifetime cost per unit output |
| ε | Energy elasticity (% ΔE / % ΔGDP) | >1 = energy-intensive growth |
| RES% | Renewable energy share (% of TPES or electricity) | Distinguish TPES vs. electricity |
| TFP | Total factor productivity | Used in energy-productivity nexus |
| CI | CO₂ emissions intensity (tCO₂/MWh or tCO₂/$GDP) | Watch denominator |
| TPES | Total primary energy supply | IEA standard definition |
| NEA | Nepal Electricity Authority | State utility; publishes annual reports |
| AEPC | Alternative Energy Promotion Centre | Nepal off-grid/rural program |
| DOED | Department of Electricity Development | Nepal licensing authority |
| NPC | National Planning Commission | Nepal central planning body |

---

## Nepal Energy Context

- **Hydropower dominance:** ~90% of electricity from hydro; run-of-river and storage projects
- **Load shedding history:** Severe 2008–2016 (up to 16 hrs/day); largely resolved by 2018 with new capacity
- **Electrification rate:** ~90% household access (2023), but rural reliability remains low
- **Cross-border trade:** Electricity import/export treaty with India; Power Trade Agreement (2014, amended 2021)
- **Off-grid programs:** AEPC subsidizes solar home systems and micro-hydro for remote areas
- **Remittance economy:** Remittances ~25% of GDP; energy demand partly driven by remittance-funded appliances
- **Landlocked geography:** No coast; oil/gas entirely imported via India → price pass-through risk
- **Energy mix:** Electricity ~hydro; cooking energy ~biomass (firewood/dung) in rural areas → dual energy poverty
- **Key policy docs:** Nepal Energy Crisis Reduction and Electricity Development Decade (2009), NEA Annual Reports

---

## Global Energy Context

- **IEA World Energy Outlook (WEO):** Annual flagship; scenarios (STEPS, APS, NZE); use latest vintage
- **IRENA:** Renewable capacity data, LCOE trends, country profiles
- **BP Statistical Review of World Energy:** Now "Energy Institute Statistical Review"; historical series
- **REN21 Global Status Report:** Annual renewable policy tracking
- **SDG7:** Affordable and clean energy for all — benchmarking framework
- **Energy transition:** Shift from fossil to low-carbon; tracked via RES%, CI, LCOE convergence

---

## Top Journals

| Journal | Scope |
|---------|-------|
| Energy Economics | Econometric energy studies; high impact |
| Energy Policy | Policy-oriented; interdisciplinary |
| Nature Energy | High-impact; methods + policy |
| The Energy Journal | IAEE flagship; theory + empirics |
| Resource and Energy Economics | Natural resource + energy micro |
| Renewable and Sustainable Energy Reviews | Comprehensive reviews; LCOE, transitions |
| Applied Energy | Engineering-economics interface |
| World Development | Development economics; energy-poverty nexus |

---

## Key Data Sources

| Source | Data | Access |
|--------|------|--------|
| IEA (iea.org) | TPES, electricity, CO₂, balances | Free basic; subscription for detail |
| IRENA (irena.org) | Renewable capacity, LCOE by technology | Free download |
| World Bank WDI | GDP, population, EI, access rates | `WDI` R package |
| EIA (eia.gov) | US + international energy statistics | Free |
| NEA Annual Reports | Nepal electricity production, losses, tariffs | neanepal.com.np |
| DOED | Nepal hydro project register | doed.gov.np |
| WITS (World Bank) | Energy trade flows | wits.worldbank.org |
| BP/Energy Institute | Long historical series (1965–) | energyinst.org |
| Global Power Plant Database | Plant-level data | WRI; open data |

---

## Methodological Toolkit

| Method | Use Case | Key R Packages |
|--------|----------|----------------|
| Panel data (FE/RE/TWFE) | Energy-growth nexus, EI determinants | `plm`, `fixest` |
| Difference-in-differences | Policy impact evaluation | `did`, `fixest` |
| Synthetic control | Country-level policy evaluation | `Synth`, `tidysynth` |
| ARDL bounds testing | Long-run cointegration, small T | `ARDL`, `dLagM` |
| VAR/VECM | Energy-GDP causality (Granger) | `vars` |
| Panel unit root tests | Stationarity before regression | `urca`, `CADFtest` |
| Meta-analysis | Synthesizing elasticity estimates | `metafor` |
| Decomposition (LMDI) | Driving factors of EI change | Manual implementation |

---

## Literature Positioning Landmarks

- **Energy-growth nexus:** Kraft & Kraft (1978) → Apergis & Payne (2009–) panel studies → Kahia et al.
- **LCOE convergence:** IRENA series (2010–) → Lazard (annual); renewables at grid parity in many markets by 2020
- **Nepal energy studies:** Timilsina & Shrestha; Gurung & Oh; Pokharel — small but growing literature
- **Hydropower + development:** Allcott et al. (2016, India power outages); Dinkelman (2011, electrification SA)
- **Energy transition benchmarks:** IEA NZE (2021); IPCC AR6 WG3 (2022)

---

## Anti-Patterns (Don't Do This)

| Anti-Pattern | Problem | Correction |
|-------------|---------|------------|
| Mix TPES and electricity RES% | Incomparable denominators | State which measure; footnote |
| Use nominal GDP for EI | Misleads cross-country comparison | Use PPP-adjusted GDP (constant 2017 int'l $) |
| Skip unit root test before ARDL | May estimate spurious regression | Always: ADF + KPSS → report both |
| Attribute causality from Granger | Granger ≠ structural causality | Use "Granger-causes" language only |
| Ignore cross-sectional dependence | Biased SE in panel if CD present | Pesaran CD test first; use CCEP/AMG if needed |
| Use IEA data across different vintages without checking | Units change (Mtoe→EJ); base years shift | Pin vintage; document in data section |
