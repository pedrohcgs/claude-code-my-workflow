---
paths:
  - "**/*.R"
  - "Figures/**/*.R"
  - "scripts/**/*.R"
---

# R Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

---

## 1. Reproducibility

- `set.seed()` called ONCE at top (YYYYMMDD format)
- All packages loaded at top via `library()` (not `require()`)
- All paths relative to repository root
- `dir.create(..., recursive = TRUE)` for output directories

## 2. Function Design

- `snake_case` naming, verb-noun pattern
- Roxygen-style documentation
- Default parameters, no magic numbers
- Named return values (lists or tibbles)

## 3. Domain Correctness

<!-- Customize for your field's known pitfalls -->
- Verify estimator implementations match slide formulas
- Check known package bugs (document below in Common Pitfalls)

## 4. Visual Identity

```r
# --- Colorblind-safe palette (viridis default) ---
# Use scale_color_viridis_d() / scale_fill_viridis_d() for categorical
# Use scale_color_viridis_c() / scale_fill_viridis_c() for continuous
# ColorBrewer alternative: RColorBrewer::brewer.pal(n, "Set2")
```

### Custom Theme
```r
theme_energy <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "grey40"),
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank()
    )
}
```

### Figure Dimensions for Documents
```r
# Standard report figure (white bg for PDF output)
ggsave(filepath, width = 8, height = 5, dpi = 300, bg = "white")
```

## 5. RDS Data Pattern

**Heavy computations saved as RDS; slide rendering loads pre-computed data.**

```r
saveRDS(result, file.path(out_dir, "descriptive_name.rds"))
```

## 6. Common Pitfalls

### General
| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `bg = "white"` | Transparent/grey bg in PDF output | Always set `bg = "white"` in `ggsave()` |
| Hardcoded paths | Breaks on other machines | Use `here::here()` for all paths |

### Energy Economics (Domain-Specific)

| Pitfall | Impact | Fix |
|---------|--------|-----|
| `WDI` package: omitting `extra = TRUE` | Misses metadata columns (region, income group) needed for subgroup analysis | `WDI(extra = TRUE, start = 2000, end = 2023)` — always specify `startdate`/`enddate` |
| IEA manual data: mixing vintages (Mtoe vs. EJ) | Silent unit error; estimates off by factor ~41.87 | Pin one vintage; document year of download; check units in source metadata |
| Panel energy regressions: skipping cross-sectional dependence test | Biased/inconsistent SE if CD present; wrong estimator choice | Run `pesaran.test()` (from `plm`) or `pcdtest()` first; if CD → use CCEP or AMG estimator |
| `urca` ADF only (no KPSS) | ADF has low power; may accept H₀ of unit root incorrectly | Always pair ADF (`ur.df()`) + KPSS (`ur.kpss()`); report both; document conflict if found |
| `vars` package: lag selection without stability check | Unstable VAR gives unreliable IRFs and Granger tests | Select lag by AIC (`VARselect()`), then check `roots()` — all eigenvalues must be < 1 |
| Using nominal GDP in energy intensity | EI not comparable cross-country or across time | Use PPP-adjusted constant GDP from WDI (`NY.GDP.MKTP.PP.KD`) |
| Granger causality → claiming structural causality | Granger tests forecast precedence, not mechanism | Write "Granger-causes" explicitly; note it is not structural identification |

## 7. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 100 characters.

**Exception: Mathematical Formulas** -- lines may exceed 100 chars **if and only if:**

1. Breaking the line would harm readability of the math (influence functions, matrix ops, finite-difference approximations, formula implementations matching paper equations)
2. An inline comment explains the mathematical operation:
   ```r
   # Sieve projection: inner product of residuals onto basis functions P_k
   alpha_k <- sum(r_i * basis[, k]) / sum(basis[, k]^2)
   ```
3. The line is in a numerically intensive section (simulation loops, estimation routines, inference calculations)

**Quality Gate Impact:**
- Long lines in non-mathematical code: minor penalty (-1 to -2 per line)
- Long lines in documented mathematical sections: no penalty

## 8. Code Quality Checklist

```
[ ] Packages at top via library()
[ ] set.seed() once at top
[ ] All paths relative
[ ] Functions documented (Roxygen)
[ ] Figures: transparent bg, explicit dimensions
[ ] RDS: every computed object saved
[ ] Comments explain WHY not WHAT
```
