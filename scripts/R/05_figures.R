# =============================================================================
# 05_figures.R — Publication-ready figures -> PDF (for the Beamer deck / note).
#
# PDF only: this project renders Quarto -> Beamer (no HTML/SVG target). Figures
# use the project palette (kept in sync with Preambles/header.tex) and a
# transparent background so they sit cleanly on slides.
# =============================================================================

for (obj in c("returns", "OUT_DIR")) {
  if (!exists(obj, inherits = FALSE)) {
    stop("05_figures.R: `", obj, "` missing. Run 00_run_all.R, not this script directly.")
  }
}
if (exists("PROJECT_SEED", inherits = FALSE)) set.seed(PROJECT_SEED)

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("05_figures.R: 'ggplot2' is required and not installed.\n",
       "Install with: install.packages('ggplot2'). No silent base-R fallback.")
}
library(ggplot2)

# ---- Project palette (MUST match Preambles/header.tex \definecolor names) ---
primary_blue   <- "#012169"  # primary-blue
highlight_gold <- "#B9975B"  # primary-gold
jet            <- "#1A1A1A"  # body text
positive_green <- "#15803D"  # positive
negative_red   <- "#B91C1C"  # negative
neutral_gray   <- "#525252"  # neutral

theme_ipo <- function(base_size = 14) {  # >= 14 for Beamer projection legibility
  theme_minimal(base_size = base_size) +
    theme(
      plot.title      = element_text(face = "bold", color = primary_blue),
      axis.text       = element_text(color = jet),
      axis.title      = element_text(color = jet),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      plot.background  = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA),
      legend.background = element_rect(fill = "transparent", color = NA)
    )
}

has_cairo  <- tryCatch(capabilities("cairo"), error = function(e) FALSE)
pdf_device <- if (has_cairo) grDevices::cairo_pdf else grDevices::pdf

save_fig <- function(plot, file, width = 8, height = 4.5) {
  path <- file.path(OUT_DIR, file)
  ggsave(path, plot, width = width, height = height, device = pdf_device, bg = "transparent")
  message("Wrote ", path)
}

# ---- Figure 1: mean first-day underpricing by IPO year, US vs UK ------------
up <- returns$underpricing[!is.na(returns$underpricing$underpricing), , drop = FALSE]
if (nrow(up) > 0L) {
  up_year <- stats::aggregate(underpricing ~ ipo_year + region, data = up,
                              FUN = function(x) mean(x, na.rm = TRUE))
  fig_up <- ggplot(up_year, aes(x = ipo_year, y = underpricing, color = region)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 1.5) +
    scale_color_manual(values = c(US = primary_blue, UK = highlight_gold)) +
    scale_y_continuous(labels = function(v) paste0(round(100 * v), "%")) +
    labs(title = "First-day IPO underpricing by year", x = NULL,
         y = "Mean initial return", color = NULL) +
    theme_ipo()
  save_fig(fig_up, "fig_underpricing_by_year.pdf")
} else {
  warning("05_figures.R: no underpricing observations to plot.", call. = FALSE)
}

# ---- Figure 2: 36-month BHAR distribution by region -------------------------
lr <- returns$longrun[!is.na(returns$longrun$bhar), , drop = FALSE]
if (nrow(lr) > 0L) {
  fig_bhar <- ggplot(lr, aes(x = region, y = bhar)) +
    geom_hline(yintercept = 0, color = neutral_gray, linewidth = 0.4) +
    geom_boxplot(width = 0.55, fill = "#E8EDF5", color = primary_blue, outlier.alpha = 0.3) +
    stat_summary(fun = mean, geom = "point", shape = 18, size = 2.4, color = negative_red) +
    scale_y_continuous(labels = function(v) paste0(round(100 * v), "%")) +
    labs(title = "36-month buy-and-hold abnormal returns by region",
         x = NULL, y = "BHAR vs benchmark") +
    theme_ipo()
  save_fig(fig_bhar, "fig_bhar_by_region.pdf")
} else {
  warning("05_figures.R: no BHAR observations to plot.", call. = FALSE)
}
