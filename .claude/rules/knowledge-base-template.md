---
paths:
  - "Chapters/**/*.tex"
  - "scripts/**/*.R"
  - "scripts/**/*.py"
---

# Thesis Knowledge Base: Climate, Coffee & Migration

<!-- Claude reads this before creating or modifying any chapter content or analysis scripts. -->

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Migration indicator | `m_i` (binary, individual `i`) | `m_i = 1` if migrated to Hawassa IP | `migrate`, `M`, `migr` |
| Destination/employment | `d_it` (individual `i` at time `t`) | `d_it ∈ {IP, farm, other}` | `dest`, `job` |
| Treatment unit | woreda (administrative level 3) | "treated woredas" | "treated villages", "treated districts" |
| Climate shock severity | indexed as `c_wt` (woreda `w`, year `t`) | NDVI deviation from baseline | `climate`, `shock` |
| NDVI variable | `ndvi_wt` | annual mean NDVI for woreda `w`, year `t` | `vegetation`, `greenness` |
| SPEI variable | `spei_wt` | 12-month SPEI for woreda `w`, year `t` | `drought`, `dryness` |
| Coffee yield | `y_wt` | kg arabica per hectare, woreda `w`, year `t` | `coffee`, `harvest` |
| Time index | `t` in years (integer) | `t ∈ {2010, ..., 2022}` | seasons, months (unless specified) |

---

## Symbol Reference

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| `m_i` | Binary migration indicator (1 = migrated to Hawassa IP) | Ch. 1 |
| `c_wt` | Climate degradation index, woreda `w`, year `t` | Ch. 3 |
| `ndvi_wt` | Annual mean NDVI (250m, MODIS), woreda `w`, year `t` | Ch. 2 |
| `spei_wt` | 12-month SPEI drought index, woreda `w`, year `t` | Ch. 2 |
| `y_wt` | Arabica coffee yield (kg/ha), woreda `w`, year `t` | Ch. 3 |
| `alt_w` | Mean altitude of woreda `w` (m above sea level) | Ch. 2 |
| `road_wt` | Road access: hours to nearest major city, year `t` | Ch. 2 |
| `ip_dist_w` | Distance from woreda centroid to Hawassa IP (km) | Ch. 2 |
| `δ_w` | Woreda fixed effect | Ch. 4 |
| `τ_t` | Year fixed effect | Ch. 4 |

---

## Geography Reference

| Location | Level | Notes |
|----------|-------|-------|
| Hawassa (Hawasa) | City / treatment destination | Capital of Sidama Region; site of Hawassa Industrial Park |
| Hawassa Industrial Park | Facility | Opened 2016; primary garment/textile employer |
| Sidama Region (formerly SNNPR) | Region | Main coffee-growing area; primary source zone for thesis |
| SNNPR | Region | Southern Nations, Nationalities and Peoples' Region; split 2020 |
| Woreda | Admin level 3 | Primary unit of analysis (~district) |
| Kebele | Admin level 4 | Sub-woreda; may be relevant for household data |

---

## Chapter Progression

| # | Title | Core Question | Key Method | Key Data |
|---|-------|--------------|------------|----------|
| 1 | Introduction | Does climate degradation drive migration to Hawassa IP? | Motivation | Literature, context |
| 2 | Context & Data | What do the satellite and labor market data show? | Descriptive | GEE: MODIS NDVI, CHIRPS, Hawassa IP records |
| 3 | Climate & Coffee Degradation | How did climate change affect coffee cultivation 2010–2022? | ML classification | GEE satellite imagery, coffee zone shapefiles |
| 4 | Empirical Strategy | How do we identify the causal effect? | TBD (see below) | Constructed degradation index |
| 5 | Results | What is the effect of degradation on migration? | TBD | Combined dataset |
| 6 | Conclusion | What are the contributions and policy implications? | Synthesis | — |

---

## Empirical Strategy

**Status: ASSUMED — reduced-form regression with woreda + year FE**
*(Override this if the strategy is finalized differently)*

Expected baseline specification:
```
m_i = α + β·c_wt + δ_w + τ_t + X_i'γ + ε_i
```
where `c_wt` is the constructed climate/degradation index and `X_i` includes household controls.

**Open questions (update when resolved):**
- Is the variation within-woreda over time, or across woredas?
- Is there a natural experiment (IP opening in 2016) that creates a DiD?
- What is the instrument, if any?

---

## Satellite Data Sources

| Variable | Source | Product | Resolution | Coverage |
|----------|--------|---------|-----------|----------|
| NDVI | MODIS Terra | MOD13Q1 | 250m, 16-day | 2000–present |
| Precipitation | CHIRPS | CHIRPS v2.0 | ~5km, daily | 1981–present |
| SPEI | Derived | From CHIRPS + PET | — | Computed |
| Land cover | ESA CCI | Land Cover | 300m, annual | 1992–2020 |
| Coffee zones | CIFOR/CSA | Arabica suitability | Vector | Static |
| Road network | OpenStreetMap | OSM | Vector | Annual snapshots |

---

## Key Literature

*(Fill in as you read — used by domain-reviewer for citation fidelity checks)*

| Paper | Claim | What It Actually Shows | Watch Out For |
|-------|-------|----------------------|--------------|
| Harris & Todaro (1970) | Rural-urban migration model | Expected income differences drive migration | Does NOT address climate; often misapplied |
| *(add others)* | | | |

---

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Went Wrong | Correction |
|-------------|-----------------|-----------|
| Using `.filterDate("2020-01-01", "2020-12-31")` in GEE | Excludes Dec 31 | Use `"2021-01-01"` as end date |
| Forgetting MODIS scale factor | NDVI values appear 100x too large | Always multiply by 0.0001 |
| Random train/test split on spatial data | Inflated accuracy due to spatial autocorrelation | Use spatial block CV |
| Pooling SNNPR and Sidama Region after 2020 split | Administrative boundaries changed | Filter by woreda code, not region name |

---

## R Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| `lm()` without clustered SEs | Under-estimates SEs with spatial/temporal correlation | Use `fixest::feols(..., cluster = ~woreda_id)` |
| `feols()` drops singletons silently | Changes effective sample | Add `fixef.rm = "none"` to check; document choice |
| Merging on woreda name strings | Name encoding varies across datasets | Merge on numeric woreda codes (P-code) |
| `stargazer` with `feols` output | Incompatible; coef names may mismatch | Use `modelsummary()` instead |
