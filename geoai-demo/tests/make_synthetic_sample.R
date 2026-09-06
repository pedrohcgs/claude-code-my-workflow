# make_synthetic_sample.R — generate a Volve-shaped CSV so the Day 1 pipeline
# can be tested before the real 'Volve production data.xlsx' is available.
#
# Writes: data/SYNTHETIC_sample_delete_me.csv
# This file is NOT the real dataset. Delete it once you have the Equinor download.

source("R/utils.R")
check_wd()
set.seed(42)

wells <- tibble::tribble(
  ~well,          ~type, ~qi,    ~Di_ann, ~start,        ~gap,
  "15/9-F-12",    "OP",  9800,   0.62,    "2014-04-01",  NA,
  "15/9-F-14",    "OP",  7300,   0.55,    "2014-02-01",  NA,
  "15/9-F-11",    "OP",  4200,   0.48,    "2013-09-01",  c("2015-06-01", "2015-09-01"),
  "15/9-F-1 C",   "OP",  2600,   0.40,    "2013-06-01",  NA,
  "15/9-F-4",     "WI",  0,      0.00,    "2013-06-01",  NA
)

make_well <- function(w) {
  start <- as.Date(w$start)
  days  <- seq(start, by = "day", length.out = 365 * 3)
  t_yr  <- as.numeric(days - start) / 365.25
  if (w$type == "WI") {
    oil <- rep(0, length(days)); gas <- rep(0, length(days))
    wat <- pmax(rnorm(length(days), 5200, 400), 0)          # injector: water only
    hrs <- rep(24, length(days))
  } else {
    rate <- w$qi * exp(-w$Di_ann * t_yr)                    # exponential decline
    rate <- rate * rlnorm(length(days), 0, 0.06)            # daily noise
    oil  <- pmax(rate / SM3_TO_BBL, 0)                      # store as Sm3
    gor  <- 180 + 40 * t_yr
    gas  <- oil * gor
    wcut <- plogis((t_yr - 1.6) * 2.2) * 0.85               # water cut climbs over time
    wat  <- oil * wcut / pmax(1 - wcut, 0.05)
    hrs  <- pmin(pmax(rnorm(length(days), 22.5, 3), 0), 24)
  }
  df <- tibble::tibble(
    DATEPRD           = days,
    NPD_WELL_BORE_NAME = w$well,
    ON_STREAM_HRS     = round(hrs, 1),
    BORE_OIL_VOL      = round(oil, 2),
    BORE_GAS_VOL      = round(gas, 1),
    BORE_WAT_VOL      = round(wat, 2),
    BORE_WI_VOL       = if (w$type == "WI") round(wat, 2) else 0,
    FLOW_KIND         = if (w$type == "WI") "injection" else "production",
    WELL_TYPE         = w$type
  )
  # punch a shut-in gap if defined
  g <- w$gap[[1]]
  if (!all(is.na(g))) {
    off <- df$DATEPRD >= as.Date(g[1]) & df$DATEPRD < as.Date(g[2])
    df$BORE_OIL_VOL[off] <- 0; df$BORE_GAS_VOL[off] <- 0
    df$BORE_WAT_VOL[off] <- 0; df$ON_STREAM_HRS[off] <- 0
  }
  df
}

out <- dplyr::bind_rows(lapply(seq_len(nrow(wells)), \(i) make_well(wells[i, ])))
ensure_dir("data")
readr::write_csv(out, "data/SYNTHETIC_sample_delete_me.csv")
message("Wrote data/SYNTHETIC_sample_delete_me.csv  (", nrow(out), " rows, ",
        dplyr::n_distinct(out$NPD_WELL_BORE_NAME), " wells)")
message("Now run:  source(\"run_day1.R\")   to test the pipeline on synthetic data.")
message("Delete the CSV (and data/processed/, outputs/eda/) once the real file is in.")
