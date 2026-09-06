# 04_fit_report.R — run the decline-curve engine over every Volve producer
#
# Input : data/processed/volve_monthly.rds  (from 01_load_data.R)
# Output: outputs/decline/well_decline_params.csv
#         outputs/decline/forecast_all.csv
#         outputs/decline/decline_fits.rds
#         outputs/decline/fit_<well>.png            (one per well)
#         outputs/decline/decline_all.png           (facet)
#         outputs/decline/field_forecast.png        (history + forecast, field total)
#         outputs/decline/DECLINE_SUMMARY.md
#
# Config: edit the block below, then  source("R/04_fit_report.R")

source("R/utils.R")
source("R/03_decline_curve.R")
check_wd()

# ---- config ----
Q_ECON    <- 50       # economic oil rate (bopd) ending each forecast
WINDOW    <- "auto"   # "auto" | "post_peak" | "last_stable" | "all"
MAX_YEARS <- 30       # forecast horizon cap (auto-tightened for weak/short fits)
B_MAX     <- 1.5      # upper bound on hyperbolic exponent b
# ----------------

mfile <- "data/processed/volve_monthly.rds"
if (!file.exists(mfile)) stop("Missing ", mfile, " - run source(\"R/01_load_data.R\") first.")
monthly <- readRDS(mfile)
ensure_dir("outputs/decline")

message("Fitting decline curves  (q_econ = ", Q_ECON, " bopd, window = ", WINDOW,
        ", b_max = ", B_MAX, ") ...")
res <- fit_all_wells(monthly, q_econ = Q_ECON, window = WINDOW,
                     max_years = MAX_YEARS, b_max = B_MAX)

# --- write tables ---
readr::write_csv(res$summary,  "outputs/decline/well_decline_params.csv")
readr::write_csv(res$forecast, "outputs/decline/forecast_all.csv")
saveRDS(res$fits, "outputs/decline/decline_fits.rds")

# --- per-well plots ---
safe <- function(x) gsub("[^A-Za-z0-9]+", "_", x)
for (w in names(res$fits)) {
  p <- plot_decline_fit(res$fits[[w]])
  ggsave(file.path("outputs/decline", paste0("fit_", safe(w), ".png")),
         p, width = 8, height = 5, dpi = 150)
}

# --- facet of all wells ---
ok_fits <- Filter(\(f) isTRUE(f$ok), res$fits)
if (length(ok_fits)) {
  alls <- dplyr::bind_rows(lapply(ok_fits, \(f) dplyr::mutate(f$series, well = f$well)))
  p_all <- ggplot(alls, aes(date, rate_bopd, colour = phase)) +
    geom_point(data = ~dplyr::filter(.x, phase == "history", rate_bopd > 0), size = 0.6) +
    geom_line(data  = ~dplyr::filter(.x, phase == "fit", rate_bopd > 0), linewidth = 0.7) +
    geom_line(data  = ~dplyr::filter(.x, phase == "forecast"), linewidth = 0.8) +
    scale_colour_manual(values = c(history = "#37474f", fit = "#1b5e9c", forecast = "#c62828")) +
    scale_y_log10(labels = scales::comma) +
    facet_wrap(~ well, scales = "free_y") +
    labs(title = "Decline-curve fits & forecasts", x = NULL, y = "Oil rate (bopd, log)",
         colour = NULL) +
    theme_geoai()
  ggsave("outputs/decline/decline_all.png", p_all, width = 11, height = 6.5, dpi = 150)

  # --- field-level history + forecast ---
  field <- alls |>
    dplyr::filter(phase %in% c("history", "forecast")) |>
    dplyr::mutate(month = lubridate::floor_date(date, "month")) |>
    dplyr::group_by(month, phase) |>
    dplyr::summarise(rate_bopd = sum(rate_bopd, na.rm = TRUE), .groups = "drop") |>
    dplyr::filter(rate_bopd > 0)
  p_field <- ggplot(field, aes(month, rate_bopd, colour = phase)) +
    geom_line(linewidth = 1) +
    scale_colour_manual(values = c(history = "#37474f", forecast = "#c62828")) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Volve field - oil rate: history vs decline-curve forecast",
         x = NULL, y = "Oil rate (bopd)", colour = NULL) +
    theme_geoai()
  ggsave("outputs/decline/field_forecast.png", p_field, width = 10, height = 5.5, dpi = 150)
}

# --- markdown summary ---
write_decline_md <- function(path, summ, cfg) {
  con <- file(path, open = "w", encoding = "UTF-8"); on.exit(close(con))
  wl <- function(...) writeLines(paste0(..., collapse = ""), con)
  ok <- dplyr::filter(summ, ok)
  wl("# Volve - Decline-Curve Fits")
  wl("")
  wl("_Generated ", format(Sys.time(), "%Y-%m-%d %H:%M"), " by `R/04_fit_report.R`_  ")
  wl("Config: economic rate = ", cfg$q_econ, " bopd | fit window = `", cfg$window,
     "` | b_max = ", cfg$b_max, " | max horizon = ", cfg$max_years, " yr")
  wl("")
  wl("## Fitted parameters & EUR")
  wl("")
  wl("| Well | Model | Window | qi (bopd) | Di /yr | b | 1st-yr decline | R² | End of life | Np to date (MMbbl) | Remaining (MMbbl) | **EUR (MMbbl)** |")
  wl("|---|---|---|--:|--:|--:|--:|--:|---|--:|--:|--:|")
  for (i in seq_len(nrow(ok))) {
    r <- ok[i, ]
    wl("| ", r$well, " | ", r$model, " | ", r$window,
       " | ", formatC(r$qi_bopd, format = "d", big.mark = ","),
       " | ", sprintf("%.2f", r$Di_nom_annual),
       " | ", sprintf("%.2f", r$b),
       " | ", sprintf("%.0f%%", 100 * r$de_first_year),
       " | ", sprintf("%.2f", r$r2),
       " | ", format(r$eol_date),
       " | ", sprintf("%.2f", r$np_to_date_mbbl),
       " | ", sprintf("%.2f", r$remaining_mbbl),
       " | **", sprintf("%.2f", r$eur_mmbbl), "** |")
  }
  wl("")
  tot_eur <- sum(ok$eur_mmbbl); tot_rem <- sum(ok$remaining_mbbl)
  wl("**Field total:** EUR ", sprintf("%.2f", tot_eur),
     " MMbbl  (", sprintf("%.2f", tot_rem), " MMbbl remaining to produce)")
  wl("")
  fl <- dplyr::filter(summ, nzchar(flags))
  if (nrow(fl)) {
    wl("## Flags")
    wl("")
    for (i in seq_len(nrow(fl))) wl("- **", fl$well[i], "** - ", fl$flags[i])
    wl("")
  }
  wl("## Figures")
  wl("")
  for (f in c("field_forecast.png", "decline_all.png")) { wl("![", f, "](", f, ")"); wl("") }
  wl("## Method")
  wl("")
  wl("Arps rate model  q(t) = qi / (1 + b·Di·t)^(1/b)  fitted by Levenberg-Marquardt ",
     "(`minpack.lm`). Exponential (b=0), hyperbolic (0<b<1, multi-start, b capped at ",
     "b_max) and harmonic (b=1) are each fitted on the chosen window; the lowest-AICc ",
     "model is reported. Time origin is the first month of the fit window, so `qi` is ",
     "the rate at the start of the analysed decline. EUR = cumulative produced to date ",
     "+ closed-form Arps cumulative from the last observed rate down to the economic ",
     "rate. Horizon is auto-tightened to 10 yr for weak (R²<0.6) or short (<1.5 yr) fits.")
  wl("")
  wl("_Single-well DCA to an economic rate does not model field-level abandonment: ",
     "several Volve wells were shut in well above their economic rate when the platform ",
     "left in 2016, so per-well \"remaining\" is an upper bound on what was practically ",
     "recoverable. Not reserves in the SPE-PRMS sense._")
}
write_decline_md("outputs/decline/DECLINE_SUMMARY.md", res$summary,
                 list(q_econ = Q_ECON, window = WINDOW, max_years = MAX_YEARS, b_max = B_MAX))

# --- console echo ---
cat("\n================ DECLINE-CURVE SUMMARY ================\n")
print(as.data.frame(res$summary |>
  dplyr::select(well, model, qi_bopd, Di_nom_annual, b, r2,
                last_rate_bopd, eur_mmbbl, flags)), row.names = FALSE)
cat("\nWrote outputs/decline/ : params CSV, forecast CSV, fits RDS, ",
    length(res$fits), " well PNGs, 3 rollup PNGs, DECLINE_SUMMARY.md\n", sep = "")
cat("04_fit_report.R done.\n")
