---
paths:
  - "**/*.R"
  - "Figures/**/*.R"
  - "scripts/**/*.R"
---

# R Code Standards

**Standard:** Senior Principal Data Engineer + PhD researcher quality

These standards apply to all R scripts in this repository.

---

## 1. Script Structure

Every script MUST follow this section layout:

```r
# ==============================================================================
# [Lecture N]: [Descriptive Title]
# ==============================================================================
#
# Author:   [Your Name]
# Source:   [Paper(s) replicated / adapted from]
#
# Purpose:
#   [2-4 sentence description]
#
# Inputs:
#   - [data source or URL]
#
# Outputs (saved to Figures/LectureN/):
#   - [file.pdf]  -- [description]
#   - [file.rds]  -- [description]
#
# Runtime: ~X min
# ==============================================================================
```

Numbered sections: 0. Setup, 1. Data/DGP, 2. Estimation, 3. Run, 4. Figures, 5. Export

## 2. Console Output Policy

**Scripts are NOT notebooks.**

- **Allowed:** `message()` for progress milestones only
- **Forbidden:** `cat()`, `print()`, ASCII banners, per-iteration output

## 3. Reproducibility

- `set.seed()` called ONCE at top (YYYYMMDD format)
- All packages loaded at top via `library()` (not `require()`)
- All paths relative to repository root
- `dir.create(..., recursive = TRUE)` for output directories

## 4. Function Design

- `snake_case` naming, verb-noun pattern
- Roxygen-style documentation
- Default parameters, no magic numbers
- Named return values (lists or tibbles)

## 5. Domain Correctness

<!-- Customize for your field's known pitfalls -->
- Verify estimator implementations match slide formulas
- Check known package bugs (document in Section 12 below)

## 6. Visual Identity

```r
# --- Your institutional palette ---
# Customize these colors for your institution
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

## 7. RDS Data Pattern

**Heavy computations saved as RDS; slide rendering loads pre-computed data.**

```r
saveRDS(result, file.path(out_dir, "descriptive_name.rds"))
```

## 8. Code Quality Checklist

```
[ ] Header with all fields
[ ] Numbered sections
[ ] Packages at top via library()
[ ] set.seed() once at top
[ ] All paths relative
[ ] Functions documented
[ ] No cat/print output
[ ] Figures: transparent bg, explicit dimensions
[ ] RDS: every computed object saved
[ ] Comments explain WHY not WHAT
```

## 9. Common Pitfalls

<!-- Add your field-specific pitfalls here -->
| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `bg = "transparent"` | White boxes on slides | Always include in ggsave() |
| `cat()` for status | Noisy stdout | Use message() sparingly |
| Hardcoded paths | Breaks on other machines | Use relative paths |

## 10. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 100 characters for readability.

**Exception: Mathematical Formulas** — Lines containing complex mathematical operations may exceed 100 characters **if and only if:**

1. **Breaking the line would harm readability of the math.** Examples:
   - Influence function calculations with multiple components
   - Matrix operations (row/column definitions, element-wise operations)
   - Numerical derivative / finite-difference approximations
   - Complex formula implementations matching paper equations

2. **An inline comment explains the mathematical operation.** Example:
   ```r
   # Sieve projection: inner product of residuals onto basis functions P_k
   alpha_k <- sum(r_i * basis[, k]) / sum(basis[, k]^2)
   ```

3. **The line is in a numerically intensive section** (simulation loops, estimation routines, inference calculations).

**Rationale:** Mathematical code is harder to read when broken across multiple lines. Preserving formula structure reduces bugs, improves maintainability, and matches standard statistical computing practice.

**Quality Gate Impact:**
- Long lines in non-mathematical code → minor penalty (-1 to -2 points per line)
- Long lines in documented mathematical sections → no penalty (acceptable exception)
