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

## 3. Domain Correctness (Applied Econometrics)

- Verify estimator implementations match paper equations exactly
- Check estimand: ATT vs ATE vs LATE — does the code produce what the paper claims?
- Clustering level must match treatment assignment unit (not individual if treatment is at group level)
- For staggered DiD: NEVER use TWFE without checking for negative weights / heterogeneous TE bias
  - Use `did::att_gt()` (Callaway-Sant'Anna), `fastdid`, `fixest::sunab()`, or `did2s` instead
  - If TWFE is used, must include Goodman-Bacon decomposition or de Chaisemartin-D'Haultfoeuille diagnostics
- For IV: ALWAYS report first-stage F-statistic; flag if < 10 (prefer Montiel Olea-Pflueger effective F)
- For RDD: ALWAYS run `rddensity` (McCrary test) before `rdrobust`; check bandwidth is MSE-optimal or justified
- For event studies: use `fixest::i()` with explicit reference period; check pre-trend coefficients
- `did::att_gt()` requires `control_group = "nevertreated"` or `"notyettreated"` — document choice
- Standard errors: `fixest` defaults to appropriate cluster-robust; verify `lm()` scripts use `sandwich` or `clubSandwich`
- Check known package bugs (document below in Common Pitfalls)

## 4. Visual Identity

```r
# --- Your institutional palette ---
primary_blue  <- "#012169"
primary_gold  <- "#f2a900"
accent_gray   <- "#525252"
positive_green <- "#15803d"
negative_red  <- "#b91c1c"
```

### Custom Theme
```r
theme_custom <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", color = primary_blue),
      legend.position = "bottom"
    )
}
```

### Figure Dimensions for Beamer
```r
ggsave(filepath, width = 12, height = 5, bg = "transparent")
```

## 5. RDS Data Pattern

**Heavy computations saved as RDS; slide rendering loads pre-computed data.**

```r
saveRDS(result, file.path(out_dir, "descriptive_name.rds"))
```

## 6. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `bg = "transparent"` | White boxes on slides | Always include in ggsave() |
| Hardcoded paths | Breaks on other machines | Use relative paths |
| TWFE with staggered DiD + heterogeneous TE | Biased ATT estimate, negative weights | Use `did` (CS), `fastdid`, or `fixest::sunab()` |
| Clustering at individual level when treatment is at group level | SEs too small, over-rejection | Cluster at treatment assignment unit |
| Wild bootstrap not used with few clusters ($\leq 50$) | Invalid inference | Use `fwildclusterboot::boottest()` or `fixest::feols(..., vcov = ~unit)` with `boottest` |
| RDD without McCrary density test | Invalid continuity assumption | Always run `rddensity::rddensity()` first |
| Synthetic control without permutation inference | No valid p-values | Run placebo for every donor unit, compute RMSPE ratios |
| Event study binning endpoints without documentation | Masks pre-trends or treatment dynamics | Use `fixest::i(rel_time, ref = -1)` with explicit bin-and-label |
| IV with F < 10 using standard Wald CI | Size distortion under weak instruments | Report Anderson-Rubin CI or use `fixest` tF procedure |
| `lm()` for panel data | Wrong SEs, slow, no FE absorption | Use `fixest::feols()` for any panel specification |
| `feols(..., se = "cluster")` (deprecated) | May not work in future versions | Use `feols(..., cluster = ~unit)` |
| Missing first-stage report in IV | Referee red flag | Always report and interpret first stage |

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
