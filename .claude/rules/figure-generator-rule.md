---
paths:
  - "**/*.R"
  - "Figures/**"
  - "figures/**"
---

# ggplot2 Figure Standards

**Target:** Publication-quality figures matching AER, QJE, and Econometrica visual standards.

---

## 1. No In-Figure Text

- **Never** use `ggtitle()`, `labs(title = ...)`, or `labs(subtitle = ...)`
- **Never** use `labs(caption = ...)` or `annotate()` for source notes
- Titles, numbering, and notes belong in the paper/presentation, not the figure
- The figure file name and folder location identify what the figure shows

## 2. Serif Typography

All text elements must use a serif font consistent with economics journals.

```r
library(showtext)
font_add_google("Source Serif Pro", "source_serif")
# Alternative: font_add("cm", "cmunrm.otf") for Computer Modern
showtext_auto()
```

Apply serif to every text element:

```r
theme(
  text              = element_text(family = "source_serif"),
  axis.title        = element_text(family = "source_serif"),
  axis.text         = element_text(family = "source_serif"),
  legend.text       = element_text(family = "source_serif"),
  legend.title      = element_text(family = "source_serif"),
  strip.text        = element_text(family = "source_serif")
)
```

## 3. Journal Theme

```r
theme_econ <- function(base_size = 12, base_family = "source_serif") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # No title elements
      plot.title       = element_blank(),
      plot.subtitle    = element_blank(),
      plot.caption     = element_blank(),

      # Clean axes
      axis.title       = element_text(size = rel(1.0), face = "plain"),
      axis.text        = element_text(size = rel(0.85), color = "grey20"),
      axis.ticks       = element_line(color = "grey40", linewidth = 0.3),
      axis.line        = element_line(color = "grey40", linewidth = 0.3),

      # Minimal grid: horizontal reference lines only
      panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      panel.background   = element_rect(fill = "transparent", color = NA),
      plot.background    = element_rect(fill = "transparent", color = NA),

      # Legend
      legend.position  = "bottom",
      legend.title     = element_text(size = rel(0.85), face = "plain"),
      legend.text      = element_text(size = rel(0.80)),
      legend.key       = element_rect(fill = "transparent", color = NA),
      legend.background = element_rect(fill = "transparent", color = NA),

      # Facet strips
      strip.text       = element_text(size = rel(0.90), face = "plain"),
      strip.background = element_rect(fill = "grey95", color = NA),

      # Margins
      plot.margin      = margin(t = 5, r = 10, b = 5, l = 5, unit = "pt")
    )
}
```

## 4. Color and Linetype

- Default to **grayscale** for print compatibility: `scale_color_grey()`, `scale_fill_grey()`
- When color is needed, use a colorblind-safe palette (max 4-5 distinct colors)
- Always pair color with a second channel: linetype (`scale_linetype_manual`), shape (`scale_shape_manual`), or fill pattern
- Confidence bands: `geom_ribbon(alpha = 0.15)`

## 5. Axis and Label Formatting

- Axis labels: descriptive, with units in parentheses -- e.g., `"Income (USD, thousands)"`
- Use `scales::comma`, `scales::percent`, or `scales::dollar` for numeric axes
- Remove axis label when the meaning is obvious from context (e.g., "Year" on a time series)
- Breaks should be round numbers; avoid ggplot2 auto-breaks when they produce odd intervals

## 6. Multi-Panel Figures

- Use `facet_wrap()` or `facet_grid()` with `scales = "free_y"` only when axis ranges genuinely differ
- Panel tags use lowercase letters: (a), (b), (c) via `tag` in `labs()` or annotation
- Consistent axis ranges across panels when comparability matters

## 7. Export

```r
ggsave(
  filepath,
  width  = 6.5,   # AER single-column width in inches
  height = 4.0,
  dpi    = 300,
  bg     = "transparent",
  device = cairo_pdf  # or "pdf" -- vector format for journals
)
```

- **Vector format** (PDF or EPS) for journal submission
- **PNG at 300+ dpi** for presentations and drafts
- Always `bg = "transparent"`
- Standard widths: 6.5 in (single-column), 12 in (full-width / Beamer)

## 8. File Naming

Figures are self-documenting through their path and name:

```
figures/
├── descriptive/
│   ├── hist_income_distribution.pdf
│   └── scatter_education_earnings.pdf
├── estimation/
│   ├── coefplot_main_specification.pdf
│   └── event_study_treatment.pdf
└── robustness/
    └── coefplot_alternative_controls.pdf
```

Pattern: `{plot_type}_{variable_or_content}.pdf`

## 9. Prohibited Patterns

| Pattern | Reason |
|---------|--------|
| `ggtitle()` | Titles go in the document, not the figure |
| `labs(title = ..., caption = ...)` | Same -- no in-figure titles or notes |
| `theme_gray()` / `theme_bw()` default | Not journal quality |
| Sans-serif fonts | Journals require serif |
| Rainbow / jet color scales | Not colorblind-safe, not professional |
| 3D effects, excessive decoration | Violates minimalism standard |
| `png()` for final output | Use vector formats (PDF/EPS) for publication |
