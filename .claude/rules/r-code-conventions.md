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
| Ignoring zero-trade observations | Biased OLS on log(exports) | Use PPML or explicitly document sample restriction |
| `log(trade + 1)` without justification | Inconsistent with theory; results not comparable across papers | Document transformation choice; default to PPML unless theory demands log-OLS |
| Clustering SE at firm only when exporting to multiple destinations | Under-rejection when errors are correlated across destinations | Cluster at the appropriate level; see Abadie et al. (2023) |
| Country/firm FE absorbed without collinearity check | Perfect multicollinearity silently drops variables | Use `fixest::feols()` and inspect `summary()` for dropped dummies |
| Credit constraint proxy undefined or undocumented | Replication impossible | Construct and document proxy in a dedicated `00_construct_proxies.R` |
| No overlap check before comparing credit-constrained vs. unconstrained firms | Extrapolating far outside common support | Run balance table + overlap diagnostic before any ATT/ATET estimation |

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

## 8. Numerical Discipline

See [`r-reviewer.md`](../agents/r-reviewer.md) Category 11 ("Numerical Discipline") for the full checklist. Headline rules:

- **No float equality.** Never use `==` on doubles. Use `all.equal()` or `abs(a - b) < tol`.
- **CDF clamping** to an OPEN interval. Exact 0 or 1 passed to `qnorm()` / `pbinom()` etc. produces `±Inf`. Project-wide epsilon:

  ```r
  eps <- 1e-12
  p <- pmin(1 - eps, pmax(eps, p))   # now safe for qnorm(p)
  ```

- **Integer literals for counts.** `nrow <- 1000L` (not `1000`), `for (i in 1L:nL)` — avoids silent promotion.
- **Pre-allocate vectors** before loops (`numeric(n)`, `vector("list", n)`), never grow with `c()`.
- **Deterministic bootstrap seeding.** Set seed before the bootstrap, and if the bootstrap is nested, set per-replicate seeds as `seed_base + b`.
- **Explicit `na.rm = TRUE/FALSE`.** Never rely on defaults for `mean()`, `sd()`, `sum()` on data with potential NAs.
- **No `T` / `F`.** They're variables, not constants — write `TRUE` / `FALSE`.

## 9. Code Quality Checklist

```
[ ] Packages at top via library()
[ ] set.seed() once at top (YYYYMMDD)
[ ] All paths relative
[ ] Functions documented (Roxygen)
[ ] Figures: transparent bg, explicit dimensions
[ ] RDS: every computed object saved
[ ] Comments explain WHY not WHAT
[ ] Numerical discipline: no float ==, CDF clamping with eps, pre-allocated vectors
```
