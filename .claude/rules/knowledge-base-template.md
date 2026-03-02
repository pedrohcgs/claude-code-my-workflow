---
paths:
  - "Paper/**/*.tex"
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "code/**/*.do"
  - "code/**/*.py"
  - "scripts/**/*.R"
---

# Project Knowledge Base: Geopolitics and Global Value Chains

<!-- Claude reads this before creating or modifying any code, paper, or slide content.
     All notation and conventions below are binding unless explicitly overridden. -->

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Matrices: uppercase bold | **Z**, **A**, **L**, **Y** | `\mathbf{Z}`, `\mathbf{A}` | z, a, l, y |
| Vectors: lowercase bold | **x**, **v**, **g**, **y** | `\mathbf{x}`, `\mathbf{y}_c` | x, v (italic, unbolded) |
| Country index (source) | i, k | w_{i,c,t} | country, src, j |
| Country index (focus) | c | Exposure_{c,t} | home, target |
| Time index | t | seg(i,t) | year, yr, T |
| Sector index | s | FVA_{i,s,t} | sec, sector, ind |
| Dimension | N countries × I industries | N·I | NI, n*i |

## Symbol Reference

| Symbol | Meaning | Defined In |
|--------|---------|------------|
| **Z** | Intermediate transaction matrix (N·I × N·I) | Sec 2 (Data & Method) |
| **A** | Technical coefficients: **A** = **Z** · diag(**x**)⁻¹ | Sec 2 |
| **L** | Leontief inverse: **L** = (**I** − **A**)⁻¹ | Sec 2 |
| **Y** | Final demand matrix (N·I × N·F) | Sec 2 |
| **x** | Gross output vector (N·I × 1) | Sec 2 |
| **y**_c | Final demand vector for focus country c (N·I × 1) | Sec 2 |
| **VA** | Value added vector (N·I × 1) | Sec 2 |
| **v** | VA intensity: v = VA / x (elementwise; set v_i = 0 when x_i = 0) | Sec 2 |
| **g** | Total output to satisfy c's final demand: **g** = **L** · **y**_c | Sec 2 |
| VAcontr | VA contributions: VAcontr = diag(**v**) · **g** | Sec 2 |
| FVA_{i,c,t} | Foreign VA from country i embodied in country c's final demand, year t | Sec 3 |
| w_{i,c,t} | FVA weight: FVA_{i,c,t} / Σ_{k≠c} FVA_{k,c,t} (sums to 1 over i≠c) | Sec 3 |
| IPD(i,j,t) | Ideal-point distance between countries i and j at year t (Bailey-Strezhnev-Voeten) | Sec 3 |
| seg(i,t) | US-China pivot score: [IPD(i,CHN,t)−IPD(i,US,t)] / [IPD(i,US,t)+IPD(i,CHN,t)] ∈ [−1,+1] | Sec 3 |
| Exposure_{c,t} | Σ_{i≠c} w_{i,c,t} · seg(i,t) — weighted average pivot of c's supply chain | Sec 4 |
| Risk_{c,t} | Σ_{i≠c} w_{i,c,t} · \|seg(i,t)−seg(c,t)\| / 2 — mismatch with own alignment | Sec 4 |

## Key Formulas (Do Not Deviate Without Explicit Override)

```
seg(i,t) = [IPD(i, CHN, t) - IPD(i, US, t)] / [IPD(i, US, t) + IPD(i, CHN, t)]

Exposure_{c,t} = Σ_{i ≠ c} w_{i,c,t} · seg(i,t)

where w_{i,c,t} = FVA_{i,c,t} / Σ_{k ≠ c} FVA_{k,c,t}
and   FVA_{i,c,t} = sum of VAcontr rows belonging to country i,
      from g = L · y_c (must recompute for each focus country c and year t)

INVARIANT: Σ_{i≠c} w_{i,c,t} = 1.0 (tolerance 1e-6) — assert before computing Exposure
```

## Empirical Applications

| Application | Datasets | Purpose | Status |
|------------|---------|---------|--------|
| Chile pilot | OECD ICIO 2025, Bailey-Strezhnev-Voeten | Develop + validate full pipeline | Not started |
| LA-6 to LA-10 expansion | OECD ICIO 2025, ideal points | Cross-country comparison, main paper results | Not started |
| Sector heatmaps | OECD ICIO 2025 (50 ISIC sectors) | Identify geopolitically vulnerable sectors | Not started |
| Robustness: UNGA-DM | OECD ICIO 2025, Kilby UNGA-DM | Alternative seg construction | Not started |

## Design Principles

| Principle | Rationale |
|-----------|-----------|
| MRIO algebra entirely in Python (numpy/scipy) | N·I × N·I matrices (~4000×4000); Python handles efficiently; Stata cannot |
| Econometrics and descriptive tables in Stata | Primary analysis tool; replication-friendly in the field |
| Figures in matplotlib (Python) or ggplot2 (R) | Publication-ready; no default Stata graphs in paper |
| seg from IPD (Bailey-Strezhnev-Voeten) is primary | Theoretically motivated; UNGA-DM is robustness only |
| Country scope: Latin America (~6-10 countries) | Introductory/seminal positioning; Chile pilot first |

## Anti-Patterns (Do Not Do This)

| Anti-Pattern | Problem | Correct Approach |
|-------------|---------|-----------------|
| MRIO algebra in Stata | Too slow; scalar loops on 4000×4000 matrices | Python (numpy) only |
| Use gross imports as weights | Conflates direct trade with upstream supply-chain exposure | Always use Leontief-derived FVA weights |
| Mix IPD-based and UNGA-DM seg in same specification | Inconsistent measurement | One primary, one robustness; label clearly |
| Skip weight normalization check | Rounding errors cause exposure drift | Assert Σw = 1.0 ± 1e-6 before computing Exposure |
| Set v = NA when x = 0 | Propagates NAs through entire VAcontr | Set v_i = 0; add comment explaining treatment |
| Stata regression without clustering | Understated SEs in country-year panel | Always vce(cluster countrycode) |
| Cite "OECD 2023 ICIO" | Wrong release year | Cite "OECD 2025 ICIO" (1995-2022 coverage) |
| Conflate Exposure with trade openness | Different concepts; Exposure is about alignment, not volume | Frame as geopolitical tilt, not dependence per se |

## Python / Stata Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| ICIO row/col ordering varies by year | Wrong Leontief inverse | Verify ordering from ReadMe annex every year |
| diag(x)^{-1} when x_i = 0 | Division by zero → inf/NaN in A | Detect zero-output rows; set corresponding v_i = 0 |
| Leontief fails (singular I-A) | Cannot compute L | Check spectral radius of A < 1; flag year |
| Ideal-point missing for small states | NA propagates to Exposure | Drop from index or interpolate; document in footnote |
| merge in Stata yields _merge=2 | Unmatched source rows kept silently | Assert _merge==3 or explicitly handle exceptions |
| xtset not called before xtreg | Stata silently runs pooled OLS | Always xtset countrycode year at do-file top |
| numpy matmul on non-contiguous array | Silent wrong result | Use np.ascontiguousarray() before large matmuls |
