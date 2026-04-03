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
# --- Boston College palette ---
bc_maroon     <- "#872034"
bc_gold       <- "#EAAA00"
accent_gray   <- "#666666"
positive_green <- "#2E7D32"
negative_red  <- "#D32F2F"
```

### Custom Theme
```r
theme_regfrag <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", color = bc_maroon),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}
```

### Figure Dimensions for Manuscript (single-column journal)
```r
ggsave(filepath, width = 6.5, height = 4, dpi = 300, bg = "white")
```

### Figure Dimensions for Beamer (conference presentations)
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
| Missing `bg = "transparent"` | White boxes on slides | Include in ggsave() for presentations |
| Hardcoded paths | Breaks on other machines | Use relative paths |
| Winsorization at wrong level | Biased estimates | Winsorize at 1%/99% by default; document choice |
| Clustering SEs at wrong level | Incorrect inference | Cluster at firm level unless theory dictates otherwise |
| `fixest::feols` vs `lm` defaults | Different SE computation | Use `feols` with explicit `vcov` argument |
| Not logging skewed variables | Non-normal residuals | Log-transform size, assets, revenue |
| Missing industry/year FE | Omitted variable bias | Always include unless theoretically motivated |

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
