---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
  - "**/*.py"
  - "notebooks/**"
---

# Project Knowledge Base: PV Module Reliability

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Efficiency | η (eta), fraction internally, % for display | η = 0.21 (21%) | Mixing fraction and % in same equation |
| Irradiance | G with subscript for type | G_POA, G_DNI | Bare "G" without specifying plane |
| Temperature | T with subscript | T_c (cell), T_a (ambient), T_m (module) | Bare "T" without context |
| Degradation rate | R_d, always %/year | R_d = -0.5 %/year | Omitting sign convention or units |
| Time series | Timezone-aware timestamps | `2024-01-01T12:00:00-07:00` | Naive timestamps for solar data |

## Symbol Reference

| Symbol | Meaning | Typical Units |
|--------|---------|---------------|
| η | Conversion efficiency | fraction or % |
| I_sc | Short-circuit current | A |
| V_oc | Open-circuit voltage | V |
| FF | Fill factor | fraction or % |
| P_max | Maximum power | W |
| E_g | Bandgap energy | eV |
| G | Irradiance | W/m² |
| T_c | Cell temperature | °C |
| R_d | Degradation rate | %/year |
| E_a | Activation energy (Arrhenius) | eV |
| AF | Acceleration factor | dimensionless |
| β | Weibull shape parameter | dimensionless |
| η_w | Weibull scale parameter (characteristic life) | hours or years |
| PR | Performance ratio | fraction or % |
| Y_f | Final yield | kWh/kWp |

## Module Progression

| # | Title | Core Question | Key Notation | Key Method |
|---|-------|--------------|-------------|------------|
| 1 | Optical Degradation | How does light transmission degrade? | τ, R, α, EQE | Spectrophotometry, yellowing index |
| 2 | Thermal Stress | How does heat cause failure? | T_c, E_a, AF, NOCT | Arrhenius modeling, thermal cycling |
| 3 | Mechanical Failure | What causes structural breakdown? | σ, ε, N_f | Fatigue analysis, EL imaging |
| 4 | Environmental Exposure | How do field conditions degrade modules? | RH, UV dose, V_sys | DH testing, PID protocols, corrosion |

## Empirical Applications

| Application | Source | Dataset | Module(s) | Purpose |
|------------|--------|---------|-----------|---------|
| Field degradation rates | Jordan & Kurtz (2013) | NREL compilation | All | Benchmark R_d values |
| Damp heat acceleration | IEC 61215 | Lab testing | 2, 4 | Qualification thresholds |
| PID susceptibility | Hacke et al. | Sandia/NREL | 4 | System voltage stress |
| Thermal cycling | IEC 61215 | Lab testing | 2, 3 | TC200/TC600 protocols |
| Soiling losses | Ilse et al. | Multi-site | All | Energy yield correction |

## Design Principles

| Principle | Evidence | Modules Applied |
|-----------|----------|-----------------|
| STC ≠ real world | Field data consistently differs from nameplate | All |
| Acceleration ≠ replication | Lab tests accelerate, not replicate, field conditions | 2, 3, 4 |
| Multiple mechanisms interact | PID + thermal + mechanical compound in the field | All |

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| Reporting STC efficiency as field performance | Overstated yield by 15-25% | Always apply temperature, spectral, soiling derating |
| Using linear R_d for early-life LID | Poor fit for first-year degradation | Model LID separately from long-term degradation |
| Ignoring spectral mismatch in indoor testing | 2-5% error in cell efficiency | Apply spectral mismatch factor |
| Naive timestamps with pvlib | Wrong solar position calculations | Always use timezone-aware timestamps |

## Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| pvlib timezone-naive input | Wrong solar zenith/azimuth | Use `tz`-aware `pd.DatetimeIndex` |
| solcore layer order reversed | Wrong reflectance/absorption | Verify layer ordering: front to back |
| Mixed W/m² and kW/m² | 1000x error in energy yield | Standardize to W/m² at data ingestion |
| Integer year in degradation calc | Truncated fractional years | Use float for time deltas |
| SCAPS mesh too coarse | Non-convergent or wrong J-V | Start with default mesh, refine iteratively |
